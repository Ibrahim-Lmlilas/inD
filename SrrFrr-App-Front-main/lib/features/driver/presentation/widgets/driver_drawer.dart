// Driver Drawer Component
//
// Features:
// - Proper rating display from UserProvider
// - Fully responsive design (phone/tablet/desktop)
// - Auto-refresh on drawer open
// - Smooth animations
// - Loading state for mode switching
// - Debug logging for troubleshooting

library;

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
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class DriverDrawer extends StatefulWidget {
  final User? user;

  const DriverDrawer({super.key, this.user});

  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  late Animation<double> _avatarScaleAnimation;
  bool _isRefreshing = false;
  bool _isSwitchingMode = false; // Loading state for mode switch

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _refreshProfileData();
  }

  // Refresh driver profile data when drawer opens
  Future<void> _refreshProfileData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    final userProvider = context.read<UserProvider>();

    if (userProvider.isAuthenticated && userProvider.isDriverMode) {
      // logInfo(
      //   '[DriverDrawer]',
      //   '🔄 Refreshing driver profile data on drawer open',
      // );
      await userProvider.fetchDriverProfile();
      // logInfo(
      //   '[DriverDrawer]',
      //   '✅ Driver profile refreshed - Rating: ${userProvider.driverRating}',
      // );
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
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
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
              isLadiesInterface,
              responsivePadding,
            ),

            Expanded(child: _buildMenuSections(context, responsivePadding)),

            _buildPassengerModeButton(context, responsivePadding),
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
    bool isLadiesInterface,
    double padding,
  ) {
    final currentUser = userProvider.currentUser;
    final rating = userProvider.driverRating;
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
                              '${currentUser?.firstName ?? 'Conducteur'} ${currentUser?.lastName ?? ''}',
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

          _buildInterfaceBadge(isLadiesInterface, padding),
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

  Widget _buildInterfaceBadge(bool isLadiesInterface, double padding) {
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
          Icon(Icons.drive_eta_rounded, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            isLadiesInterface ? 'SRR FRR Ladies Driver' : 'SRR FRR Driver',
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
  // MENU SECTIONS
  // ============================================================================

  Widget _buildMenuSections(BuildContext context, double padding) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: padding * 0.8),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('Compte', padding),
        _buildMenuItem(
          context: context,
          icon: Icons.person_outline_rounded,
          title: 'Mon profil',
          subtitle: 'Informations personnelles',
          onTap: () => _handleDriverMenuTap(context, 'profile'),
        ),

        SizedBox(height: padding * 0.3),

        _buildSectionHeader('Activité', padding),
        _buildMenuItem(
          context: context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Vos alertes et messages',
          onTap: () => _handleDriverMenuTap(context, 'notifications'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.history_rounded,
          title: 'Historique',
          subtitle: 'Courses effectuées',
          onTap: () => _handleDriverMenuTap(context, 'history'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Portefeuille',
          subtitle: 'Solde et transactions',
          onTap: () => _handleDriverMenuTap(context, 'wallet'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.card_membership_outlined,
          title: 'Abonnement',
          subtitle: 'Gérer mon abonnement',
          onTap: () => _handleDriverMenuTap(context, 'subscription'),
        ),

        SizedBox(height: padding * 0.3),

        _buildSectionHeader('Paramètres', padding),
        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined,
          title: 'Paramètres',
          subtitle: 'Préférences de l\'app',
          onTap: () => _handleDriverMenuTap(context, 'settings'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.help_outline_rounded,
          title: 'Aide',
          subtitle: 'Support et FAQ',
          onTap: () => _handleDriverMenuTap(context, 'help'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.info_outline_rounded,
          title: 'À propos',
          subtitle: 'Version et informations',
          onTap: () => _handleDriverMenuTap(context, 'about'),
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
  // PASSENGER MODE BUTTON WITH LOADING STATE
  // ============================================================================

  Widget _buildPassengerModeButton(BuildContext context, double padding) {
    final buttonHeight = 52.0;

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
                    await _switchToPassengerMode(context);
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
                        'Changement...',
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
                      Icon(Icons.person_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mode Passager',
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
  // NAVIGATION HELPERS
  // ============================================================================

  void _handleDriverMenuTap(BuildContext context, String route) {
    Navigator.of(context).pop();

    final userProvider = context.read<UserProvider>();

    switch (route) {
      case 'profile':
        context.push('/profile?source=driver');
        break;
      case 'history':
        context.push('/ride-history?source=driver');
        break;
      case 'wallet':
        context.push('/driver/wallet');
        break;
      case 'subscription':
        context.push('/driver/subscription');
        break;
      case 'notifications':
        context.push('/driver/notifications');
        break;
      case 'settings':
        context.push('/system?source=driver', extra: userProvider.currentUser);
        break;
      case 'help':
        context.push('/help-faq?source=driver');
        break;
      case 'about':
        _showComingSoon(context, 'À propos');
        break;
      default:
        debugPrint('Unknown driver route: $route');
    }
  }

  Future<void> _switchToPassengerMode(BuildContext context) async {
    if (_isSwitchingMode) return;

    setState(() => _isSwitchingMode = true);

    try {
      final wsService = context.read<WebSocketService>();
      final userProvider = context.read<UserProvider>();

      if (wsService.currentEndpoint == '/ws/driver') {
        logInfo('DriverDrawer', 'Switching from driver to passenger mode');
        await wsService.disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await userProvider.switchMode(UserMode.passenger);

      if (!context.mounted) return;

      context.push('/home');
    } catch (e) {
      logError('DriverDrawer', 'Error switching to passenger mode: $e');
      if (!context.mounted) return;
      context.push('/home');
    } finally {
      if (mounted) {
        setState(() => _isSwitchingMode = false);
      }
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    SnackBarService(context).showInfo('$feature - Bientôt disponible');
  }
}
