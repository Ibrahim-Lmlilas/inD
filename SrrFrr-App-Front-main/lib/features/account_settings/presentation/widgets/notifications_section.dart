// Notifications Section Widget
// Settings for notification preferences

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/switch_tile.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class NotificationsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;
  final double padding;

  const NotificationsSection({
    super.key,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onNotificationsChanged,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SwitchTile(
              icon: Icons.notifications_active,
              title: l10n.enableNotifications,
              subtitle: l10n.receiveAllNotifications,
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
            if (notificationsEnabled) ...[
              Divider(height: 1, indent: 68, color: AppColors.dividerColor),
              SwitchTile(
                icon: Icons.volume_up,
                title: l10n.sound,
                subtitle: l10n.notificationSounds,
                value: soundEnabled,
                onChanged: onSoundChanged,
              ),
              Divider(height: 1, indent: 68, color: AppColors.dividerColor),
              SwitchTile(
                icon: Icons.vibration,
                title: l10n.vibration,
                subtitle: l10n.notificationVibration,
                value: vibrationEnabled,
                onChanged: onVibrationChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}