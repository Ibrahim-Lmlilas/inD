// Notification Types - Matches Backend NotificationType Enum
//
// IMPORTANT: Keep in sync with backend com.srrfrr.api.enums.NotificationType

library;

enum NotificationType {
  // ============================================================================
  // PASSENGER NOTIFICATIONS
  // ============================================================================
  passengerRideConfirmed('PASSENGER_RIDE_CONFIRMED', 'PASSENGER'),
  passengerRideStarted('PASSENGER_RIDE_STARTED', 'PASSENGER'),
  passengerRideCompleted('PASSENGER_RIDE_COMPLETED', 'PASSENGER'),
  passengerRideCancelled('PASSENGER_RIDE_CANCELLED', 'PASSENGER'),

  // ============================================================================
  // DRIVER NOTIFICATIONS
  // ============================================================================
  driverRideConfirmed('DRIVER_RIDE_CONFIRMED', 'DRIVER'),
  driverRideCancelled('DRIVER_RIDE_CANCELLED', 'DRIVER'),
  driverWalletDebit('DRIVER_WALLET_DEBIT', 'DRIVER'),
  driverWalletCredit('DRIVER_WALLET_CREDIT', 'DRIVER'),
  driverSubscriptionExpiring('DRIVER_SUBSCRIPTION_EXPIRING', 'DRIVER'),

  // ============================================================================
  // ACCOUNT NOTIFICATIONS (Both Passenger & Driver)
  // ============================================================================
  accountValidated('ACCOUNT_VALIDATED', 'ACCOUNT'),
  accountRejected('ACCOUNT_REJECTED', 'ACCOUNT'),
  accountPending('ACCOUNT_PENDING', 'ACCOUNT'),
  accountLoyalty('ACCOUNT_LOYALTY', 'ACCOUNT'),
  accountGeneral('ACCOUNT_GENERAL', 'ACCOUNT'),

  // ============================================================================
  // UNKNOWN/FALLBACK
  // ============================================================================
  unknown('UNKNOWN', 'UNKNOWN');

  final String value;
  final String category;

  const NotificationType(this.value, this.category);

  // Parse notification type from backend string
  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => NotificationType.unknown,
    );
  }

  // Check if notification belongs to PASSENGER category
  bool get isPassengerNotification => category == 'PASSENGER';

  // Check if notification belongs to DRIVER category
  bool get isDriverNotification => category == 'DRIVER';

  // Check if notification belongs to ACCOUNT category (shown to both)
  bool get isAccountNotification => category == 'ACCOUNT';

  // Get user-friendly display name
  String get displayName {
    switch (this) {
      case NotificationType.passengerRideConfirmed:
        return 'Course confirmée';
      case NotificationType.passengerRideStarted:
        return 'Course démarrée';
      case NotificationType.passengerRideCompleted:
        return 'Course terminée';
      case NotificationType.passengerRideCancelled:
        return 'Course annulée';
      case NotificationType.driverRideConfirmed:
        return 'Nouvelle course';
      case NotificationType.driverRideCancelled:
        return 'Course annulée';
      case NotificationType.driverWalletDebit:
        return 'Débit portefeuille';
      case NotificationType.driverWalletCredit:
        return 'Crédit portefeuille';
      case NotificationType.driverSubscriptionExpiring:
        return 'Abonnement expirant';
      case NotificationType.accountValidated:
        return 'Compte validé';
      case NotificationType.accountRejected:
        return 'Compte rejeté';
      case NotificationType.accountPending:
        return 'Compte en attente';
      case NotificationType.accountLoyalty:
        return 'Points de fidélité';
      case NotificationType.accountGeneral:
        return 'Notification';
      case NotificationType.unknown:
        return 'Notification';
    }
  }
}
