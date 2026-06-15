/// Notifications Repository
///
/// Handles all notification data operations with clean architecture principles.
/// Provides a clean API abstraction over the notification service layer.
///
/// Responsibilities
/// - Load notifications with pagination
/// - Mark notifications as read
/// - Calculate notification statistics
/// - Handle error states gracefully

library;

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/features/notifications/data/services/notification_api_service.dart';

// ============================================================================
// RESULT TYPES
// ============================================================================

/// Generic result wrapper for repository operations
sealed class NotificationResult<T> {
  const NotificationResult();
}

/// Successful operation result
final class NotificationSuccess<T> extends NotificationResult<T> {
  final T data;
  const NotificationSuccess(this.data);
}

/// Failed operation result
final class NotificationFailure<T> extends NotificationResult<T> {
  final String message;
  const NotificationFailure(this.message);
}

// ============================================================================
// DATA TRANSFER OBJECTS
// ============================================================================

/// Pagination information for notification lists
class NotificationPagination {
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool hasNext;

  const NotificationPagination({
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.hasNext,
  });

  factory NotificationPagination.empty() {
    return const NotificationPagination(
      totalPages: 0,
      totalElements: 0,
      currentPage: 0,
      hasNext: false,
    );
  }

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationPagination('
        'page: $currentPage/$totalPages, '
        'total: $totalElements, '
        'hasNext: $hasNext'
        ')';
  }
}

/// Response containing notifications and pagination metadata
class NotificationsResponse {
  final List<AppNotification> notifications;
  final NotificationPagination pagination;

  const NotificationsResponse({
    required this.notifications,
    required this.pagination,
  });

  /// Number of unread notifications in the response
  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  String toString() {
    return 'NotificationsResponse('
        '${notifications.length} notifications, '
        '$unreadCount unread, '
        '$pagination'
        ')';
  }
}

// ============================================================================
// REPOSITORY
// ============================================================================

/// Repository for notification data operations
///
/// Provides a clean interface for notification management, abstracting
/// away API implementation details and handling error cases gracefully.
class NotificationsRepository {
  final NotificationApiService _apiService;

  NotificationsRepository(this._apiService);

  // ==========================================================================
  // LOAD NOTIFICATIONS
  // ==========================================================================

  /// Load passenger notifications with pagination
  ///
  /// **Parameters:**
  /// - [page]: Page number (0-indexed)
  /// - [size]: Number of items per page
  ///
  /// **Returns:** [NotificationResult] with notifications and pagination info
  Future<NotificationResult<NotificationsResponse>> loadPassengerNotifications({
    int page = 0,
    int size = 20,
  }) async {
    return _loadNotifications(
      loadFn: () =>
          _apiService.getPassengerNotifications(page: page, size: size),
      userType: 'passenger',
      page: page,
    );
  }

  /// Load driver notifications with pagination
  ///
  /// **Parameters:**
  /// - [page]: Page number (0-indexed)
  /// - [size]: Number of items per page
  ///
  /// **Returns:** [NotificationResult] with notifications and pagination info
  Future<NotificationResult<NotificationsResponse>> loadDriverNotifications({
    int page = 0,
    int size = 20,
  }) async {
    return _loadNotifications(
      loadFn: () => _apiService.getDriverNotifications(page: page, size: size),
      userType: 'driver',
      page: page,
    );
  }

  /// Internal method to load notifications with error handling
  Future<NotificationResult<NotificationsResponse>> _loadNotifications({
    required Future<Map<String, dynamic>> Function() loadFn,
    required String userType,
    required int page,
  }) async {
    try {
      logDebug(
        '[NotificationsRepository]',
        '📥 Loading $userType notifications: page $page',
      );

      final response = await loadFn();

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final notificationList = data['notifications'] as List<dynamic>;
        final paginationData = data['pagination'] as Map<String, dynamic>?;

        // Parse notifications
        final notifications = notificationList
            .map(
              (json) => AppNotification.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Parse pagination
        final pagination = paginationData != null
            ? NotificationPagination.fromJson(paginationData)
            : NotificationPagination(
                totalPages: 1,
                totalElements: notifications.length,
                currentPage: page,
                hasNext: false,
              );

        final result = NotificationsResponse(
          notifications: notifications,
          pagination: pagination,
        );

        logSuccess(
          '[NotificationsRepository]',
          '✅ Loaded ${notifications.length} notifications '
              '(${result.unreadCount} unread, page ${pagination.currentPage}/${pagination.totalPages})',
        );

        return NotificationSuccess(result);
      } else {
        final errorMsg =
            response['message'] as String? ?? 'Erreur de chargement';
        logError('[NotificationsRepository]', '❌ Load failed: $errorMsg');
        return NotificationFailure(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[NotificationsRepository]', '❌ Load $userType failed: $e');
      logError('[NotificationsRepository]', 'Stack: $stackTrace');
      return const NotificationFailure(
        'Erreur de chargement des notifications',
      );
    }
  }

  // ==========================================================================
  // MARK AS READ
  // ==========================================================================

  /// Mark a single notification as read
  ///
  /// **Parameters:**
  /// - [notificationId]: ID of the notification to mark as read
  ///
  /// **Returns:** [NotificationResult] indicating success or failure
  Future<NotificationResult<void>> markAsRead(String notificationId) async {
    try {
      logDebug(
        '[NotificationsRepository]',
        '📖 Marking as read: $notificationId',
      );

      final response = await _apiService.markNotificationAsRead(
        notificationId: notificationId,
      );

      if (response['success'] == true) {
        logSuccess('[NotificationsRepository]', '✅ Marked as read');
        return const NotificationSuccess(null);
      } else {
        final errorMsg = response['message'] as String? ?? 'Erreur';
        logError(
          '[NotificationsRepository]',
          '❌ Mark as read failed: $errorMsg',
        );
        return NotificationFailure(errorMsg);
      }
    } catch (e) {
      logError('[NotificationsRepository]', '❌ Mark as read exception: $e');
      return const NotificationFailure('Erreur lors du marquage');
    }
  }

  /// Mark all notifications as read
  ///
  /// **Returns:** [NotificationResult] indicating success or failure
  Future<NotificationResult<void>> markAllAsRead() async {
    try {
      logDebug('[NotificationsRepository]', '📖 Marking all as read');

      final response = await _apiService.markAllNotificationsAsRead();

      if (response['success'] == true) {
        logSuccess('[NotificationsRepository]', '✅ All marked as read');
        return const NotificationSuccess(null);
      } else {
        final errorMsg = response['message'] as String? ?? 'Erreur';
        logError('[NotificationsRepository]', '❌ Mark all failed: $errorMsg');
        return NotificationFailure(errorMsg);
      }
    } catch (e) {
      logError('[NotificationsRepository]', '❌ Mark all exception: $e');
      return const NotificationFailure('Erreur lors du marquage');
    }
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Calculate unread count from notification list
  int calculateUnreadCount(List<AppNotification> notifications) {
    return notifications.where((n) => n.isUnread).length;
  }

  /// Filter notifications by read status
  List<AppNotification> filterByReadStatus(
    List<AppNotification> notifications, {
    required bool unreadOnly,
  }) {
    if (!unreadOnly) return notifications;
    return notifications.where((n) => n.isUnread).toList();
  }

  /// Sort notifications by creation date (newest first)
  List<AppNotification> sortByDate(
    List<AppNotification> notifications, {
    bool descending = true,
  }) {
    final sorted = List<AppNotification>.from(notifications);
    sorted.sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }
}