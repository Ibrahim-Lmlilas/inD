import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import '../../config/firebase_options.dart';

// top-level function for background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logDebug(
    '[FCM Background]',
    '📨 Background message: ${message.notification?.title}',
  );

  // Don't show notification if already read
  final status = message.data['status'] as String?;
  if (status != null && status.toUpperCase() == 'READ') {
    logDebug('[FCM Background]', '⏭️ Skipping notification (already READ)');
    return;
  }
}

class FCMService {
  // Singleton instance
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important ride notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  // Callbacks for token refresh and message handling
  Function(String)? onTokenRefresh;
  Function(RemoteMessage)? onMessageReceived;

  // Initialize FCM with all configurations
  Future<void> initialize() async {
    // Skip Firebase Messaging on web platform
    if (kIsWeb) {
      logWarning(
        '[FCMService]',
        '⚠️ Firebase Messaging is not supported on web',
      );
      return;
    }

    try {
      logDebug('[FCMService]', '🚀 Initializing FCM...');

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      logSuccess('[FCMService]', '✅ Firebase initialized');

      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      logSuccess('[FCMService]', '✅ Background handler registered');

      // Initialize Firebase Messaging instance
      _messaging = FirebaseMessaging.instance;

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications & create Android channel
      await _initializeLocalNotifications();

      // Create notification channel for Android
      await _createNotificationChannel();

      // Get FCM token
      await _getFcmToken();

      // Set up message handlers
      _setupMessageHandlers();

      logSuccess('[FCMService]', '✅ FCM initialized successfully');
    } catch (e) {
      logError('[FCMService]', '❌ FCM initialization failed: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (_messaging == null) return;

    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      logDebug(
        '[FCMService]',
        '📢 Notification permission: ${settings.authorizationStatus}',
      );
    } catch (e) {
      logError('[FCMService]', '❌ Error requesting permissions: $e');
    }
  }

  // Create Android notification channel
  Future<void> _createNotificationChannel() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      logSuccess('[FCMService]', '✅ Android notification channel created');
    } catch (e) {
      logError('[FCMService]', '❌ Error creating notification channel: $e');
    }
  }

  // Initialize local notifications for foreground messages
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logDebug('[FCMService]', '📱 Notification tapped: ${response.payload}');
        // Handle notification tap
      },
    );

    logSuccess('[FCMService]', '✅ Local notifications initialized');
  }

  // Get FCM token
  Future<String?> _getFcmToken() async {
    if (_messaging == null) return null;

    try {
      _fcmToken = await _messaging!.getToken();
      logDebug('[FCMService]', '📱 FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      logError('[FCMService]', '❌ Error getting FCM token: $e');
      return null;
    }
  }

  // Set up message handlers for different states
  void _setupMessageHandlers() {
    if (_messaging == null) return;

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logInfo(
        '[FCMService]',
        '📨 Foreground message: ${message.notification?.title}',
      );

      // Check if notification should be displayed based on status
      final status = message.data['status'] as String?;

      if (status == null || status.toUpperCase() == 'UNREAD') {
        // Only show local notification if status is UNREAD or not specified
        _showLocalNotification(message);
        logDebug('[FCMService]', '✅ Showing notification (UNREAD)');
      } else {
        logDebug('[FCMService]', '⏭️ Skipping notification (status: $status)');
      }

      // Call callback if registered
      onMessageReceived?.call(message);
    });

    // When app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logInfo(
        '[FCMService]',
        '📱 App opened from notification: ${message.data}',
      );
      // Handle navigation when app is opened from notification
      // You can add navigation logic here based on message.data
    });

    // Token refresh
    _messaging!.onTokenRefresh.listen((String newToken) {
      logDebug('[FCMService]', '🔄 FCM token refreshed: $newToken');
      _fcmToken = newToken;
      onTokenRefresh?.call(newToken);
    });
  }

  // Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'New Notification',
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Get current FCM token
  String? get fcmToken => _fcmToken;

  // Check if FCM is available (not on web)
  bool get isAvailable => !kIsWeb && _messaging != null;

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) {
      logError('[FCMService]', '⚠️ Cannot subscribe: FCM not initialized');
      return;
    }

    try {
      await _messaging!.subscribeToTopic(topic);
      logSuccess('[FCMService]', '✅ Subscribed to topic: $topic');
    } catch (e) {
      logError('[FCMService]', '❌ Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) {
      logError('[FCMService]', '⚠️ Cannot unsubscribe: FCM not initialized');
      return;
    }

    try {
      await _messaging!.unsubscribeFromTopic(topic);
      logSuccess('[FCMService]', '✅ Unsubscribed from topic: $topic');
    } catch (e) {
      logError('[FCMService]', '❌ Error unsubscribing from topic: $e');
    }
  }

  // Delete FCM token
  Future<void> deleteToken() async {
    if (_messaging == null) return;

    try {
      await _messaging!.deleteToken();
      _fcmToken = null;
      logSuccess('[FCMService]', '✅ FCM token deleted');
    } catch (e) {
      logError('[FCMService]', '❌ Error deleting token: $e');
    }
  }

  // Get initial message (when app is opened from terminated state)
  Future<RemoteMessage?> getInitialMessage() async {
    if (_messaging == null) return null;

    try {
      final message = await _messaging!.getInitialMessage();

      // Don't show notification if it's already read
      if (message != null) {
        final status = message.data['status'] as String?;
        if (status != null && status.toUpperCase() == 'READ') {
          logDebug(
            '[FCMService]',
            '⏭️ Skipping initial message (already READ)',
          );
          return null;
        }
      }

      return message;
    } catch (e) {
      logError('[FCMService]', '❌ Error getting initial message: $e');
      return null;
    }
  }
}
