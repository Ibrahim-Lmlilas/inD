// System Settings Page (Refactored)
//
// Clean architecture with proper separation:
// - Uses SettingsRepository for persistence
// - Uses UserProvider for account operations
// - Extracted sections into separate widgets

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/config/request_permissions.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/features/account_settings/data/repositories/settings_repository.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/account_deletion_dialog.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/appearance_section.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/notifications_section.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/privacy_section.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class SystemSettingsPage extends StatefulWidget {
  final String source;

  const SystemSettingsPage({super.key, this.source = 'passenger'});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage>
    with WidgetsBindingObserver {
  late final SettingsRepository _settingsRepository;

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _settingsRepository = SettingsRepository();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoadingSettings = true);

    try {
      final settings = await _settingsRepository.getNotificationSettings();

      if (mounted) {
        setState(() {
          _notificationsEnabled = settings.fullyEnabled;
          _soundEnabled = settings.soundEnabled;
          _vibrationEnabled = settings.vibrationEnabled;
        });
      }
    } catch (e) {
      logError('SystemSettingsPage', 'Error loading settings: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSettings = false);
      }
    }
  }

  Future<void> _saveNotificationSettings() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await _settingsRepository.setSoundEnabled(_soundEnabled);
      await _settingsRepository.setVibrationEnabled(_vibrationEnabled);

      if (mounted) {
        SnackBarService(context).showSuccess(l10n.notificationsSaved);
      }
    } catch (e) {
      logError('SystemSettingsPage', 'Error saving settings: $e');
      if (mounted) {
        SnackBarService(context).showError(l10n.savingError);
      }
    }
  }

  Future<void> _handleNotificationsToggle(bool value) async {
    final l10n = AppLocalizations.of(context)!;

    if (!value) {
      await _settingsRepository.setNotificationsEnabled(false);
      setState(() => _notificationsEnabled = false);
      SnackBarService(context).showSuccess(l10n.notificationsDisabled);
      return;
    }

    final hasPermission = await RequestPermissions.hasNotificationPermission();

    if (!hasPermission) {
      final granted = await RequestPermissions.requestNotificationPermission();

      if (!granted) {
        if (mounted) {
          _showPermissionDialog();
          setState(() => _notificationsEnabled = false);
        }
        return;
      }
    }

    await _settingsRepository.setNotificationsEnabled(true);
    setState(() => _notificationsEnabled = true);
    SnackBarService(context).showSuccess(l10n.notificationsEnabled);
  }

  void _showPermissionDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          l10n.permissionRequired,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationPermissionExplanation,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.mustEnableInSettings,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              RequestPermissions.openAppSettings();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: Text(
              l10n.openSettings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    context.push('$route?source=${widget.source}');
  }

  void _showComingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    SnackBarService(context).showInfo(l10n.featureComingSoon(feature));
  }

  Future<void> _showDeleteAccountDialog() async {
    HapticFeedback.mediumImpact();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AccountDeletionDialog(),
    );

    if (result == null || !mounted) return;

    await _proceedWithDeletion(
      password: result['password'] as String,
      reason: result['reason'] as String? ?? '',
      confirmed: result['confirmed'] as bool,
    );
  }

  Future<void> _proceedWithDeletion({
    required String password,
    required String reason,
    required bool confirmed,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    _showLoadingDialog();

    try {
      final userProvider = context.read<UserProvider>();

      final result = await userProvider.deleteAccount(
        password: password,
        reason: reason,
        confirmed: confirmed,
      );

      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        if (mounted) {
          SnackBarService(context).showSuccess(l10n.accountDeletedSuccessfully);
          await Future.delayed(const Duration(milliseconds: 800));

          if (mounted) {
            context.go('/auth');
          }
        }
      } else {
        if (mounted) {
          SnackBarService(
            context,
          ).showError(result['message'] ?? l10n.accountDeletionFailed);
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      logError('SystemSettingsPage', 'Delete account error: $e');

      if (mounted) {
        SnackBarService(context).showError(l10n.errorOccurredPleaseTryAgain);
      }
    }
  }

  void _showLoadingDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.deleting,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    final isFemaleUser = currentUser?.gender.toBackend().toLowerCase() == 'female';
    final isLadiesInterface =
        currentUser?.interfaceType.toBackend().toLowerCase() == 'ladies';

    if (_isLoadingSettings) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: padding),
            _buildSectionHeader(l10n.appearanceAndInterface, padding),
            SizedBox(height: padding / 2),
            AppearanceSection(
              onNavigate: _navigateTo,
              isFemaleUser: isFemaleUser,
              isLadiesInterface: isLadiesInterface,
              padding: padding,
            ),
            SizedBox(height: padding * 1.5),
            _buildSectionHeader(l10n.notifications, padding),
            SizedBox(height: padding / 2),
            NotificationsSection(
              notificationsEnabled: _notificationsEnabled,
              soundEnabled: _soundEnabled,
              vibrationEnabled: _vibrationEnabled,
              onNotificationsChanged: (value) {
                HapticFeedback.selectionClick();
                _handleNotificationsToggle(value);
              },
              onSoundChanged: (value) {
                setState(() => _soundEnabled = value);
                HapticFeedback.selectionClick();
                _saveNotificationSettings();
              },
              onVibrationChanged: (value) {
                setState(() => _vibrationEnabled = value);
                HapticFeedback.selectionClick();
                _saveNotificationSettings();
              },
              padding: padding,
            ),
            SizedBox(height: padding * 1.5),
            _buildSectionHeader(l10n.dataAndPrivacy, padding),
            SizedBox(height: padding / 2),
            PrivacySection(
              onPrivacyPolicy: () => _showComingSoon(l10n.privacyPolicy),
              onTerms: () => _showComingSoon(l10n.termsAndConditions),
              onDeleteAccount: _showDeleteAccountDialog,
              padding: padding,
            ),
            SizedBox(height: padding * 2),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.settings,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionHeader(String title, double padding) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}