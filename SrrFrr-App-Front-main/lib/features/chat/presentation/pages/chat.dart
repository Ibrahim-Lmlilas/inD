import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/chat/chat_feature.dart';
import 'package:srrfrr_app_front/features/chat/data/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ChatPage({super.key, required this.data});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  late Map<String, dynamic> chatData;
  late Map<String, dynamic> rideData;
  late final SnackBarService snackBarService;
  late final ChatRepository _chatRepository;

  bool _showScrollToBottom = false;
  bool _isUserScrolling = false;
  bool _isLoadingOlderMessages = false;
  int _currentPage = 0;
  bool _hasMoreMessages = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    chatData = widget.data['chatData'] as Map<String, dynamic>;
    rideData = widget.data['rideData'] as Map<String, dynamic>;
    snackBarService = SnackBarService(context);

    // Initialize ChatRepository with ChatService and ApiInterceptor
    final apiInterceptor = ApiInterceptor();
    final chatService = ChatService(apiInterceptor);
    _chatRepository = ChatRepository(chatService);

    _initializeChat();
    _setupMessageController();
    _setupScrollListener();
  }

  @override
  void dispose() {
    logInfo('ChatPage', 'Disposing ChatPage');
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ChatProvider>();

      final wsToken = chatData['wsToken'] as String?;
      final channelId = chatData['channelId'] as String?;
      final rideId = rideData['ride_id'] as String?;

      if (wsToken == null || channelId == null || rideId == null) {
        snackBarService.showError('Données de connexion manquantes');
        logError('ChatPage', 'Missing required parameters');
        return;
      }

      // Set callback for new messages BEFORE initializing
      provider.onNewMessageReceived = (isOwnMessage) {
        _handleNewMessage(isOwnMessage);
      };

      if (provider.chatId == chatData['chatId'] &&
          provider.channelId == channelId) {
        logInfo('ChatPage', 'Chat already initialized, reconnecting...');
        await provider.reconnect();

        // Scroll to bottom when returning to existing chat
        _scheduleScrollToBottom();
        return;
      }

      logInfo('ChatPage', 'Initializing fresh chat session');

      await provider.initializeChat(
        chatId: chatData['chatId'] ?? '',
        rideId: rideId,
        channelId: channelId,
        wsToken: wsToken,
        currentUserId: chatData['current_user_id'] ?? '',
        otherUserId: chatData['other_user_id'] ?? '',
        otherUserName: chatData['other_user_name'] ?? 'Utilisateur',
      );

      // Load initial messages from API
      await _loadInitialMessages();

      // Scroll to bottom after messages load
      _scheduleScrollToBottom();
    });
  }

  void _scheduleScrollToBottom() {
    // Multiple attempts to ensure scroll happens after build completes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollToBottom(animated: false);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        _scrollToBottom(animated: false);
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _scrollController.hasClients) {
        _scrollToBottom(animated: false);
      }
    });
  }

  void _setupMessageController() {
    _messageController.addListener(() {
      setState(() {});
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      // Handle pagination - load older messages when scrolling near top
      final isNearTop = _scrollController.position.pixels <= 200;

      if (isNearTop && !_isLoadingOlderMessages && _hasMoreMessages) {
        _loadOlderMessages();
      }

      // Track user scroll position
      final distanceFromBottom =
          _scrollController.position.maxScrollExtent - _scrollController.offset;

      final isAtBottom = distanceFromBottom < 100;
      _isUserScrolling = !isAtBottom;

      // Show/hide scroll-to-bottom button
      final showButton = distanceFromBottom > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
          if (isAtBottom) _unreadCount = 0; // Clear unread when at bottom
        });
      }
    });
  }

  Future<void> _loadInitialMessages() async {
    final provider = context.read<ChatProvider>();
    final rideId = rideData['ride_id'] as String?;
    final currentUserId = chatData['current_user_id'] as String?;
    final otherUserName = chatData['other_user_name'] as String?;

    if (rideId == null || currentUserId == null) {
      logError('ChatPage', 'Cannot load messages: missing required data');
      return;
    }

    try {
      logInfo('ChatPage', 'Loading initial messages for ride: $rideId');

      final result = await _chatRepository.loadMessages(
        rideId: rideId,
        currentUserId: currentUserId,
        otherUserName: otherUserName,
        page: 0,
        size: 20,
      );

      if (result.success && result.data != null) {
        final response = result.data!;
        provider.setMessages(response.messages);

        setState(() {
          _currentPage = response.pagination.currentPage;
          _hasMoreMessages = response.pagination.hasMoreMessages;
        });

        logSuccess(
          'ChatPage',
          'Loaded ${response.messages.length} initial messages',
        );
      } else {
        logError('ChatPage', 'Failed to load messages: ${result.error}');
        snackBarService.showError(
          result.error ?? 'Erreur lors du chargement des messages',
        );
      }
    } catch (e, stackTrace) {
      logError('ChatPage', 'Error loading initial messages: $e');
      logError('ChatPage', 'Stack trace: $stackTrace');
      snackBarService.showError('Erreur lors du chargement des messages');
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlderMessages || !_hasMoreMessages) return;

    setState(() => _isLoadingOlderMessages = true);

    // Store current scroll position before loading
    final currentScrollPosition = _scrollController.position.pixels;
    final currentMaxScrollExtent = _scrollController.position.maxScrollExtent;

    try {
      final provider = context.read<ChatProvider>();
      final rideId = rideData['ride_id'] as String?;
      final currentUserId = chatData['current_user_id'] as String?;
      final otherUserName = chatData['other_user_name'] as String?;

      if (rideId == null || currentUserId == null) return;

      final nextPage = _currentPage + 1;
      logInfo('ChatPage', 'Loading page $nextPage of older messages');

      final result = await _chatRepository.loadMessages(
        rideId: rideId,
        currentUserId: currentUserId,
        otherUserName: otherUserName,
        page: nextPage,
        size: 20,
      );

      if (result.success && result.data != null) {
        final response = result.data!;

        if (response.messages.isNotEmpty) {
          provider.prependMessages(response.messages);

          setState(() {
            _currentPage = response.pagination.currentPage;
            _hasMoreMessages = response.pagination.hasMoreMessages;
          });

          logSuccess(
            'ChatPage',
            'Loaded ${response.messages.length} older messages',
          );
          logInfo(
            'ChatPage',
            'Page ${response.pagination.currentPage} of ${response.pagination.totalPages} (hasMore: $_hasMoreMessages)',
          );

          // Restore scroll position after new messages are added
          await Future.delayed(const Duration(milliseconds: 50));
          if (_scrollController.hasClients && mounted) {
            final newMaxScrollExtent =
                _scrollController.position.maxScrollExtent;
            final scrollDifference =
                newMaxScrollExtent - currentMaxScrollExtent;
            final newPosition = currentScrollPosition + scrollDifference;

            _scrollController.jumpTo(newPosition);
          }
        } else {
          setState(() => _hasMoreMessages = false);
          logInfo('ChatPage', 'No more older messages available');
        }
      } else {
        logError('ChatPage', 'Failed to load messages: ${result.error}');
      }
    } catch (e, stackTrace) {
      logError('ChatPage', 'Error loading older messages: $e');
      logError('ChatPage', 'Stack trace: $stackTrace');
      snackBarService.showError('Erreur lors du chargement des messages');
    } finally {
      if (mounted) {
        setState(() => _isLoadingOlderMessages = false);
      }
    }
  }

  void _handleNewMessage(bool isOwnMessage) {
    if (!mounted) return;

    if (isOwnMessage) {
      // Always scroll to bottom for own messages
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToBottom();
      });
    } else {
      // For received messages: only auto-scroll if user is at bottom
      if (!_isUserScrolling) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _scrollToBottom();
        });
      } else {
        // User scrolled up: increment unread counter
        setState(() => _unreadCount++);
      }
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }

    setState(() {
      _unreadCount = 0;
      _isUserScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.messages.isEmpty) {
            return _buildLoadingState();
          }

          return Stack(
            children: [
              Column(
                children: [
                  if (!provider.isConnected) const ConnectionBanner(),
                  if (provider.errorMessage != null)
                    ErrorBanner(
                      error: provider.errorMessage!,
                      onDismiss: () => provider.clearError(),
                    ),
                  Expanded(child: _buildMessageList(provider)),
                  _buildQuickReplies(provider),
                  _buildMessageInput(provider),
                ],
              ),
              if (_showScrollToBottom)
                ScrollToBottomButton(
                  onTap: () => _scrollToBottom(),
                  unreadCount: _unreadCount,
                ),
              if (_isLoadingOlderMessages) const LoadingIndicator(),
            ],
          );
        },
      ),
    );
  }

  // ========================================================================
  // APP BAR
  // ========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Consumer<ChatProvider>(
        builder: (context, provider, _) => Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  provider.otherUserName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.otherUserName ?? 'Utilisateur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // MESSAGE LIST
  // ========================================================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Chargement des messages...',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
    if (provider.messages.isEmpty) {
      return const EmptyChatState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.reconnect(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        reverse: false,
        itemCount: provider.messages.length,
        itemBuilder: (context, index) {
          final message = provider.messages[index];
          final groupInfo = _chatRepository.getMessageGroupInfo(
            provider.messages,
            index,
          );

          return Column(
            children: [
              if (groupInfo.showDateSeparator)
                DateSeparator(date: message.timestamp),
              MessageBubble(
                message: message,
                isFirstInGroup: groupInfo.isFirstInGroup,
                isLastInGroup: groupInfo.isLastInGroup,
                showTimestamp: groupInfo.showTimestamp,
              ),
            ],
          );
        },
      ),
    );
  }

  // ========================================================================
  // QUICK REPLIES
  // ========================================================================

  Widget _buildQuickReplies(ChatProvider provider) {
    final suggestions = _chatRepository.getQuickReplies();

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return QuickReplyChip(
            text: suggestions[index],
            onTap: () => _sendQuickReply(provider, suggestions[index]),
          );
        },
      ),
    );
  }

  // ========================================================================
  // MESSAGE INPUT
  // ========================================================================

  Widget _buildMessageInput(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Votre message...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(ChatProvider provider) {
    final hasText = _messageController.text.trim().isNotEmpty;
    final canSend = hasText && !provider.isSending && provider.isConnected;

    return AnimatedScale(
      scale: canSend ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: canSend ? AppColors.primary : AppColors.grey300,
        shape: const CircleBorder(),
        elevation: canSend ? 2 : 0,
        child: InkWell(
          onTap: canSend ? () => _sendMessage(provider) : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: provider.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: canSend ? Colors.white : AppColors.grey400,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // ACTIONS
  // ========================================================================

  Future<void> _sendMessage(ChatProvider provider) async {
    final content = _messageController.text;
    if (content.trim().isEmpty) return;

    _messageController.clear();
    HapticFeedback.lightImpact();

    await provider.sendMessage(content);
  }

  Future<void> _sendQuickReply(ChatProvider provider, String message) async {
    HapticFeedback.lightImpact();
    await provider.sendMessage(message);
  }
}
