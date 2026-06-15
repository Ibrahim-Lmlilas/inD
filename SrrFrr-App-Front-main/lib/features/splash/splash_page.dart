// lib/presentation/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  DateTime? _startTime;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashFlow();
    });
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSplashFlow() async {
    if (_navigationStarted) return;
    _navigationStarted = true;

    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);

    final destination = await _initializeAndCheckAuth();

    final elapsedTime = DateTime.now().difference(_startTime!);
    final remainingTime = const Duration(seconds: 2) - elapsedTime;
    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }

    if (mounted) {
      await _fadeController.forward();
      if (mounted) {
        logDebug('[SplashPage]',' Final navigation to: $destination');
        context.go(destination);
      }
    }
  }

  Future<String> _initializeAndCheckAuth() async {
    try {
      logDebug('[SplashPage]', 'Starting authentication flow');

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.initialize();

      logDebug('[SplashPage]', 'UserProvider initialized');
      logDebug('[SplashPage]', 'Provider state:');
      logDebug(
        '[SplashPage]',
        '- isAuthenticated: ${userProvider.isAuthenticated}',
      );
      logDebug('[SplashPage]', '- isDriverMode: ${userProvider.isDriverMode}');
      logDebug(
        '[SplashPage]',
        '- currentUser: ${userProvider.currentUser != null ? "Present" : "Null"}',
      );

      if (!userProvider.isAuthenticated) {
        logDebug('[SplashPage]', 'User not authenticated, going to auth');
        return '/auth';
      }

      final activeRideRoute = await userProvider.checkForActiveRide();
      if (activeRideRoute != null) {
        logDebug(
          '[SplashPage]',
          'Active ride found, redirecting to tracking',
        );
        return activeRideRoute;
      }

      if (userProvider.isDriverMode) {
        logDebug(
          '[SplashPage]',
          'User is driver, checking driver profile',
        );

        await userProvider.fetchDriverProfile();

        final driverRoute = userProvider.getDriverRoute();
        logDebug('[SplashPage]', 'Driver route determined: $driverRoute');
        return driverRoute;
      } else {
        logDebug('[SplashPage]', 'User is passenger, going to home');
        return '/home';
      }
    } catch (e, stackTrace) {
      logDebug('[SplashPage]', 'Error during auth flow: $e');
      logDebug('[SplashPage]', 'Stack trace: $stackTrace');
      return '/auth';
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeAnimation,
          _scaleAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues( alpha : 0.9),
                  AppColors.secondary,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues( alpha : 
                                0.3 * _pulseAnimation.value,
                              ),
                              blurRadius: 40 * _pulseAnimation.value,
                              spreadRadius: 10 * _pulseAnimation.value,
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withValues( alpha : 0.4),
                              blurRadius: 60,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const AppLogo(width: 200, height: 200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}