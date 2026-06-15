import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/pages/edit-language.dart';
import 'package:srrfrr_app_front/features/auth/presentation/pages/registration_success.dart';
import 'package:srrfrr_app_front/features/support/presentation/pages/help_faq.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/features/auth/presentation/pages/registration.dart';
import 'package:srrfrr_app_front/features/chat/presentation/pages/chat.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/pages/wallet_page.dart';
import 'package:srrfrr_app_front/features/profile/presentation/pages/edit_interface_type.dart';
import 'package:srrfrr_app_front/features/profile/presentation/pages/edit_profile_name.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/pages/edit_theme.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/pages/system_settings.dart';
import 'package:srrfrr_app_front/features/profile/presentation/pages/profile.dart';
import 'package:srrfrr_app_front/features/profile/presentation/pages/edit_password.dart';
import 'package:srrfrr_app_front/features/profile/presentation/pages/edit_phone.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/pages/driver_subscription.dart';
import 'package:srrfrr_app_front/features/ride_history/presentation/pages/ride_history.dart';
import 'package:srrfrr_app_front/features/loyalty_points/presentation/pages/rewards.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/pages/notifications.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/pages/drivers_offers.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/pages/ride_tracking.dart';
import 'package:srrfrr_app_front/features/driver/presentation/pages/application_status.dart';
import 'package:srrfrr_app_front/features/driver/presentation/pages/driver_registration.dart';
import 'package:srrfrr_app_front/features/driver/presentation/pages/home.dart';
import 'package:srrfrr_app_front/features/auth/presentation/pages/pwd_reset.dart';
import 'package:srrfrr_app_front/features/splash/splash_page.dart';
import 'package:srrfrr_app_front/features/auth/presentation/pages/auth.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/pages/home.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ========================================================================
      // Authentication & Onboarding Routes
      // ========================================================================
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/registration',
        builder: (context, state) {
          final userType = state.extra as String? ?? 'passenger';
          return RegistrationPage(userType: userType);
        },
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetPage(),
      ),
      GoRoute(
        path: '/registration-success',
        builder: (context, state) => const RegistrationSuccessPage(),
      ),

      // ========================================================================
      // Passenger Routes
      // ========================================================================
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/driver-offers',
        name: 'driver-offers',
        builder: (context, state) {
          final rideRequest = state.extra as Map<String, dynamic>?;

          if (rideRequest == null) {
            // Redirect to home if no ride request data
            return const Scaffold(
              body: Center(child: Text('Invalid ride request')),
            );
          }

          return DriverOffersPage(rideRequest: rideRequest);
        },
      ),
      GoRoute(
        path: '/ride-tracking',
        builder: (context, state) {
          return const RideTrackingPage();
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          if (data == null) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('/home');
              }
            });
            return const HomePage();
          }

          final chatData = data['chatData'] as Map<String, dynamic>?;
          final rideData = data['rideData'] as Map<String, dynamic>?;

          // Validate both chatData AND rideData exist
          if (chatData == null || rideData == null) {
            logError('Routes', '❌ Missing chatData or rideData');
            if (context.mounted) {
              context.go('/home');
            }
            return const HomePage();
          }

          // Validate rideId exists in rideData
          if (rideData['ride_id'] == null) {
            logError('Routes', '❌ Missing ride_id in rideData');
            Future.microtask(() {
              if (context.mounted) {
                context.go('/home');
              }
            });
            return const HomePage();
          }

          return ChatPage(data: {'chatData': chatData, 'rideData': rideData});
        },
      ),

      // ========================================================================
      // Driver Routes
      // ========================================================================
      GoRoute(
        path: '/driver-status',
        builder: (context, state) => const ApplicationStatusPage(),
      ),
      GoRoute(
        path: '/driver-registration',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isReapplying = extra?['reapply'] == true;
          return DriverRegistrationPage(isReapplying: isReapplying);
        },
      ),
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => const DriverHomePage(),
      ),

      // Driver sub-routes (features)
      GoRoute(
        path: '/driver/wallet',
        builder: (context, state) => const DriverWalletPage(),
      ),
      GoRoute(
        path: '/driver/subscription',
        builder: (context, state) => const DriverSubscriptionPage(),
      ),
      GoRoute(
        path: '/driver/vehicle',
        builder: (context, state) {
          // TODO: Create DriverVehiclePage
          return const Scaffold(
            body: Center(child: Text('Driver Vehicle Info - Coming Soon')),
          );
        },
      ),

      // ========================================================================
      // Profile Routes (Common for both Passenger & Driver)
      // ========================================================================
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'] ?? 'passenger';
          return ProfilePage(source: source);
        },
        routes: [
          // Profile edit subsections
          GoRoute(
            path: 'edit-info',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return EditProfilePage(source: source, isEditing: false);
            },
          ),
          GoRoute(
            path: 'edit-password',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return EditPasswordPage(source: source);
            },
          ),
          GoRoute(
            path: 'edit-phone',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return EditPhonePage(source: source);
            },
          ),
        ],
      ),

      // ========================================================================
      // System Settings Routes (Common for both Passenger & Driver)
      // ========================================================================
      GoRoute(
        path: '/system',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'] ?? 'passenger';
          return SystemSettingsPage(source: source);
        },
        routes: [
          // System settings subsections
          GoRoute(
            path: 'edit-interface',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return InterfaceTypePage(source: source);
            },
          ),
          GoRoute(
            path: 'edit-theme',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return ThemePage(source: source);
            },
          ),
          GoRoute(
            path: 'edit-language',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'passenger';
              return LanguagePage(source: source);
            },
          ),
        ],
      ),

      // ========================================================================
      // Rewards & Loyalty Routes
      // ========================================================================
      GoRoute(
        path: '/rewards',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'];
          return RewardsPage(source: source!);
        },
      ),

      // ========================================================================
      // Ride History Routes (Unified)
      // ========================================================================
      GoRoute(
        path: '/ride-history',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'] ?? 'passenger';
          final isDriverMode = source == 'driver';
          return RideHistoryPage(isDriverMode: isDriverMode);
        },
      ),

      // ========================================================================
      // Notification Routes
      // ========================================================================
      GoRoute(
        path: '/driver/notifications',
        builder: (context, state) {
          return NotificationsPage(source: 'driver');
        },
      ),

      GoRoute(
        path: '/passenger/notifications',
        builder: (context, state) {
          return NotificationsPage(source: 'passenger');
        },
      ),

      // ========================================================================
      // Help & Support Routes
      // ========================================================================
      GoRoute(
        path: '/help-faq',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'];
          return HelpFaqPage(source: source!);
        },
      ),
    ],

    // Error handler - redirects to home on any routing error
    errorBuilder: (context, state) {
      debugPrint('Routing error: ${state.error}');
      return const HomePage();
    },

    // Redirect logic for authentication and user mode
    redirect: (context, state) {
      // Don't redirect during splash - let splash screen handle it
      if (state.matchedLocation == '/splash') {
        return null;
      }

      // Public routes that don't need authentication
      final publicRoutes = ['/auth', '/registration', '/password-reset'];
      final isOnPublicRoute = publicRoutes.contains(state.matchedLocation);

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final isLoggedIn = userProvider.isAuthenticated;
        final isDriverMode = userProvider.isDriverMode;

        // Redirect to auth if not logged in and not on public route
        if (!isLoggedIn && !isOnPublicRoute) {
          debugPrint('Redirecting to /auth - user not authenticated');
          return '/auth';
        }

        // Redirect to appropriate home if logged in and on auth/registration pages
        if (isLoggedIn && isOnPublicRoute) {
          final destination = isDriverMode ? '/driver-home' : '/home';
          debugPrint(
            'Redirecting to $destination - user already authenticated',
          );
          return destination;
        }
      } catch (e) {
        // Provider not yet available, allow navigation
        debugPrint('UserProvider not available yet: $e');
      }

      return null;
    },
  );
}

// Helper class for navigation with context preservation
class NavigationHelper {
  // Navigate to profile from passenger mode
  static void navigateToProfileFromPassenger(BuildContext context) {
    context.go('/profile?source=passenger');
  }

  // Navigate to profile from driver mode
  static void navigateToProfileFromDriver(BuildContext context) {
    context.go('/profile?source=driver');
  }

  // Navigate to system settings from passenger mode
  static void navigateToSystemSettingsFromPassenger(BuildContext context) {
    context.go('/system?source=passenger');
  }

  // Navigate to system settings from driver mode
  static void navigateToSystemSettingsFromDriver(BuildContext context) {
    context.go('/system?source=driver');
  }

  // Navigate to rewards from passenger mode
  static void navigateToRewardsFromPassenger(BuildContext context) {
    context.go('/rewards?source=passenger');
  }

  // Navigate to rewards from driver mode
  static void navigateToRewardsFromDriver(BuildContext context) {
    context.go('/rewards?source=driver');
  }

  // Navigate to ride history from passenger mode
  static void navigateToRideHistoryFromPassenger(BuildContext context) {
    context.go('/ride-history?source=passenger');
  }

  // Navigate to ride history from driver mode
  static void navigateToRideHistoryFromDriver(BuildContext context) {
    context.go('/ride-history?source=driver');
  }

  // Get the correct back destination based on source
  static String getBackDestination(String source) {
    switch (source) {
      case 'driver':
        return '/driver-home';
      case 'driver-status':
        return '/driver-status';
      case 'passenger':
      default:
        return '/home';
    }
  }
}