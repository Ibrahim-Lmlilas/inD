// Notification Service - Real-time Notification Management
//
// Handles FCM topics, WebSocket notifications, and notification display

library;

import 'dart:async';
import 'dart:convert';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srrfrr_app_front/core/services/fcm_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FCMService _fcmService = FCMService();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  final StreamController<AppNotification> _notificationController =
      StreamController<AppNotification>.broadcast();

  String? _currentUserId;
  bool _isConnected = false;

  // ============================================================================
  // PUBLIC GETTERS
  // ============================================================================

  Stream<AppNotification> get notifications => _notificationController.stream;
  bool get isConnected => _isConnected;

  // ============================================================================
  // INITIALIZATION & CONNECTION
  // ============================================================================

  // Initialize notification service for a user
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _isConnected) {
      logDebug('[NotificationService]', 'Already connected for user: $userId');
      return;
    }

    try {
      _currentUserId = userId;
      await _connectWebSocket(userId);
      logSuccess('[NotificationService]', 'Initialized for user: $userId');
    } catch (e) {
      logError('[NotificationService]', 'Initialization failed: $e');
    }
  }

  // Connect to WebSocket for real-time notifications
  Future<void> _connectWebSocket(String userId) async {
    try {
      // Disconnect existing connection
      await _disconnectWebSocket();

      final apiUrl = dotenv.env['API_BASE_URL'];
      final uri = Uri.parse(apiUrl!);
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';

      // Backend endpoint: /notifications/{notificationsId}
      final wsUrl =
          '$wsScheme://${uri.host}:${uri.port}${uri.path}/notifications/$userId';

      logInfo('[NotificationService]', 'Connecting to: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _isConnected = true;
      logSuccess('[NotificationService]', 'WebSocket connected');

      _listenToNotifications();
    } catch (e) {
      _isConnected = false;
      logError('[NotificationService]', 'WebSocket connection failed: $e');
    }
  }

  // Listen to incoming notifications
  void _listenToNotifications() {
    _wsSubscription?.cancel();

    _wsSubscription = _channel!.stream.listen(
      (data) {
        try {
          logDebug('[NotificationService]', 'Raw notification: $data');

          final json = jsonDecode(data) as Map<String, dynamic>;
          final notification = AppNotification.fromJson(json);

          // Only process and display UNREAD notifications
          if (notification.isUnread) {
            logInfo(
              '[NotificationService]',
              'Notification received (UNREAD): ${notification.type.value} '
                  '(category: ${notification.category})',
            );

            _notificationController.add(notification);
          } else {
            logDebug(
              '[NotificationService]',
              'Skipping READ notification: ${notification.type.value}',
            );
          }
        } catch (e) {
          logError('[NotificationService]', 'Error parsing notification: $e');
        }
      },
      onError: (error) {
        logError('[NotificationService]', 'WebSocket error: $error');
        _isConnected = false;
        _attemptReconnect();
      },
      onDone: () {
        logWarning('[NotificationService]', 'WebSocket connection closed');
        _isConnected = false;
        _attemptReconnect();
      },
    );
  }

  // Attempt to reconnect WebSocket
  Future<void> _attemptReconnect() async {
    if (_currentUserId != null) {
      await Future.delayed(const Duration(seconds: 3));
      logInfo('[NotificationService]', 'Attempting to reconnect...');
      await _connectWebSocket(_currentUserId!);
    }
  }

  // Disconnect WebSocket
  Future<void> _disconnectWebSocket() async {
    _wsSubscription?.cancel();
    _wsSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    _isConnected = false;
  }

  // ============================================================================
  // FCM TOPIC MANAGEMENT
  // ============================================================================

  // Subscribe to passenger topics
  Future<void> subscribeToPassengerTopics() async {
    try {
      logDebug('[NotificationService]', 'Subscribing to passenger topics...');

      await _fcmService.subscribeToTopic('passengers');
      await _fcmService.subscribeToTopic('passenger_notifications');

      logSuccess('[NotificationService]', 'Subscribed to passenger topics');
    } catch (e) {
      logError(
        '[NotificationService]',
        'Failed to subscribe to passenger topics: $e',
      );
    }
  }

  // Subscribe to driver topics
  Future<void> subscribeToDriverTopics() async {
    try {
      logDebug('[NotificationService]', 'Subscribing to driver topics...');

      await _fcmService.subscribeToTopic('drivers');
      await _fcmService.subscribeToTopic('driver_notifications');

      logSuccess('[NotificationService]', 'Subscribed to driver topics');
    } catch (e) {
      logError(
        '[NotificationService]',
        'Failed to subscribe to driver topics: $e',
      );
    }
  }

  // Unsubscribe from passenger topics
  Future<void> unsubscribeFromPassengerTopics() async {
    try {
      logDebug(
        '[NotificationService]',
        'Unsubscribing from passenger topics...',
      );

      await _fcmService.unsubscribeFromTopic('passengers');
      await _fcmService.unsubscribeFromTopic('passenger_notifications');

      logSuccess('[NotificationService]', 'Unsubscribed from passenger topics');
    } catch (e) {
      logError(
        '[NotificationService]',
        'Failed to unsubscribe from passenger topics: $e',
      );
    }
  }

  // Unsubscribe from driver topics
  Future<void> unsubscribeFromDriverTopics() async {
    try {
      logDebug('[NotificationService]', 'Unsubscribing from driver topics...');

      await _fcmService.unsubscribeFromTopic('drivers');
      await _fcmService.unsubscribeFromTopic('driver_notifications');

      logSuccess('[NotificationService]', 'Unsubscribed from driver topics');
    } catch (e) {
      logError(
        '[NotificationService]',
        'Failed to unsubscribe from driver topics: $e',
      );
    }
  }

  // Switch mode (unsubscribe from old, subscribe to new)
  Future<void> switchMode({required bool isPassengerMode}) async {
    if (isPassengerMode) {
      await unsubscribeFromDriverTopics();
      await subscribeToPassengerTopics();
    } else {
      await unsubscribeFromPassengerTopics();
      await subscribeToDriverTopics();
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  // Disconnect and cleanup
  Future<void> disconnect() async {
    logInfo('[NotificationService]', 'Disconnecting notification service');

    await _disconnectWebSocket();
    await unsubscribeFromPassengerTopics();
    await unsubscribeFromDriverTopics();

    _currentUserId = null;
  }

  // Dispose all resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
