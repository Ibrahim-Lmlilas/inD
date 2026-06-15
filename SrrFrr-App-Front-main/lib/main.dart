import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srrfrr_app_front/core/services/fcm_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:srrfrr_app_front/features/loyalty_points/presentation/providers/loyalty_provider.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/providers/notification_provider.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/config/app_initializer.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/features/loyalty_points/data/services/loyalty_service.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/features/profile/data/services/profile_service.dart';
import 'package:srrfrr_app_front/features/support/data/services/support_service.dart';
import 'app/app.dart';
import 'core/services/websocket_service.dart';
import 'features/ride_tracking/data/services/ride_tracking_service.dart';
import 'shared/providers/user_provider.dart';
import 'features/passenger/presentation/providers/passenger_ws_provider.dart';
import 'shared/providers/driver_ws_provider.dart';
import 'shared/providers/map_provider.dart';
import 'features/passenger/presentation/providers/ride_config_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/passenger/presentation/providers/driver_provider.dart';
import 'features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'dart:async';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Start timing for performance measurement
  final stopwatch = Stopwatch()..start();

  // Phase 1: Load minimal environment config
  await _initializeEnvironment();

  // Phase 2: Initialize FCM (only on mobile platforms)
  if (!kIsWeb) {
    try {
      await FCMService().initialize();
      logSuccess('[Startup]', '✅ FCM initialized');
    } catch (e) {
      logError('[Startup]', '❌ FCM initialization failed: $e');
    }
  }

  stopwatch.stop();
  logDebug(
    '[Startup]',
    '⏱️  Environment loaded in ${stopwatch.elapsedMilliseconds}ms',
  );

  await initializeDateFormatting('fr_FR', null);

  // Launch app with AppInitializer wrapper for location permissions
  runApp(
    AppInitializer(
      onInitComplete: () {
        logSuccess('[Startup]', '✅ Location permissions granted - App ready');
      },
      child: MultiProvider(
        providers: [
          // ======================================================================
          // MARK: - Language Provider
          // ======================================================================
          ChangeNotifierProvider<LanguageProvider>(create: (_) => LanguageProvider()),

          // ======================================================================
          // MARK: - User Management
          // ======================================================================
          ChangeNotifierProxyProvider<LanguageProvider, UserProvider>(
            create: (context) => UserProvider(
              languageProvider: context.read<LanguageProvider>(),
            ),
            update: (context, languageProvider, previous) =>
                previous ?? UserProvider(languageProvider: languageProvider),
          ),

          // ======================================================================
          // MARK: - Auth Provider
          // ======================================================================
          ChangeNotifierProxyProvider2<
            LanguageProvider,
            UserProvider,
            AuthProvider
          >(
            create: (context) => AuthProvider(
              languageProvider: context.read<LanguageProvider>(),
              userProvider: context.read<UserProvider>(),
            ),
            update: (context, languageProvider, userProvider, previous) =>
                previous ??
                AuthProvider(
                  languageProvider: languageProvider,
                  userProvider: userProvider,
                ),
          ),

          // ======================================================================
          // MARK: - Core Services (Lightweight singletons)
          // ======================================================================
          Provider<WebSocketService>(create: (_) => WebSocketService()),
          Provider<FCMService>(create: (_) => FCMService()),
          Provider<ProfileService>(
            create: (_) => ProfileService(ApiInterceptor()),
          ),
          Provider<SupportService>(
            create: (_) => SupportService(ApiInterceptor()),
          ),

          // ======================================================================
          // MARK: - Ride Tracking Service (Independent WebSocket)
          // ======================================================================
          Provider<RideTrackingService>(
            create: (_) => RideTrackingService(),
            dispose: (_, service) => service.dispose(),
          ),

          // ======================================================================
          // MARK: - Notification Provider
          // ======================================================================
          ChangeNotifierProxyProvider<UserProvider, NotificationProvider>(
            create: (context) => NotificationProvider(),
            update: (context, userProvider, previous) {
              final provider = previous ?? NotificationProvider();

              // Initialize when user logs in
              if (userProvider.isAuthenticated &&
                  userProvider.currentUser != null) {
                provider.initialize(
                  userProvider.currentUser!.id as String,
                  userProvider.isDriverMode,
                );
              }

              return provider;
            },
          ),

          // ======================================================================
          // MARK: - Rating Provider (needs UserProvider)
          // ======================================================================
          ChangeNotifierProxyProvider<UserProvider, RatingProvider>(
            create: (context) => RatingProvider(context.read<UserProvider>()),
            update: (context, userProvider, previous) =>
                previous ?? RatingProvider(userProvider),
          ),

          // ======================================================================
          // MARK: - Ride Tracking Provider (needs RideTrackingService + UserProvider)
          // ======================================================================
          ChangeNotifierProxyProvider2<
            RideTrackingService,
            UserProvider,
            RideTrackingProvider
          >(
            create: (context) => RideTrackingProvider(
              context.read<RideTrackingService>(),
              context.read<UserProvider>(),
            ),
            update: (context, trackingService, userProvider, previous) =>
                previous ?? RideTrackingProvider(trackingService, userProvider),
          ),

          // ======================================================================
          // MARK: - WebSocket Providers
          // ======================================================================
          ChangeNotifierProxyProvider2<
            WebSocketService,
            RideTrackingProvider,
            PassengerWsProvider
          >(
            create: (context) => PassengerWsProvider(
              context.read<WebSocketService>(),
              context.read<RideTrackingProvider>(),
            ),
            update: (context, wsService, rideTracking, previous) =>
                previous ?? PassengerWsProvider(wsService, rideTracking),
          ),

          ChangeNotifierProxyProvider2<
            WebSocketService,
            RideTrackingProvider,
            DriverWsProvider
          >(
            create: (context) => DriverWsProvider(
              context.read<WebSocketService>(),
              context.read<RideTrackingProvider>(),
            ),
            update: (context, wsService, rideTracking, previous) =>
                previous ?? DriverWsProvider(wsService, rideTracking),
          ),

          // ======================================================================
          // MARK: - Map and Location
          // ======================================================================
          ChangeNotifierProvider<MapProvider>(create: (_) => MapProvider()),

          // ======================================================================
          // MARK: - Financial Providers
          // ======================================================================
          ChangeNotifierProvider<LoyaltyProvider>(
            create: (context) =>
                LoyaltyProvider(loyaltyService: LoyaltyService(ApiInterceptor())),
          ),
          ChangeNotifierProvider<WalletProvider>(
            create: (_) => WalletProvider(),
          ),

          // ======================================================================
          // MARK: - Subscription Provider
          // ======================================================================
          ChangeNotifierProvider<SubscriptionProvider>(
            create: (_) => SubscriptionProvider(),
          ),

          // ======================================================================
          // MARK: - Ride Management
          // ======================================================================
          ChangeNotifierProxyProvider<UserProvider, RideConfigProvider>(
            create: (context) =>
                RideConfigProvider(context.read<UserProvider>()),
            update: (context, userProvider, previous) =>
                previous ?? RideConfigProvider(userProvider),
          ),

          ChangeNotifierProxyProvider<PassengerWsProvider, DriverProvider>(
            create: (context) =>
                DriverProvider(context.read<PassengerWsProvider>()),
            update: (context, wsProvider, previous) =>
                previous ?? DriverProvider(wsProvider),
          ),

          // ======================================================================
          // MARK: - Communication
          // ======================================================================
          ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _initializeEnvironment() async {
  try {
    try {
      await dotenv.load(fileName: ".env.local");
      if (kDebugMode) {
        logSuccess('[Environment]', '✅ Loaded .env.local');
      }
    } catch (_) {
      await dotenv.load(fileName: ".env");
      if (kDebugMode) {
        logSuccess('[Environment]', '✅ Loaded .env');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      logError('[Environment]', '❌ Could not load environment file: $e');
    }
  }
}