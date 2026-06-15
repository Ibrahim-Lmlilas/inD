// Notification Listener Widget - Multilingual Support
//
// Listens to NotificationProvider stream and displays SnackBar
// with language-aware content from UserProvider.
// Place this widget at the root of your app (in MaterialApp builder)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification_type.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/providers/notification_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class AppNotificationListener extends StatefulWidget {
  final Widget child;

  const AppNotificationListener({super.key, required this.child});

  @override
  State<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState extends State<AppNotificationListener> {
  AppNotification? _lastNotification;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // Listen for new notifications
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.notifications.isNotEmpty) {
            final latestNotification = provider.notifications.first;

            // Only show if it's a new notification (different from last shown)
            if (_lastNotification?.id != latestNotification.id) {
              _lastNotification = latestNotification;
              _showNotification(context, latestNotification);
            }
          }
        });

        return child!;
      },
      child: widget.child,
    );
  }

  void _showNotification(BuildContext context, AppNotification notification) {
    // Get current language from UserProvider
    final userProvider = context.read<UserProvider>();
    final language = userProvider.currentUser?.language ?? Language.french;

    // Get localized content
    final localizedTitle = notification.getTitle(language.toBackend());
    final localizedContent = notification.getContent(language.toBackend());

    logInfo(
      '[NotificationListener]',
      '📬 Displaying: $localizedTitle (${language.code})',
    );

    // Get l10n for button label
    final l10n = AppLocalizations.of(context)!;

    // Determine icon and color based on notification type
    final (icon, color) = _getIconAndColor(notification.type);

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localizedContent,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // action: SnackBarAction(
        //   label: l10n.notificationSnackbarAction,
        //   textColor: Colors.white,
        //   onPressed: () {
        //     // Mark as read and navigate to notifications page
        //     context.read<NotificationProvider>().markAsRead(notification.id);
        //     // TODO: Navigate based on category
        //     // Navigator.pushNamed(context, '/notifications');
        //   },
        // ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(NotificationType type) {
    switch (type) {
      // Passenger notifications - Green
      case NotificationType.passengerRideConfirmed:
        return (Icons.check_circle, const Color(0xFF10B981));
      case NotificationType.passengerRideStarted:
        return (Icons.play_circle, const Color(0xFF3B82F6));
      case NotificationType.passengerRideCompleted:
        return (Icons.check_circle_outline, const Color(0xFF10B981));
      case NotificationType.passengerRideCancelled:
        return (Icons.cancel, const Color(0xFFF59E0B));

      // Driver notifications
      case NotificationType.driverRideConfirmed:
        return (Icons.check_circle, const Color(0xFF10B981));
      case NotificationType.driverRideCancelled:
        return (Icons.cancel, const Color(0xFFF59E0B));
      case NotificationType.driverWalletDebit:
        return (Icons.money_off, const Color(0xFFDC2626));
      case NotificationType.driverWalletCredit:
        return (Icons.account_balance_wallet, const Color(0xFF10B981));
      case NotificationType.driverSubscriptionExpiring:
        return (Icons.warning, const Color(0xFFF59E0B));

      // Account notifications
      case NotificationType.accountValidated:
        return (Icons.verified, const Color(0xFF10B981));
      case NotificationType.accountRejected:
        return (Icons.cancel, const Color(0xFFDC2626));
      case NotificationType.accountPending:
        return (Icons.hourglass_empty, const Color(0xFF3B82F6));
      case NotificationType.accountLoyalty:
        return (Icons.star, const Color(0xFFF59E0B));
      case NotificationType.accountGeneral:
        return (Icons.info, const Color(0xFF3B82F6));

      // Unknown/fallback
      case NotificationType.unknown:
        return (Icons.notifications, const Color(0xFF6B7280));
    }
  }
}