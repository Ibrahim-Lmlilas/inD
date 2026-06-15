// Chat Repository
//
// Handles chat data operations and business logic

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/chat/data/models/chat_models.dart';
import 'package:srrfrr_app_front/features/chat/data/services/chat_service.dart';

/// Result wrapper for repository operations
class ChatResult<T> {
  final T? data;
  final String? error;
  final bool success;

  const ChatResult._({this.data, this.error, required this.success});

  factory ChatResult.success(T data) {
    return ChatResult._(data: data, success: true);
  }

  factory ChatResult.failure(String error) {
    return ChatResult._(error: error, success: false);
  }
}

/// Messages response from API
class MessagesResponse {
  final List<Message> messages;
  final MessagePagination pagination;

  const MessagesResponse({required this.messages, required this.pagination});
}

/// Chat repository handling data operations
class ChatRepository {
  final ChatService chatService;

  ChatRepository(this.chatService);

  // ============================================================================
  // MESSAGE LOADING
  // ============================================================================

  /// Load messages for a ride with pagination
  Future<ChatResult<MessagesResponse>> loadMessages({
    required String rideId,
    required String currentUserId,
    String? otherUserName,
    int page = 0,
    int size = 20,
  }) async {
    try {
      logDebug(
        '[ChatRepository]',
        '📥 Loading messages: page $page, size $size',
      );

      final result = await chatService.getRideMessages(
        rideId,
        page: page,
        size: size,
      );

      if (result['success'] == true) {
        final messagesData = result['messages'] as List?;
        final totalPages = result['totalPages'] as int? ?? 0;
        final currentPage = result['currentPage'] as int? ?? page;

        if (messagesData != null && messagesData.isNotEmpty) {
          // Backend returns newest first, reverse for chronological order
          final messages = messagesData.reversed.map((msgData) {
            return Message.fromJson(
              msgData as Map<String, dynamic>,
              currentUserId: currentUserId,
              otherUserName: otherUserName,
            );
          }).toList();

          final pagination = MessagePagination(
            currentPage: currentPage,
            totalPages: totalPages,
            hasMoreMessages: currentPage < (totalPages - 1),
          );

          final response = MessagesResponse(
            messages: messages,
            pagination: pagination,
          );

          logSuccess(
            '[ChatRepository]',
            '✅ Loaded ${messages.length} messages (page $currentPage/$totalPages)',
          );

          return ChatResult.success(response);
        } else {
          // Empty result
          final pagination = MessagePagination(
            currentPage: currentPage,
            totalPages: totalPages,
            hasMoreMessages: false,
          );

          final response = MessagesResponse(
            messages: [],
            pagination: pagination,
          );

          logInfo('[ChatRepository]', 'No messages found');
          return ChatResult.success(response);
        }
      } else {
        final errorMsg =
            result['message'] as String? ??
            'Erreur lors du chargement des messages';
        logError('[ChatRepository]', '❌ Load failed: $errorMsg');
        return ChatResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[ChatRepository]', '❌ Exception loading messages: $e');
      logError('[ChatRepository]', 'Stack: $stackTrace');
      return ChatResult.failure('Erreur lors du chargement des messages');
    }
  }

  // ============================================================================
  // MESSAGE GROUPING
  // ============================================================================

  /// Calculate message group info for UI rendering
  MessageGroupInfo getMessageGroupInfo(List<Message> messages, int index) {
    final current = messages[index];
    final previous = index > 0 ? messages[index - 1] : null;
    final next = index < messages.length - 1 ? messages[index + 1] : null;

    // Date separator logic
    final showDateSeparator =
        previous == null || !_isSameDay(current.timestamp, previous.timestamp);

    // Message grouping (cluster messages from same sender within 2 minutes)
    final isFirstInGroup =
        previous == null ||
        previous.senderId != current.senderId ||
        current.timestamp.difference(previous.timestamp).inMinutes > 2 ||
        !_isSameDay(current.timestamp, previous.timestamp);

    final isLastInGroup =
        next == null ||
        next.senderId != current.senderId ||
        next.timestamp.difference(current.timestamp).inMinutes > 2 ||
        !_isSameDay(current.timestamp, next.timestamp);

    // Show timestamp on last message in group
    final showTimestamp = isLastInGroup;

    return MessageGroupInfo(
      showDateSeparator: showDateSeparator,
      isFirstInGroup: isFirstInGroup,
      isLastInGroup: isLastInGroup,
      showTimestamp: showTimestamp,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ============================================================================
  // QUICK REPLIES
  // ============================================================================

  /// Get suggested quick reply messages
  List<String> getQuickReplies() {
    return [
      'Je suis en route',
      'J\'arrive dans 5 minutes',
      'Où êtes-vous ?',
      'Merci',
      'Je suis là',
    ];
  }

  // ============================================================================
  // DATE FORMATTING
  // ============================================================================

  /// Format date for separator display
  String formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
