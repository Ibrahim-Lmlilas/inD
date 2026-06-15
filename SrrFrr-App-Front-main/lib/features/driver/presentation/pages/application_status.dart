import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/providers/notification_provider.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification_type.dart';

enum ApplicationStatus {
  notRegistered,
  pending,
  validated,
  rejected,
  loading,
  error,
}

class ApplicationStatusPage extends StatefulWidget {
  const ApplicationStatusPage({super.key});

  @override
  State<ApplicationStatusPage> createState() => _ApplicationStatusPageState();
}

class _ApplicationStatusPageState extends State<ApplicationStatusPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  ApplicationStatus _status = ApplicationStatus.loading;
  Map<String, dynamic>? _driverData;
  String? _errorMessage;

  final Set<String> _processedNotificationIds = {};
  bool _isProcessingNotification = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkApplicationStatus();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.addListener(_onNotificationUpdate);
  }

  void _onNotificationUpdate() {
    if (!mounted || _isProcessingNotification) return;

    final notificationProvider = context.read<NotificationProvider>();

    final unreadAccountNotifications = notificationProvider.notifications
        .where((n) => n.status == 'UNREAD' && n.type.value.contains('ACCOUNT'))
        .toList();

    if (unreadAccountNotifications.isNotEmpty) {
      final notification = unreadAccountNotifications.first;

      if (!_processedNotificationIds.contains(notification.id)) {
        _processedNotificationIds.add(notification.id);
        _handleNotification(notification);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  void _restartAnimations() {
    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchDriverProfile();

      if (!mounted) return;

      if (userProvider.hasDriverProfile) {
        setState(() {
          _driverData = userProvider.driverProfile;

          if (userProvider.isDriverValidated) {
            _status = ApplicationStatus.validated;
          } else if (userProvider.isDriverPending) {
            _status = ApplicationStatus.pending;
          } else if (userProvider.isDriverRejected) {
            _status = ApplicationStatus.rejected;
          } else {
            _status = ApplicationStatus.notRegistered;
          }
          _restartAnimations();
        });
      } else {
        setState(() {
          _status = ApplicationStatus.notRegistered;
          _restartAnimations();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = ApplicationStatus.error;
        _errorMessage = 'Erreur de connexion';
        _restartAnimations();
      });
    }
  }

  void _handleNotification(AppNotification notification) {
    if (_isProcessingNotification) {
      logInfo('ApplicationStatusPage', '⏳ Already processing a notification');
      return;
    }

    _isProcessingNotification = true;

    logInfo(
      'ApplicationStatusPage',
      '📨 Account notification: ${notification.type.value} (ID: ${notification.id})',
    );

    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.accountValidated:
        logSuccess('ApplicationStatusPage', '✅ Account validated notification');
        _handleAccountValidated().then((_) {
          _isProcessingNotification = false;
        });
        break;

      case NotificationType.accountRejected:
        logWarning('ApplicationStatusPage', '❌ Account rejected notification');
        _handleAccountRejected().then((_) {
          _isProcessingNotification = false;
        });
        break;

      default:
        _isProcessingNotification = false;
        break;
    }
  }

  Future<void> _handleAccountValidated() async {
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.fetchDriverProfile();

    if (!mounted) return;

    setState(() {
      _driverData = userProvider.driverProfile;
      _status = ApplicationStatus.validated;
      _restartAnimations();
    });

    logSuccess('ApplicationStatusPage', '🎉 Transitioned to validated state');
  }

  Future<void> _handleAccountRejected() async {
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.fetchDriverProfile();

    if (!mounted) return;

    setState(() {
      _driverData = userProvider.driverProfile;
      _status = ApplicationStatus.rejected;
      _restartAnimations();
    });

    logWarning('ApplicationStatusPage', '⚠️ Transitioned to rejected state');
  }

  void _navigateToRegistration() {
    HapticFeedback.mediumImpact();
    context.push('/driver-registration');
  }

  void _navigateToReapply() {
    HapticFeedback.mediumImpact();
    context.push('/driver-registration', extra: {'reapply': true});
  }

  Future<void> _navigateToHome() async {
    try {
      HapticFeedback.mediumImpact();
      final userProvider = context.read<UserProvider>();
      await userProvider.switchMode(UserMode.passenger);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      logError('driver_status', 'Error switching mode: $e');
      if (!mounted) return;
      context.go('/home');
    }
  }

  Future<void> _navigateToDriverHome() async {
    try {
      HapticFeedback.mediumImpact();
      final userProvider = context.read<UserProvider>();
      await userProvider.switchMode(UserMode.driver);
      if (!mounted) return;
      context.go('/driver-home');
    } catch (e) {
      logError('driver_status', 'Error navigating to driver home: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: _navigateToHome,
        ),
        title: Text(
          l10n.driverMode,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20.0),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;

    switch (_status) {
      case ApplicationStatus.loading:
        return _buildLoadingState(l10n);
      case ApplicationStatus.notRegistered:
        return _buildNotRegisteredState(l10n);
      case ApplicationStatus.pending:
        return _buildPendingState(l10n);
      case ApplicationStatus.rejected:
        return _buildRejectedState(l10n);
      case ApplicationStatus.validated:
        return _buildValidatedState(l10n);
      case ApplicationStatus.error:
        return _buildErrorState(l10n);
    }
  }

  Widget _buildValidatedState(AppLocalizations l10n) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 16.0);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 70.0);
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 32.0);
    final bodySize = ResponsiveUtils.getResponsiveFontSize(context, 16.0);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

          // Animated Success Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.2),
                    AppColors.success.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: iconSize,
                color: AppColors.success,
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          // Title
          SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Text(
                  l10n.validatedTitle,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing),
                Text(
                  l10n.validatedDescription,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      18.0,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          // Success Card
          Container(
            padding: EdgeInsets.all(padding * 1.2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.08),
                  AppColors.success.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
              ),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    color: AppColors.success,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  l10n.welcomeDrivers,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      18.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                ),
                Text(
                  l10n.welcomeDriversDescription,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          // Benefits Grid
          _buildBenefitItem(
            icon: Icons.stars_rounded,
            title: l10n.verifiedStatus,
            description: l10n.verifiedBadge,
            l10n: l10n,
          ),
          SizedBox(height: spacing),
          _buildBenefitItem(
            icon: Icons.attach_money,
            title: l10n.flexibleIncome,
            description: l10n.flexibleIncomeDesc,
            l10n: l10n,
          ),
          SizedBox(height: spacing),
          _buildBenefitItem(
            icon: Icons.shield_rounded,
            title: l10n.insuredProtection,
            description: l10n.insuredProtectionDesc,
            l10n: l10n,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          // Primary Action Button
          Container(
            width: double.infinity,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  AppSizes.radiusXL,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _navigateToDriverHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      AppSizes.radiusXL,
                    ),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drive_eta_rounded,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    l10n.startDriving,
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: spacing),

          // Secondary Button
          TextButton(
            onPressed: _navigateToHome,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
            ),
            child: Text(
              l10n.returnHome,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
              color: AppColors.success,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      13.0,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveIconSize(context, 50.0),
            height: ResponsiveUtils.getResponsiveIconSize(context, 50.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
          Text(
            l10n.verifyingStatus,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16.0),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotRegisteredState(AppLocalizations l10n) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 16.0);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 70.0);
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 30.0);
    final bodySize = ResponsiveUtils.getResponsiveFontSize(context, 16.0);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Icon(
                Icons.drive_eta_rounded,
                size: iconSize,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          Text(
            l10n.notRegisteredTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
            child: Text(
              l10n.notRegisteredDescription,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          _buildFeatureCard(
            icon: Icons.monetization_on_rounded,
            title: l10n.attractiveIncome,
            description: l10n.attractiveIncomeDesc,
            color: const Color(0xFF10B981),
            l10n: l10n,
          ),
          SizedBox(height: spacing),
          _buildFeatureCard(
            icon: Icons.access_time_rounded,
            title: l10n.totalFreedom,
            description: l10n.totalFreedomDesc,
            color: const Color(0xFF3B82F6),
            l10n: l10n,
          ),
          SizedBox(height: spacing),
          _buildFeatureCard(
            icon: Icons.verified_user_rounded,
            title: l10n.guaranteedSafety,
            description: l10n.guaranteedSafetyDesc,
            color: const Color(0xFF8B5CF6),
            l10n: l10n,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          Container(
            width: double.infinity,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  AppSizes.radiusXL,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _navigateToRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      AppSizes.radiusXL,
                    ),
                  ),
                ),
              ),
              child: Text(
                l10n.startRegistration,
                style: TextStyle(
                  fontSize: bodySize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
        ],
      ),
    );
  }

  Widget _buildPendingState(AppLocalizations l10n) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 70.0);
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 30.0);
    final bodySize = ResponsiveUtils.getResponsiveFontSize(context, 16.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    const Color(0xFFF59E0B).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: iconSize,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          Text(
            l10n.pendingVerificationTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
            child: Text(
              l10n.pendingVerificationDescription,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          Container(
            padding: EdgeInsets.all(padding * 1.2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.08),
                  const Color(0xFFF59E0B).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
              ),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: const Color(0xFFF59E0B),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 48.0),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                ),
                Text(
                  l10n.processingTime,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      18.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                ),
                Text(
                  l10n.verificationTimeframe,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          TextButton(
            onPressed: _navigateToHome,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
            ),
            child: Text(
              l10n.returnHome,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedState(AppLocalizations l10n) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 16.0);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 70.0);
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 30.0);
    final bodySize = ResponsiveUtils.getResponsiveFontSize(context, 16.0);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              height: ResponsiveUtils.getResponsiveIconSize(context, 140.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.3),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: iconSize,
                color: AppColors.error,
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

          Text(
            l10n.rejectedTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
            child: Text(
              l10n.rejectedDescription,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          Container(
            padding: EdgeInsets.all(padding * 1.2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withValues(alpha: 0.08),
                  AppColors.error.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
              ),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.error,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          24.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        12.0,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.rejectionReason,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            18.0,
                          ),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                ),
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                  ),
                  child: Text(
                    _driverData?['rejection_reason'] ??
                        l10n.defaultRejectionReason,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14.0,
                      ),
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40.0)),

          Container(
            width: double.infinity,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  AppSizes.radiusXL,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _navigateToReapply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      AppSizes.radiusXL,
                    ),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    'Nouvelle demande',
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: spacing),

          TextButton(
            onPressed: _navigateToHome,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
            ),
            child: Text(
              l10n.returnHome,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 26.0);
    final bodySize = ResponsiveUtils.getResponsiveFontSize(context, 16.0);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 80.0);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: iconSize,
                color: AppColors.error,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            ),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsivePadding(context),
              ),
              child: Text(
                _errorMessage ?? l10n.connectionError,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
            ),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _checkApplicationStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                        context,
                        AppSizes.radiusXL,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required AppLocalizations l10n,
  }) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtils.getResponsiveIconSize(context, 60.0),
            height: ResponsiveUtils.getResponsiveIconSize(context, 60.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 14.0),
              ),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(context, 30.0),
              color: color,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      13.0,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
