// Notification Utilities
//
// Helper functions for notification display and formatting

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification_type.dart';

class NotificationUtils {
  // Get icon for notification type
  static IconData getIcon(NotificationType type) {
    switch (type) {
      // Passenger notifications
      case NotificationType.passengerRideConfirmed:
        return Icons.check_circle;
      case NotificationType.passengerRideStarted:
        return Icons.play_circle;
      case NotificationType.passengerRideCompleted:
        return Icons.check_circle_outline;
      case NotificationType.passengerRideCancelled:
        return Icons.cancel;

      // Driver notifications
      case NotificationType.driverRideConfirmed:
        return Icons.check_circle;
      case NotificationType.driverRideCancelled:
        return Icons.cancel;
      case NotificationType.driverWalletDebit:
        return Icons.money_off;
      case NotificationType.driverWalletCredit:
        return Icons.account_balance_wallet;
      case NotificationType.driverSubscriptionExpiring:
        return Icons.warning;

      // Account notifications
      case NotificationType.accountValidated:
        return Icons.verified;
      case NotificationType.accountRejected:
        return Icons.cancel;
      case NotificationType.accountPending:
        return Icons.hourglass_empty;
      case NotificationType.accountLoyalty:
        return Icons.star;
      case NotificationType.accountGeneral:
        return Icons.info;

      // Unknown
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }

  // Get color for notification type
  static Color getColor(NotificationType type) {
    switch (type) {
      // Success states - Green
      case NotificationType.passengerRideConfirmed:
      case NotificationType.passengerRideCompleted:
      case NotificationType.driverRideConfirmed:
      case NotificationType.driverWalletCredit:
      case NotificationType.accountValidated:
        return const Color(0xFF10B981);

      // Warning states - Orange
      case NotificationType.passengerRideCancelled:
      case NotificationType.driverRideCancelled:
      case NotificationType.driverSubscriptionExpiring:
      case NotificationType.accountLoyalty:
        return const Color(0xFFF59E0B);

      // Error states - Red
      case NotificationType.driverWalletDebit:
      case NotificationType.accountRejected:
        return const Color(0xFFDC2626);

      // Info states - Blue
      case NotificationType.passengerRideStarted:
      case NotificationType.accountPending:
      case NotificationType.accountGeneral:
        return const Color(0xFF3B82F6);

      // Unknown - Gray
      case NotificationType.unknown:
        return const Color(0xFF6B7280);
    }
  }

  // Get formatted time string (e.g., "Il y a 2 heures")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours ${hours == 1 ? 'heure' : 'heures'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days ${days == 1 ? 'jour' : 'jours'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks ${weeks == 1 ? 'semaine' : 'semaines'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months ${months == 1 ? 'mois' : 'mois'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years ${years == 1 ? 'an' : 'ans'}';
    }
  }

  // Check if notification should show badge (high priority)
  static bool shouldShowBadge(NotificationType type) {
    switch (type) {
      case NotificationType.passengerRideConfirmed:
      case NotificationType.passengerRideStarted:
      case NotificationType.driverRideConfirmed:
      case NotificationType.driverWalletDebit:
      case NotificationType.driverWalletCredit:
      case NotificationType.accountValidated:
      case NotificationType.accountRejected:
        return true;
      default:
        return false;
    }
  }

  // Get notification priority (for sorting or filtering)
  static int getPriority(NotificationType type) {
    switch (type) {
      // High priority - 3
      case NotificationType.passengerRideConfirmed:
      case NotificationType.passengerRideStarted:
      case NotificationType.driverRideConfirmed:
      case NotificationType.accountValidated:
      case NotificationType.accountRejected:
        return 3;

      // Medium priority - 2
      case NotificationType.passengerRideCompleted:
      case NotificationType.passengerRideCancelled:
      case NotificationType.driverRideCancelled:
      case NotificationType.driverWalletDebit:
      case NotificationType.driverWalletCredit:
      case NotificationType.driverSubscriptionExpiring:
        return 2;

      // Low priority - 1
      case NotificationType.accountPending:
      case NotificationType.accountLoyalty:
      case NotificationType.accountGeneral:
      case NotificationType.unknown:
        return 1;
    }
  }

  // Group notifications by category
  static Map<String, List<T>> groupByCategory<T>(
    List<T> items,
    String Function(T) getCategoryFn,
  ) {
    final Map<String, List<T>> grouped = {};

    for (final item in items) {
      final category = getCategoryFn(item);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }

    return grouped;
  }

  // Get localized category name
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'PASSENGER':
        return 'Passager';
      case 'DRIVER':
        return 'Chauffeur';
      case 'ACCOUNT':
        return 'Compte';
      default:
        return 'Autre';
    }
  }
}
