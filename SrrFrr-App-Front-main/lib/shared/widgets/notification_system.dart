/// Shared notification configuration for dialogs and snackbars
library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

// ============================================================================
// NOTIFICATION TYPE ENUM
// ============================================================================

enum NotificationType { success, error, warning, info }

// ============================================================================
// NOTIFICATION CONFIGURATION
// ============================================================================

class NotificationConfig {
  final Color backgroundColor;
  final IconData icon;
  final String defaultTitle;

  const NotificationConfig({
    required this.backgroundColor,
    required this.icon,
    required this.defaultTitle,
  });

  static NotificationConfig fromType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return NotificationConfig(
          backgroundColor: AppColors.success,
          icon: Icons.check_circle_outline,
          defaultTitle: 'Succès',
        );
      case NotificationType.error:
        return NotificationConfig(
          backgroundColor: AppColors.error,
          icon: Icons.error_outline,
          defaultTitle: 'Erreur',
        );
      case NotificationType.warning:
        return NotificationConfig(
          backgroundColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
          defaultTitle: 'Attention',
        );
      case NotificationType.info:
        return NotificationConfig(
          backgroundColor: AppColors.primary,
          icon: Icons.info_outline,
          defaultTitle: 'Information',
        );
    }
  }
}

// ============================================================================
// SHARED UI COMPONENTS
// ============================================================================

class NotificationIconRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Widget child;
  final double spacing;

  const NotificationIconRow({
    super.key,
    required this.icon,
    required this.color,
    required this.child,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: spacing),
        Expanded(child: child),
      ],
    );
  }
}

class NotificationContent extends StatelessWidget {
  final String message;
  final TextStyle? textStyle;

  const NotificationContent({super.key, required this.message, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: textStyle);
  }
}