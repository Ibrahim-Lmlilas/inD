// Unified App Drawer
// Dynamically switches between passenger and driver modes
//
// Features:
// - Single component for both modes
// - Auto-updates when mode changes
// - Proper rating display from UserProvider
// - Fully responsive design
// - Loading states for mode switching

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/core/services/websocket_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class AppDrawer extends StatefulWidget {
  final User? user;

  const AppDrawer({super.key, this.user});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  late Animation<double> _avatarScaleAnimation;
  bool _isRefreshing = false;
  bool _isSwitchingMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    final userProvider = context.read<UserProvider>();

    if (userProvider.isAuthenticated) {
      if (userProvider.isDriverMode) {
        await userProvider.fetchDriverProfile();
      } else {
        await userProvider.refreshPassengerProfile();
      }
    }

    _isRefreshing = false;
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    final isDriverMode = userProvider.isDriverMode;
    final isLadiesInterface = currentUser?.shouldUseLadiesInterface ?? false;
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final isLargeScreen = !ResponsiveUtils.isPhone(context);

    return Drawer(
      backgroundColor: AppColors.background,
      width: isLargeScreen ? 400 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.isPhone(context) ? 0 : AppSizes.radiusL,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(
              userProvider,
              isDriverMode,
              isLadiesInterface,
              responsivePadding,
            ),

            Expanded(
              child: _buildMenuSections(
                context,
                responsivePadding,
                l10n,
                isDriverMode,
              ),
            ),

            _buildModeSwitchButton(
              context,
              responsivePadding,
              l10n,
              isDriverMode,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PROFILE HEADER
  // ============================================================================

  Widget _buildProfileHeader(
    UserProvider userProvider,
    bool isDriverMode,
    bool isLadiesInterface,
    double padding,
  ) {
    final currentUser = userProvider.currentUser;
    final rating = isDriverMode
        ? userProvider.driverRating
        : userProvider.passengerRating;
    final isLargeScreen = !ResponsiveUtils.isPhone(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      width: double.infinity,
      padding: EdgeInsets.all(padding * (isLargeScreen ? 1.5 : 1.2)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context) * 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Row(
              children: [
                ScaleTransition(
                  scale: _avatarScaleAnimation,
                  child: _buildAvatar(userProvider, isLargeScreen ? 70 : 60),
                ),

                SizedBox(width: padding * 0.8),

                Expanded(
                  child: AnimatedBuilder(
                    animation: _avatarController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _avatarController.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currentUser?.firstName ?? (isDriverMode ? 'Conducteur' : 'Utilisateur')} ${currentUser?.lastName ?? ''}',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  16,
                                ),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 4),

                            _buildRatingStars(rating, isLargeScreen),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: padding * 0.8),

          _buildInterfaceBadge(isDriverMode, isLadiesInterface, padding),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating, bool isLargeScreen) {
    final starSize = isLargeScreen ? 16.0 : 14.0;
    final fontSize = isLargeScreen ? 14.0 : 13.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          final isFilled = rating >= starValue;
          final isHalfFilled = rating >= starValue - 0.5 && rating < starValue;

          return Icon(
            isFilled
                ? Icons.star
                : isHalfFilled
                ? Icons.star_half
                : Icons.star_border,
            size: starSize,
            color: Colors.amber[300],
          );
        }),
        SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }

  Widget _buildInterfaceBadge(
    bool isDriverMode,
    bool isLadiesInterface,
    double padding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String badgeText;
    IconData badgeIcon;

    if (isDriverMode) {
      badgeText = isLadiesInterface
          ? l10n.ladiesInterfaceDriverBadge
          : l10n.driverModeBadge;
      badgeIcon = Icons.drive_eta_rounded;
    } else {
      badgeText = isLadiesInterface ? l10n.ladiesInterfaceBadge : l10n.appName;
      badgeIcon = isLadiesInterface ? Icons.female : Icons.person;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding * 0.8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, AppSizes.radiusL),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // AVATAR
  // ============================================================================

  Widget _buildAvatar(UserProvider userProvider, double size) {
    final user = userProvider.currentUser;
    final profilePicturePath = user?.profilePhotoPath;
    final hasValidPicture = UserProvider.isValidProfilePicture(
      profilePicturePath,
    );
    final pictureUrl = UserProvider.getProfilePictureUrl(profilePicturePath);
    final initial = UserProvider.getInitial(user?.firstName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasValidPicture ? null : Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, AppSizes.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context) * 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 3,
        ),
      ),
      child: hasValidPicture && pictureUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  AppSizes.radiusXL,
                ),
              ),
              child: Image.network(
                pictureUrl,
                fit: BoxFit.cover,
                headers: const {'Accept': 'image/*'},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar(initial, size);
                },
              ),
            )
          : _buildInitialAvatar(initial, size),
    );
  }

  Widget _buildInitialAvatar(String initial, double size) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================================
  // MENU SECTIONS - MODE AWARE
  // ============================================================================

  Widget _buildMenuSections(
    BuildContext context,
    double padding,
    AppLocalizations l10n,
    bool isDriverMode,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: padding * 0.8),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader(l10n.account, padding),
        _buildMenuItem(
          context: context,
          icon: Icons.person_outline_rounded,
          title: l10n.myProfile,
          subtitle: l10n.personalInformation,
          onTap: () => _handleMenuTap(context, 'profile', isDriverMode),
        ),

        SizedBox(height: padding * 0.3),

        _buildSectionHeader(l10n.activity, padding),
        _buildMenuItem(
          context: context,
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: l10n.yourAlertsAndMessages,
          onTap: () => _handleMenuTap(context, 'notifications', isDriverMode),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.history_rounded,
          title: l10n.history,
          subtitle: l10n.completedRides,
          onTap: () => _handleMenuTap(context, 'history', isDriverMode),
        ),

        // Driver-specific menu item
        if (isDriverMode) ...[
          _buildMenuItem(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.wallet,
            subtitle: l10n.walletBalanceTransactions,
            onTap: () => _handleMenuTap(context, 'wallet', isDriverMode),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.card_membership_outlined,
            title: l10n.subscription,
            subtitle: l10n.manageSubscription,
            onTap: () => _handleMenuTap(context, 'subscription', isDriverMode),
          ),
        ] else ...[
          // Passenger-specific menu item
          _buildMenuItem(
            context: context,
            icon: Icons.loyalty_rounded,
            title: l10n.loyaltyProgram,
            subtitle: l10n.pointsAndRewards,
            onTap: () => _handleMenuTap(context, 'rewards', isDriverMode),
          ),
        ],

        SizedBox(height: padding * 0.3),

        _buildSectionHeader(l10n.settings, padding),
        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined,
          title: l10n.settings,
          subtitle: l10n.appPreferences,
          onTap: () => _handleMenuTap(context, 'settings', isDriverMode),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.help_outline_rounded,
          title: l10n.help,
          subtitle: l10n.supportAndFaq,
          onTap: () => _handleMenuTap(context, 'help', isDriverMode),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.info_outline_rounded,
          title: l10n.about,
          subtitle: l10n.versionAndInformation,
          onTap: () => _handleMenuTap(context, 'about', isDriverMode),
        ),

        SizedBox(height: padding),
      ],
    );
  }

  Widget _buildSectionHeader(String title, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        padding * 0.8,
        padding,
        padding * 0.4,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isLargeScreen = !ResponsiveUtils.isPhone(context);
    final itemHeight = isLargeScreen ? 68.0 : 60.0;
    final iconContainerSize = isLargeScreen ? 44.0 : 38.0;
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, AppSizes.radiusM),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsivePadding(context),
            vertical: 4,
          ),
          child: Container(
            height: itemHeight,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsivePadding(context) * 0.8,
            ),
            child: Row(
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                        context,
                        AppSizes.radiusM,
                      ),
                    ),
                  ),
                  child: Icon(icon, size: iconSize, color: AppColors.primary),
                ),

                SizedBox(
                  width: ResponsiveUtils.getResponsivePadding(context) * 0.8,
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            15,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            12,
                          ),
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: iconSize,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MODE SWITCH BUTTON - DYNAMIC
  // ============================================================================

  Widget _buildModeSwitchButton(
    BuildContext context,
    double padding,
    AppLocalizations l10n,
    bool isDriverMode,
  ) {
    final buttonHeight = 52.0;
    final buttonText = isDriverMode ? l10n.passengerMode : l10n.driverMode;
    final buttonIcon = isDriverMode
        ? Icons.person_outline_rounded
        : Icons.drive_eta_rounded;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context) * 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _isSwitchingMode
                ? null
                : () async {
                    HapticFeedback.mediumImpact();
                    await _switchMode(context, isDriverMode);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              elevation: ResponsiveUtils.getResponsiveElevation(context),
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(
                    context,
                    AppSizes.radiusXXL,
                  ),
                ),
              ),
            ),
            child: _isSwitchingMode
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        l10n.switching,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(buttonIcon, size: 20),
                      SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // NAVIGATION & MODE SWITCHING
  // ============================================================================

  void _handleMenuTap(BuildContext context, String route, bool isDriverMode) {
    Navigator.of(context).pop();

    final userProvider = context.read<UserProvider>();
    final source = isDriverMode ? 'driver' : 'passenger';

    switch (route) {
      case 'profile':
        context.push('/profile?source=$source');
        break;
      case 'rewards':
        context.push('/rewards?source=$source');
        break;
      case 'history':
        context.push('/ride-history?source=$source');
        break;
      case 'wallet':
        context.push(isDriverMode ? '/driver/wallet' : '/passenger/wallet');
        break;
      case 'subscription':
        context.push('/driver/subscription');
        break;
      case 'notifications':
        context.push('/${source}/notifications');
        break;
      case 'settings':
        context.push('/system?source=$source', extra: userProvider.currentUser);
        break;
      case 'help':
        context.push('/help-faq?source=$source');
        break;
      case 'about':
        final l10n = AppLocalizations.of(context)!;
        _showComingSoon(context, l10n.about);
        break;
      default:
        debugPrint('Unknown route: $route');
    }
  }

  Future<void> _switchMode(BuildContext context, bool isCurrentlyDriver) async {
    if (_isSwitchingMode) return;

    setState(() => _isSwitchingMode = true);

    try {
      final wsService = context.read<WebSocketService>();
      final userProvider = context.read<UserProvider>();

      // Disconnect current WebSocket
      final currentEndpoint = wsService.currentEndpoint;
      if (currentEndpoint == '/ws/passenger' ||
          currentEndpoint == '/ws/driver') {
        logInfo(
          'AppDrawer',
          'Disconnecting ${isCurrentlyDriver ? 'driver' : 'passenger'} WebSocket',
        );
        await wsService.disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Switch mode
      final newMode = isCurrentlyDriver ? UserMode.passenger : UserMode.driver;
      await userProvider.switchMode(newMode);

      if (!context.mounted) return;

      // Navigate to appropriate screen
      if (isCurrentlyDriver) {
        // Switching to passenger
        context.push('/home');
      } else {
        // Switching to driver - use smart routing
        final targetRoute = userProvider.getDriverRoute();
        logInfo('AppDrawer', '→ Routing to: $targetRoute');
        context.push(targetRoute);
      }
    } catch (e) {
      logError('AppDrawer', 'Error switching mode: $e');
      if (!context.mounted) return;

      // Fallback navigation
      if (isCurrentlyDriver) {
        context.push('/home');
      } else {
        context.push('/driver-status');
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchingMode = false);
      }
    }
  }

  void _showComingSoon(BuildContext context, String featureName) {
    final l10n = AppLocalizations.of(context)!;
    SnackBarService(context).showInfo(l10n.featureComingSoon(featureName));
  }
}