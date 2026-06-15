package com.srrfrr.api.enums;

import lombok.Getter;

/**
 * Enum representing all notification types with multilingual support.
 * Each type has a category prefix for filtering (DRIVER, PASSENGER, ACCOUNT).
 */
@Getter
public enum NotificationType {
    // Passenger notifications
    PASSENGER_RIDE_CONFIRMED(
            "PASSENGER",
            "تأكيد الرحلة", "Trajet confirmé", "Ride Confirmed",
            "تم تأكيد رحلتك", "Votre trajet a été confirmé", "Your ride has been confirmed"),
    PASSENGER_RIDE_STARTED(
            "PASSENGER",
            "بداية الرحلة", "Trajet commencé", "Ride Started",
            "بدأت رحلتك", "Votre trajet a commencé", "Your ride has started"),
    PASSENGER_RIDE_COMPLETED(
            "PASSENGER",
            "انتهاء الرحلة", "Trajet terminé", "Ride Completed",
            "تمت رحلتك بنجاح", "Votre trajet est terminé", "Your ride has been completed"),
    PASSENGER_RIDE_CANCELLED(
            "PASSENGER",
            "إلغاء الرحلة", "Trajet annulé", "Ride Cancelled",
            "تم إلغاء رحلتك", "Votre trajet a été annulé", "Your ride has been cancelled"),

    // Driver notifications
    DRIVER_RIDE_CONFIRMED(
            "DRIVER",
            "رحلة جديدة مؤكدة", "Nouveau trajet confirmé", "New Ride Confirmed",
            "قام راكب بتأكيد رحلة", "Un passager a confirmé un trajet", "A passenger has confirmed a ride"),
    DRIVER_RIDE_CANCELLED(
            "DRIVER",
            "إلغاء الرحلة", "Trajet annulé", "Ride Cancelled",
            "قام الراكب بإلغاء الرحلة", "Le passager a annulé le trajet", "The passenger cancelled the ride"),
    DRIVER_WALLET_DEBIT(
            "DRIVER",
            "خصم من المحفظة", "Débit du portefeuille", "Wallet Debited",
            "تم خصم مبلغ من محفظتك", "Montant débité de votre portefeuille", "Amount debited from your wallet"),
    DRIVER_WALLET_CREDIT(
            "DRIVER",
            "إضافة للمحفظة", "Crédit du portefeuille", "Wallet Credited",
            "تمت إضافة مبلغ لمحفظتك", "Montant crédité à votre portefeuille", "Amount credited to your wallet"),
    DRIVER_SUBSCRIPTION_EXPIRING(
            "DRIVER",
            "انتهاء الاشتراك قريباً", "Abonnement expirant", "Subscription Expiring",
            "اشتراكك على وشك الانتهاء", "Votre abonnement est sur le point d'expirer",
            "Your subscription is about to expire"),

    // Subscription Notifications
    DRIVER_SUBSCRIPTION_EXPIRED(
            "DRIVER",
            "انتهى الاشتراك", "Abonnement expiré", "Subscription Expired",
            "انتهى اشتراكك", "Votre abonnement a expiré", "Your subscription has expired"),
    DRIVER_SUBSCRIPTION_RENEWED(
            "DRIVER",
            "تجديد الاشتراك", "Abonnement renouvelé", "Subscription Renewed",
            "تم تجديد اشتراكك", "Votre abonnement a été renouvelé", "Your subscription has been renewed"),
    DRIVER_SUBSCRIPTION_RENEWAL_FAILED(
            "DRIVER",
            "فشل التجديد", "Échec du renouvellement", "Renewal Failed",
            "فشل تجديد الاشتراك", "Le renouvellement de l'abonnement a échoué", "Subscription renewal failed"),
    DRIVER_SUBSCRIPTION_EXPIRING_SOON(
            "DRIVER",
            "ينتهي قريباً", "Expire bientôt", "Expiring Soon",
            "ينتهي اشتراكك قريباً", "Votre abonnement expire bientôt", "Your subscription expires soon"),

    // Account notifications
    ACCOUNT_VALIDATED(
            "ACCOUNT",
            "تم التحقق من الحساب", "Compte validé", "Account Validated",
            "تم التحقق من حسابك", "Votre compte a été validé", "Your account has been validated"),
    ACCOUNT_REJECTED(
            "ACCOUNT",
            "رفض الحساب", "Compte rejeté", "Account Rejected",
            "تم رفض التحقق من حسابك", "La validation de votre compte a été rejetée",
            "Your account validation was rejected"),
    ACCOUNT_PENDING(
            "ACCOUNT",
            "حساب قيد المراجعة", "Compte en attente", "Account Pending",
            "حسابك قيد المراجعة", "Votre compte est en cours d'examen", "Your account is under review"),
    ACCOUNT_LOYALTY(
            "ACCOUNT",
            "نقاط الولاء", "Points de fidélité", "Loyalty Points",
            "تحديث نقاط الولاء", "Mise à jour des points de fidélité", "Loyalty points update"),
    ACCOUNT_GENERAL(
            "ACCOUNT",
            "تحديث الحساب", "Mise à jour du compte", "Account Update",
            "إشعار عام للحساب", "Notification générale du compte", "General account notification");

    private final String category;
    private final String defaultTitleAR;
    private final String defaultTitleFR;
    private final String defaultTitleEN;
    private final String defaultContentAR;
    private final String defaultContentFR;
    private final String defaultContentEN;

    NotificationType(String category,
            String defaultTitleAR, String defaultTitleFR, String defaultTitleEN,
            String defaultContentAR, String defaultContentFR, String defaultContentEN) {
        this.category = category;
        this.defaultTitleAR = defaultTitleAR;
        this.defaultTitleFR = defaultTitleFR;
        this.defaultTitleEN = defaultTitleEN;
        this.defaultContentAR = defaultContentAR;
        this.defaultContentFR = defaultContentFR;
        this.defaultContentEN = defaultContentEN;
    }

    /**
     * Get the full type name (e.g., "DRIVER_RIDE_CONFIRMED").
     */
    public String getTypeName() {
        return this.name();
    }

    /**
     * Check if this notification type belongs to a specific category.
     */
    public boolean isCategory(String categoryPrefix) {
        return this.category.equals(categoryPrefix);
    }

    /**
     * Parse notification type from string name.
     */
    public static NotificationType fromString(String typeName) {
        if (typeName == null || typeName.isBlank()) {
            throw new IllegalArgumentException("Notification type cannot be null or empty");
        }

        try {
            return NotificationType.valueOf(typeName.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid notification type: " + typeName);
        }
    }
}