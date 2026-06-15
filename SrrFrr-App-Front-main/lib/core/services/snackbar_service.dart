import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/shared/widgets/notification_system.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarService {
  final BuildContext context;

  SnackBarService(this.context);

  // Show snackbar with specified type
  void showSnackBar({
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool removeCurrent = true,
  }) {
    if (!_isContextValid()) return;

    final config = NotificationConfig.fromType(type);

    if (removeCurrent) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationIconRow(
          icon: config.icon,
          color: Colors.white,
          spacing: 8,
          child: NotificationContent(
            message: message,
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        margin: const EdgeInsets.all(AppSizes.paddingL),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  // Show success snackbar
  void showSuccess(String message, {Duration? duration}) => showSnackBar(
    message: message,
    type: NotificationType.success,
    duration: duration ?? const Duration(seconds: 3),
  );

  // Show error snackbar
  void showError(String message, {Duration? duration}) => showSnackBar(
    message: message,
    type: NotificationType.error,
    duration: duration ?? const Duration(seconds: 4),
  );

  // Show warning snackbar
  void showWarning(String message, {Duration? duration}) => showSnackBar(
    message: message,
    type: NotificationType.warning,
    duration: duration ?? const Duration(seconds: 5),
  );

  // Show info snackbar
  void showInfo(String message, {Duration? duration}) => showSnackBar(
    message: message,
    type: NotificationType.info,
    duration: duration ?? const Duration(seconds: 3),
  );

  // Dismiss current snackbar
  void dismissCurrent() {
    if (_isContextValid()) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
  }

  bool _isContextValid() {
    try {
      return ScaffoldMessenger.of(context).mounted;
    } catch (_) {
      return false;
    }
  }
}
