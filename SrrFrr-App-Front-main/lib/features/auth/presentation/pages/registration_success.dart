import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class RegistrationSuccessPage extends StatefulWidget {
  const RegistrationSuccessPage({super.key});

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _hasAutoRedirected = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();

    // Auto-redirect after animation completes (3 seconds)
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasAutoRedirected) {
        _hasAutoRedirected = true;
        _redirectToHome();
      }
    });
  }

  void _redirectToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildContent(context, user, l10n)),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    User? user,
    AppLocalizations l10n,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    return Container(
      height: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? (screenWidth - 400) / 2 : AppSizes.paddingL,
        vertical: AppSizes.paddingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Success Animation
          _buildSuccessAnimation(context, size: isSmallScreen ? 150.0 : 180.0),

          SizedBox(
            height: isSmallScreen ? AppSizes.paddingL : AppSizes.paddingXL,
          ),

          // Success Message
          _buildSuccessMessage(context, user, l10n),

          SizedBox(
            height: isSmallScreen ? AppSizes.paddingL : AppSizes.paddingXL,
          ),

          // Welcome Card
          _buildWelcomeCard(context, user, l10n),

          const Spacer(flex: 2),

          // Action Button
          _buildContinueButton(context, l10n),

          SizedBox(
            height: isSmallScreen ? AppSizes.paddingM : AppSizes.paddingL,
          ),

          // Auto-redirect indicator
          // _buildAutoRedirectIndicator(l10n),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation(BuildContext context, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/Car_safety_b.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: false,
        controller: _animationController,
      ),
    );
  }

  Widget _buildSuccessMessage(
    BuildContext context,
    User? user,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 60, color: AppColors.success),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          l10n.registrationSuccess,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (user != null) ...[
          const SizedBox(height: AppSizes.paddingS),
          Text(
            l10n.welcome(user.firstName),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
    User? user,
    AppLocalizations l10n,
  ) {
    final features = user?.shouldUseLadiesInterface == true
        ? [
            {
              'icon': Icons.female,
              'text': l10n.verifiedFemaleDrivers,
              'color': const Color(0xFFE91E63),
            },
            {
              'icon': Icons.security,
              'text': l10n.secureEnvironment,
              'color': AppColors.primary,
            },
            {
              'icon': Icons.support_agent,
              'text': l10n.prioritySupport,
              'color': AppColors.success,
            },
          ]
        : [
            {
              'icon': Icons.directions_car,
              'text': l10n.wideChoiceOfRides,
              'color': AppColors.primary,
            },
            {
              'icon': Icons.verified_user,
              'text': l10n.verifiedDrivers,
              'color': AppColors.success,
            },
            {
              'icon': Icons.payment,
              'text': l10n.securePayments,
              'color': const Color(0xFFFF9800),
            },
          ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.yourAccountIsReady,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Wrap(
            spacing: AppSizes.paddingL,
            runSpacing: AppSizes.paddingS,
            alignment: WrapAlignment.center,
            children: features.map((feature) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 16,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(width: AppSizes.paddingXS),
                  Text(
                    feature['text'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _redirectToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.startTraveling),
            const SizedBox(width: AppSizes.paddingS),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoRedirectIndicator(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final remainingSeconds = (3 - (_animationController.value * 3)).ceil();

        return Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: _animationController.value,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Auto-redirect in $remainingSeconds...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
