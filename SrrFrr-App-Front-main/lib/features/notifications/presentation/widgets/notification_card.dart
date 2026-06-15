/// Notification Card Widget - Multilingual Support
///
/// Displays notification with language-aware title and content.
/// Uses LanguageProvider to select correct translation.

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification_type.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Card widget for displaying a notification
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final double padding;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.padding = 16.0,
  });

  /// Get icon and color based on notification type
  (IconData, Color) _getIconAndColor() {
    switch (notification.type) {
      // Driver notifications
      case NotificationType.driverRideConfirmed:
        return (Icons.check_circle_rounded, const Color(0xFF10B981));
      case NotificationType.driverWalletDebit:
        return (Icons.account_balance_wallet_rounded, const Color(0xFFF59E0B));
      case NotificationType.driverWalletCredit:
        return (Icons.account_balance_wallet_rounded, const Color(0xFF10B981));

      // Passenger notifications
      case NotificationType.passengerRideConfirmed:
        return (Icons.check_circle_rounded, const Color(0xFF10B981));
      case NotificationType.passengerRideStarted:
        return (Icons.directions_car_rounded, AppColors.primary);
      case NotificationType.passengerRideCompleted:
        return (Icons.flag_rounded, const Color(0xFF10B981));
      case NotificationType.passengerRideCancelled:
        return (Icons.cancel_rounded, const Color(0xFFDC2626));

      // Account notifications
      case NotificationType.accountValidated:
        return (Icons.verified_rounded, const Color(0xFF10B981));
      case NotificationType.accountRejected:
        return (Icons.cancel_rounded, const Color(0xFFDC2626));
      case NotificationType.accountLoyalty:
        return (Icons.loyalty_rounded, const Color(0xFF9333EA));

      default:
        return (Icons.notifications_rounded, AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final language = userProvider.currentUser?.language ?? Language.french;

    // Get localized content
    final localizedTitle = notification.getTitle(language.toBackend());
    final localizedContent = notification.getContent(language.toBackend());

    final (icon, color) = _getIconAndColor();

    // Use appropriate locale for timeago
    final timeAgo = timeago.format(
      notification.createdAt,
      locale: language.code,
    );

    final isUnread = notification.isUnread;

    return Container(
      margin: EdgeInsets.only(bottom: padding * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: isUnread
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isUnread ? 12 : 8,
            offset: Offset(0, isUnread ? 3 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: EdgeInsets.all(padding * 0.9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationIcon(icon: icon, color: color),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: _NotificationContent(
                    title: localizedTitle,
                    content: localizedContent,
                    isUnread: isUnread,
                    timeAgo: timeAgo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon container for notification
class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NotificationIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Icon(icon, size: 26, color: color),
    );
  }
}

/// Content section of notification
class _NotificationContent extends StatelessWidget {
  final String title;
  final String content;
  final bool isUnread;
  final String timeAgo;

  const _NotificationContent({
    required this.title,
    required this.content,
    required this.isUnread,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NotificationHeader(title: title, isUnread: isUnread),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        _NotificationTimestamp(timeAgo: timeAgo),
      ],
    );
  }
}

/// Header with title and unread indicator
class _NotificationHeader extends StatelessWidget {
  final String title;
  final bool isUnread;

  const _NotificationHeader({required this.title, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (isUnread)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Timestamp display
class _NotificationTimestamp extends StatelessWidget {
  final String timeAgo;

  const _NotificationTimestamp({required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 5),
        Text(
          timeAgo,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
