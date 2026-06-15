// Enhanced Chat Provider with Client-Side Message ID Tracking
library;

import 'dart:async';
import 'package:srrfrr_app_front/features/chat/data/models/message_status.dart';
import 'package:srrfrr_app_front/features/chat/data/services/chat_ws_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import '../../data/models/message.dart';
import '../../../../core/utils/log_utils.dart';

class ChatProvider extends DisposableProvider {
  // =========================================================================
  // Dependencies
  // =========================================================================

  final ChatWebSocketService _wsService = ChatWebSocketService();

  // =========================================================================
  // State Variables
  // =========================================================================

  List<Message> _messages = [];

  // Track messages by BOTH client ID and server ID
  final Map<String, Message> _messagesByClientId = {};
  final Set<String> _processedServerIds = {};

  String? _chatId;
  String? _rideId;
  String? _channelId;
  String? _wsToken;
  String? _currentUserId;
  String? _otherUserId;
  String? _otherUserName;

  bool _isLoading = false;
  bool _isSending = false;
  bool _isConnected = false;

  String? _errorMessage;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;

  // Callback for UI to handle new messages
  void Function(bool isOwnMessage)? onNewMessageReceived;

  // =========================================================================
  // Public Getters
  // =========================================================================

  List<Message> get messages => _messages;
  String? get chatId => _chatId;
  String? get channelId => _channelId;
  String? get otherUserName => _otherUserName;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  String? get wsToken => _wsToken;

  // =========================================================================
  // Message Management Methods
  // =========================================================================

  void setMessages(List<Message> messages) {
    _messages = messages;

    _processedServerIds.clear();
    for (final msg in messages) {
      _processedServerIds.add(msg.id);
    }

    safeNotify();
    logSuccess('ChatProvider', 'Set ${messages.length} messages');
  }

  void prependMessages(List<Message> oldMessages) {
    final newMessages = <Message>[];

    for (final msg in oldMessages) {
      if (_processedServerIds.add(msg.id)) {
        newMessages.add(msg);
      }
    }

    if (newMessages.isNotEmpty) {
      _messages.insertAll(0, newMessages);
      safeNotify();
      logSuccess(
        'ChatProvider',
        'Prepended ${newMessages.length} older messages',
      );
    }
  }

  void appendMessage(Message message) {
    // Check if already exists by server ID
    if (_processedServerIds.contains(message.id)) {
      logDebug(
        'ChatProvider',
        'Duplicate message ignored (server ID): ${message.id}',
      );
      return;
    }

    _processedServerIds.add(message.id);
    _messages.add(message);
    safeNotify();

    onNewMessageReceived?.call(message.isSentByMe);

    logSuccess('ChatProvider', 'Appended message: ${message.id}');
  }

  void updateMessage(String clientOrServerId, Message updatedMessage) {
    // Try to find by client ID first (for pending messages)
    final clientIndex = _messages.indexWhere(
      (m) => m.clientMessageId == clientOrServerId,
    );

    if (clientIndex != -1) {
      _messages[clientIndex] = updatedMessage;
      _processedServerIds.add(updatedMessage.id);
      safeNotify();
      logSuccess(
        'ChatProvider',
        'Updated message by client ID: $clientOrServerId -> ${updatedMessage.id}',
      );
      return;
    }

    // Fallback to server ID
    final serverIndex = _messages.indexWhere((m) => m.id == clientOrServerId);
    if (serverIndex != -1) {
      _messages[serverIndex] = updatedMessage;
      safeNotify();
      logSuccess(
        'ChatProvider',
        'Updated message by server ID: $clientOrServerId',
      );
    }
  }

  // =========================================================================
  // Initialization
  // =========================================================================

  Future<void> initializeChat({
    required String chatId,
    required String rideId,
    required String channelId,
    required String wsToken,
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
  }) async {
    logInfo('ChatProvider', 'Initializing chat for ride: $rideId');

    _chatId = chatId;
    _rideId = rideId;
    _channelId = channelId;
    _wsToken = wsToken;
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;
    _otherUserName = otherUserName;

    _processedServerIds.clear();
    _messagesByClientId.clear();
    _messages.clear();

    _listenToWebSocket();
    await _connectWebSocket();
  }

  Future<void> reconnect() async {
    if (_rideId == null || _wsToken == null) {
      logError('ChatProvider', 'Cannot reconnect: missing session data');
      return;
    }

    logInfo('ChatProvider', 'Reconnecting chat...');

    if (!_isConnected) {
      await _connectWebSocket();
    }
  }

  // =========================================================================
  // WebSocket Connection Management
  // =========================================================================

  Future<void> _connectWebSocket() async {
    if (_currentUserId == null || _channelId == null || _wsToken == null) {
      _setError('Missing connection parameters');
      return;
    }

    if (_isConnected) {
      logInfo('ChatProvider', 'Already connected');
      return;
    }

    _isLoading = true;
    safeNotify();

    try {
      await _wsService.connect(token: _wsToken!);
      logSuccess('ChatProvider', 'WebSocket connection initiated');
    } catch (e) {
      logError('ChatProvider', 'Connection failed: $e');
      _setError('Connection failed. Retrying...');
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  void _listenToWebSocket() {
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();

    logInfo('ChatProvider', 'Setting up WebSocket listeners');

    _statusSubscription = _wsService.statusStream.listen(
      _handleStatusChange,
      onError: (e) => logError('ChatProvider', 'Status error: $e'),
      cancelOnError: false,
    );

    _messageSubscription = _wsService.messages.listen(
      _handleWebSocketMessage,
      onError: (e) => logError('ChatProvider', 'Message error: $e'),
      cancelOnError: false,
    );

    logSuccess('ChatProvider', 'Listeners attached');
  }

  void _handleStatusChange(ChatWsStatus status) {
    logInfo('ChatProvider', 'Status: ${status.name}');

    final wasConnected = _isConnected;
    _isConnected = status == ChatWsStatus.connected;

    switch (status) {
      case ChatWsStatus.error:
        _setError('Connection lost');
        break;
      case ChatWsStatus.connected:
        _clearError();
        logSuccess('ChatProvider', 'Connected');
        break;
      case ChatWsStatus.connecting:
        _clearError();
        break;
      case ChatWsStatus.disconnected:
        break;
    }

    if (wasConnected != _isConnected) {
      safeNotify();
    }
  }

  // =========================================================================
  // Message Handling
  // =========================================================================

  void _handleWebSocketMessage(ChatWsMessage wsMessage) {
    logInfo('ChatProvider', 'Received: ${wsMessage.type.name}');

    try {
      switch (wsMessage.type) {
        case ChatMessageType.newMessage:
          _handleNewMessage(wsMessage.data);
          break;
        case ChatMessageType.messageSent:
          _handleMessageSent(wsMessage.data);
          break;
        case ChatMessageType.messageDelivered:
          _handleMessageDelivered(wsMessage.data);
          break;
        case ChatMessageType.error:
          _handleError(wsMessage.data);
          break;
        default:
          logWarning('ChatProvider', 'Unhandled type: ${wsMessage.type}');
      }
    } catch (e, stackTrace) {
      logError('ChatProvider', 'Error handling message: $e');
      logError('ChatProvider', 'Stack trace: $stackTrace');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      logInfo('ChatProvider', 'New message data: $data');

      final messageId = data['messageId'] as String?;

      if (messageId == null) {
        logError('ChatProvider', 'Received message without messageId');
        return;
      }

      // Check if already processed by server ID
      if (_processedServerIds.contains(messageId)) {
        logWarning('ChatProvider', 'Duplicate message ignored: $messageId');
        return;
      }

      final senderId = data['senderId'] as String?;
      final content = data['content'] as String?;
      final sentAt = data['sentAt'] as String?;

      if (senderId == null || content == null || sentAt == null) {
        logError('ChatProvider', 'Message missing required fields');
        return;
      }

      final isSentByMe = senderId == _currentUserId;

      final message = Message(
        id: messageId,
        senderId: senderId,
        senderName: isSentByMe ? 'Moi' : _otherUserName ?? 'User',
        content: content,
        timestamp: DateTime.parse(sentAt),
        isRead: false,
        isSentByMe: isSentByMe,
        status: MessageStatus.delivered,
        messageType: data['messageType'] as String? ?? 'TEXT',
        fileUrl: data['fileUrl'] as String?,
        fileSize: data['fileSize'] as int?,
      );

      appendMessage(message);
      logSuccess(
        'ChatProvider',
        'New message from ${isSentByMe ? "self" : "other"}',
      );
    } catch (e, stackTrace) {
      logError('ChatProvider', 'Error handling new message: $e');
      logError('ChatProvider', 'Stack trace: $stackTrace');
    }
  }

  void _handleMessageSent(Map<String, dynamic> data) {
    try {
      final serverMessageId = data['messageId'] as String?;

      if (serverMessageId == null) {
        logError('ChatProvider', 'Message sent confirmation without messageId');
        return;
      }

      // Find the temporary "sending" message
      final tempIndex = _messages.indexWhere(
        (m) => m.status == MessageStatus.sending,
      );

      if (tempIndex != -1) {
        final tempMessage = _messages[tempIndex];

        // Update with real server ID and sent status
        _messages[tempIndex] = tempMessage.copyWith(
          id: serverMessageId,
          status: MessageStatus.sent,
        );

        _processedServerIds.add(serverMessageId);
        safeNotify();
        logSuccess('ChatProvider', 'Message confirmed sent: $serverMessageId');
      } else {
        logWarning(
          'ChatProvider',
          'No pending message found for confirmation: $serverMessageId',
        );
      }
    } catch (e, stackTrace) {
      logError('ChatProvider', 'Error handling sent confirmation: $e');
      logError('ChatProvider', 'Stack trace: $stackTrace');
    }
  }

  void _handleMessageDelivered(Map<String, dynamic> data) {
    try {
      final messageId = data['messageId'] as String?;
      if (messageId == null) return;

      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          status: MessageStatus.delivered,
        );
        safeNotify();
        logSuccess('ChatProvider', 'Message delivered: $messageId');
      }
    } catch (e) {
      logError('ChatProvider', 'Error handling delivered notification: $e');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    try {
      final errorMsg = data['message'] as String? ?? 'Unknown error';

      if (errorMsg.contains('expired') || errorMsg.contains('Invalid')) {
        logError('ChatProvider', 'Auth error: $errorMsg');
        _wsService.disconnect();
        _setError('Session expirée');
      } else {
        _setError(errorMsg);
      }
    } catch (e) {
      logError('ChatProvider', 'Error handling error: $e');
      _setError('An unexpected error occurred');
    }
  }

  // =========================================================================
  // Message Sending
  // =========================================================================

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty || !_isConnected) {
      return false;
    }

    if (_currentUserId == null || _otherUserId == null) {
      _setError('Missing user information');
      return false;
    }

    _isSending = true;
    safeNotify();

    try {
      // Send via WebSocket (returns client message ID)
      final clientMessageId = _wsService.sendTextMessage(
        senderId: _currentUserId!,
        receiverId: _otherUserId!,
        content: content.trim(),
      );

      // Create temporary message with client ID
      final tempMessage = Message(
        id: clientMessageId, // Use client ID temporarily
        clientMessageId: clientMessageId,
        senderId: _currentUserId!,
        senderName: 'Moi',
        content: content.trim(),
        timestamp: DateTime.now(),
        isRead: false,
        isSentByMe: true,
        status: MessageStatus.sending,
        messageType: 'TEXT',
      );

      // Add to messages immediately for instant feedback
      _messages.add(tempMessage);
      _messagesByClientId[clientMessageId] = tempMessage;

      _isSending = false;
      safeNotify();

      logSuccess(
        'ChatProvider',
        'Message sent with client ID: $clientMessageId',
      );
      return true;
    } catch (e) {
      logError('ChatProvider', 'Error sending message: $e');
      _setError('Failed to send message');
      _isSending = false;
      safeNotify();
      return false;
    }
  }

  // =========================================================================
  // Quick Replies
  // =========================================================================

  List<String> getSuggestedMessages() {
    return [
      'Je suis en route',
      'J\'arrive dans 5 minutes',
      'Où êtes-vous ?',
      'Merci',
      'Je suis là',
    ];
  }

  // =========================================================================
  // Error Management
  // =========================================================================

  void _setError(String message) {
    _errorMessage = message;
    logError('ChatProvider', message);
    safeNotify();
  }

  void clearError() {
    _errorMessage = null;
    safeNotify();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      safeNotify();
    }
  }

  // =========================================================================
  // Cleanup
  // =========================================================================

  Future<void> clearCurrentChannelCache() async {
    if (_channelId == null) return;

    try {
      _messages.clear();
      _messagesByClientId.clear();

      if (_processedServerIds.length > 1000) {
        _processedServerIds.clear();
      }

      logSuccess('ChatProvider', 'Cache cleared');
      safeNotify();
    } catch (e) {
      logError('ChatProvider', 'Error clearing cache: $e');
    }
  }

  @override
  void dispose() {
    logInfo('ChatProvider', 'Disposing ChatProvider');

    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _wsService.disconnect();
    _processedServerIds.clear();
    _messagesByClientId.clear();

    super.dispose();

    logSuccess('ChatProvider', 'ChatProvider disposed');
  }
}
