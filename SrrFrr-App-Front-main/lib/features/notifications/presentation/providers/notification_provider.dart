/// Notification Provider
///
/// Manages notification state and coordinates between repository and UI.
/// Handles real-time WebSocket notifications and FCM integration.
///
/// Responsibilities
/// - Manage notification list state
/// - Handle pagination
/// - Coordinate WebSocket real-time updates
/// - Manage read/unread status
/// - Switch between passenger/driver modes
///
/// Usage
/// The provider uses lazy initialization of the repository to avoid
/// dependency injection issues with ChangeNotifierProxyProvider.

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/features/notifications/data/repositories/notifications_repository.dart';
import 'package:srrfrr_app_front/features/notifications/data/services/notification_api_service.dart';
import 'package:srrfrr_app_front/features/notifications/data/services/notification_service.dart';

/// Provider for managing notification state and operations
class NotificationProvider extends ChangeNotifier {
  // Lazy initialization of dependencies
  NotificationsRepository? _repository;
  final NotificationService _notificationService = NotificationService();

  /// Get or create repository instance (lazy initialization)
  NotificationsRepository get _repo {
    _repository ??= NotificationsRepository(
      NotificationApiService(ApiInterceptor()),
    );
    return _repository!;
  }

  NotificationProvider();

  // ==========================================================================
  // STATE
  // ==========================================================================

  final List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AppNotification>? _notificationSubscription;

  // Pagination state
  int _totalPages = 0;
  int _totalElements = 0;
  int _currentPage = 0;
  bool _hasMore = true;

  // Unread count
  int _unreadCount = 0;

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _notificationService.isConnected;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initialize notification provider for authenticated user
  ///
  /// Parameters:
  /// - [userId]: User ID for WebSocket connection
  /// - [isDriverMode]: Whether user is in driver mode
  Future<void> initialize(String userId, bool isDriverMode) async {
    try {
      logDebug('[NotificationProvider]', '🚀 Initializing...');

      // Connect to WebSocket for real-time notifications
      await _notificationService.initialize(userId);

      // Subscribe to FCM topics based on mode
      if (isDriverMode) {
        await _notificationService.subscribeToDriverTopics();
      } else {
        await _notificationService.subscribeToPassengerTopics();
      }

      // Listen to real-time notifications
      _startListeningToNotifications();

      // Load notification history from backend
      await loadNotificationHistory(isDriverMode, page: 0, size: 20);

      logSuccess('[NotificationProvider]', '✅ Initialized successfully');
    } catch (e) {
      _setError('Erreur d\'initialisation des notifications');
      logError('[NotificationProvider]', '❌ Initialization failed: $e');
    }
  }

  /// Start listening to real-time WebSocket notifications
  void _startListeningToNotifications() {
    _notificationSubscription?.cancel();

    _notificationSubscription = _notificationService.notifications.listen(
      (notification) {
        logInfo(
          '[NotificationProvider]',
          '🔔 New notification: ${notification.type.value} '
              '(category: ${notification.category})',
        );

        // Add to beginning of list (most recent first)
        _notifications.insert(0, notification);
        _unreadCount++;
        _totalElements++;

        notifyListeners();
      },
      onError: (error) {
        logError('[NotificationProvider]', '❌ Stream error: $error');
      },
    );
  }

  // ==========================================================================
  // LOAD NOTIFICATIONS
  // ==========================================================================

  /// Load notification history with pagination
  ///
  /// Parameters:
  /// - [isDriverMode]: Whether to load driver or passenger notifications
  /// - [page]: Page number (0-indexed)
  /// - [size]: Number of items per page
  Future<void> loadNotificationHistory(
    bool isDriverMode, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      _setLoading(true);
      _currentPage = page;

      final result = isDriverMode
          ? await _repo.loadDriverNotifications(page: page, size: size)
          : await _repo.loadPassengerNotifications(page: page, size: size);

      switch (result) {
        case NotificationSuccess(:final data):
          _notifications.clear();
          _notifications.addAll(data.notifications);

          _totalPages = data.pagination.totalPages;
          _totalElements = data.pagination.totalElements;
          _currentPage = data.pagination.currentPage;
          _hasMore = data.pagination.hasNext;
          _unreadCount = data.unreadCount;

          _clearError();
          logSuccess(
            '[NotificationProvider]',
            '✅ Loaded ${_notifications.length} notifications '
                '(page $_currentPage/$_totalPages, $_unreadCount unread)',
          );

        case NotificationFailure(:final message):
          _setError(message);
      }

      _setLoading(false);
    } catch (e) {
      _setError('Erreur de chargement des notifications');
      logError('[NotificationProvider]', '❌ Load history failed: $e');
      _setLoading(false);
    }
  }

  /// Load more notifications (pagination - append to existing list)
  ///
  /// Parameters:
  /// - [isDriverMode]: Whether to load driver or passenger notifications
  /// - [page]: Page number (0-indexed)
  /// - [size]: Number of items per page
  Future<void> loadMoreNotifications(
    bool isDriverMode, {
    required int page,
    int size = 20,
  }) async {
    // Don't load if already at the end
    if (!_hasMore || page >= _totalPages) {
      logDebug('[NotificationProvider]', 'No more notifications to load');
      return;
    }

    try {
      _currentPage = page;

      final result = isDriverMode
          ? await _repo.loadDriverNotifications(page: page, size: size)
          : await _repo.loadPassengerNotifications(page: page, size: size);

      switch (result) {
        case NotificationSuccess(:final data):
          _notifications.addAll(data.notifications);

          _totalPages = data.pagination.totalPages;
          _totalElements = data.pagination.totalElements;
          _currentPage = data.pagination.currentPage;
          _hasMore = data.pagination.hasNext;
          _unreadCount = _repo.calculateUnreadCount(_notifications);

          logSuccess(
            '[NotificationProvider]',
            '✅ Loaded ${data.notifications.length} more notifications '
                '(page $_currentPage/$_totalPages, total: ${_notifications.length})',
          );

          notifyListeners();

        case NotificationFailure(:final message):
          logError('[NotificationProvider]', '❌ Load more failed: $message');
      }
    } catch (e) {
      logError('[NotificationProvider]', '❌ Load more failed: $e');
    }
  }

  /// Refresh notifications (reload from first page)
  Future<void> refreshNotifications(bool isDriverMode) async {
    await loadNotificationHistory(isDriverMode, page: 0, size: 20);
  }

  // ==========================================================================
  // NOTIFICATION ACTIONS
  // ==========================================================================

  /// Mark notification as read
  ///
  /// Parameters:
  /// - [notificationId]: ID of the notification to mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);

      if (index == -1) {
        logWarning(
          '[NotificationProvider]',
          'Notification not found: $notificationId',
        );
        return;
      }

      // Only proceed if notification is unread
      if (!_notifications[index].isUnread) {
        logDebug('[NotificationProvider]', 'Notification already read');
        return;
      }

      // Call repository
      final result = await _repo.markAsRead(notificationId);

      switch (result) {
        case NotificationSuccess():
          // Update locally after successful operation
          _notifications[index] = _notifications[index].copyWith(
            status: 'READ',
          );
          _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
          notifyListeners();
          logSuccess('[NotificationProvider]', '✅ Notification marked as read');

        case NotificationFailure(:final message):
          logError(
            '[NotificationProvider]',
            '❌ Failed to mark as read: $message',
          );
          throw Exception(message);
      }
    } catch (e) {
      logError('[NotificationProvider]', '❌ Mark as read failed: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Only proceed if there are unread notifications
      if (_unreadCount == 0) {
        logDebug('[NotificationProvider]', 'No unread notifications');
        return;
      }

      // Call repository
      final result = await _repo.markAllAsRead();

      switch (result) {
        case NotificationSuccess():
          // Update all notifications locally
          for (var i = 0; i < _notifications.length; i++) {
            if (_notifications[i].isUnread) {
              _notifications[i] = _notifications[i].copyWith(status: 'READ');
            }
          }

          _unreadCount = 0;
          notifyListeners();
          logSuccess(
            '[NotificationProvider]',
            '✅ All notifications marked as read',
          );

        case NotificationFailure(:final message):
          logError(
            '[NotificationProvider]',
            '❌ Failed to mark all as read: $message',
          );
          throw Exception(message);
      }
    } catch (e) {
      logError('[NotificationProvider]', '❌ Mark all as read failed: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // MODE SWITCHING
  // ==========================================================================

  /// Switch between passenger and driver mode
  Future<void> switchMode(bool isDriverMode) async {
    try {
      logDebug(
        '[NotificationProvider]',
        '🔄 Switching to ${isDriverMode ? "driver" : "passenger"} mode',
      );

      // Switch FCM topics
      await _notificationService.switchMode(isPassengerMode: !isDriverMode);

      // Reload notifications for new mode
      await loadNotificationHistory(isDriverMode, page: 0, size: 20);

      logSuccess('[NotificationProvider]', '✅ Mode switched');
    } catch (e) {
      logError('[NotificationProvider]', '❌ Mode switch failed: $e');
    }
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  /// Disconnect and cleanup all resources
  Future<void> disconnect() async {
    try {
      logDebug('[NotificationProvider]', '👋 Disconnecting...');

      await _notificationSubscription?.cancel();
      _notificationSubscription = null;

      await _notificationService.disconnect();

      _notifications.clear();
      _unreadCount = 0;
      _totalPages = 0;
      _totalElements = 0;
      _hasMore = true;
      _currentPage = 0;

      notifyListeners();
      logSuccess('[NotificationProvider]', '✅ Disconnected');
    } catch (e) {
      logError('[NotificationProvider]', '❌ Disconnect failed: $e');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Reset pagination state (useful for filters or mode changes)
  void resetPagination() {
    _currentPage = 0;
    _totalPages = 0;
    _totalElements = 0;
    _hasMore = true;
    _notifications.clear();
    notifyListeners();
  }
}