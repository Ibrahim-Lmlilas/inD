package com.srrfrr.api.services.notification;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.srrfrr.api.configurations.FirebaseMessagingConf;
import com.srrfrr.api.dto.notification.NotificationRequest;
import com.srrfrr.api.dto.notification.NotificationResponse;
import com.srrfrr.api.entities.main.Authentication;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Notification;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.enums.NotificationType;
import com.srrfrr.api.enums.Wallet.TransactionType;
import com.srrfrr.api.enums.user.Language;
import com.srrfrr.api.repositories.main.AuthenticationRepository;
import com.srrfrr.api.repositories.main.NotificationRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.websocket.handler.NotificationSocketHandler;
import jakarta.persistence.EntityNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.TextMessage;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service for notification operations.
 * All notification types are now enforced through NotificationType enum.
 */
@Slf4j
@Service
public class NotificationService {

    private final NotificationRepository notificationRepo;
    private final PassengerRepository passengerRepository;
    private final DriverRepository driverRepository;
    private final AuthenticationRepository authenticationRepository;
    private final FirebaseMessagingConf firebaseMessaging;
    private final NotificationSocketHandler socketHandler;
    private final ObjectMapper objectMapper;

    public NotificationService(
            final NotificationRepository notificationRepo,
            final PassengerRepository passengerRepository,
            final DriverRepository driverRepository,
            final AuthenticationRepository authenticationRepository,
            final NotificationSocketHandler socketHandler,
            final FirebaseMessagingConf firebaseMessaging,
            final ObjectMapper objectMapper) {
        this.notificationRepo = notificationRepo;
        this.passengerRepository = passengerRepository;
        this.driverRepository = driverRepository;
        this.socketHandler = socketHandler;
        this.authenticationRepository = authenticationRepository;
        this.firebaseMessaging = firebaseMessaging;
        this.objectMapper = objectMapper;
    }

    /**
     * Unified method to send all types of notifications.
     * Type is enforced through enum.
     */
    @Transactional
    public void sendNotification(NotificationRequest request) {
        Passenger receiver = passengerRepository.findById(request.getReceiverId())
                .orElseThrow(() -> new EntityNotFoundException("Receiver not found"));

        // 1. Save to database
        Notification notification = createNotificationEntity(request, receiver);
        notification = notificationRepo.save(notification);

        // 2. Send via WebSocket (real-time)
        sendWebSocketNotification(notification);

        // 3. Send via Firebase (push notification)
        Language lang = receiver.getLanguage() != null ? receiver.getLanguage() : Language.EN;
        String title = switch (lang) {
            case AR -> request.getTitleAR();
            case FR -> request.getTitleFR();
            default -> request.getTitleEN();
        };
        String content = switch (lang) {
            case AR -> request.getContentAR();
            case FR -> request.getContentFR();
            default -> request.getContentEN();
        };
        sendPushNotification(receiver, title, content);
    }

    /**
     * Convenience methods for common notification types.
     * Now use enum-based factory methods.
     */
    public void notifyRideConfirmed(UUID driverId) {
        NotificationRequest request = NotificationRequest.withDefaults(
            NotificationType.DRIVER_RIDE_CONFIRMED,
            driverId
        );
        sendNotification(request);
    }

    public void notifyPassengerRideConfirmed(UUID passengerId) {
        sendNotification(NotificationRequest.withDefaults(NotificationType.PASSENGER_RIDE_CONFIRMED, passengerId));
    }

    public void notifyPassengerRideStarted(UUID passengerId) {
        sendNotification(NotificationRequest.withDefaults(NotificationType.PASSENGER_RIDE_STARTED, passengerId));
    }

    public void notifyPassengerRideCompleted(UUID passengerId) {
        sendNotification(NotificationRequest.withDefaults(NotificationType.PASSENGER_RIDE_COMPLETED, passengerId));
    }

    public void notifyPassengerRideCancelled(UUID passengerId) {
        sendNotification(NotificationRequest.withDefaults(NotificationType.PASSENGER_RIDE_CANCELLED, passengerId));
    }

    public void notifyDriverRideCancelled(UUID driverPassengerId) {
        sendNotification(NotificationRequest.withDefaults(NotificationType.DRIVER_RIDE_CANCELLED, driverPassengerId));
    }

    public void notifyWalletTransaction(UUID userId, double amount, TransactionType type) {
        NotificationType notifType = type == TransactionType.CREDIT
                ? NotificationType.DRIVER_WALLET_CREDIT
                : NotificationType.DRIVER_WALLET_DEBIT;

        String contentAR = String.format("تم %s %.2f درهم %s محفظتك",
                type == TransactionType.CREDIT ? "إضافة" : "خصم",
                amount,
                type == TransactionType.CREDIT ? "إلى" : "من");

        String contentFR = String.format("%.2f DH %s votre portefeuille",
                amount,
                type == TransactionType.CREDIT ? "ajouté à" : "déduit de");

        String contentEN = String.format("%.2f DH has been %s your wallet",
                amount,
                type == TransactionType.CREDIT ? "added to" : "deducted from");

        NotificationRequest request = NotificationRequest.withCustomContent(
                notifType,
                userId,
                contentAR,
                contentFR,
                contentEN);
        sendNotification(request);
    }

    public void notifyLoyaltyPoints(UUID passengerId, int points, LoyaltyTransactionType type) {
        String contentAR = String.format("لقد %s %d نقطة ولاء",
                type == LoyaltyTransactionType.DEBIT ? "استخدمت" : "كسبت",
                points);

        String contentFR = String.format("Vous avez %s %d points de fidélité",
                type == LoyaltyTransactionType.DEBIT ? "utilisé" : "gagné",
                points);

        String contentEN = String.format("You've %s %d loyalty points",
                type == LoyaltyTransactionType.DEBIT ? "used" : "earned",
                points);

        NotificationRequest request = NotificationRequest.withCustomContent(
                NotificationType.ACCOUNT_LOYALTY,
                passengerId,
                contentAR,
                contentFR,
                contentEN);
        sendNotification(request);
    }
    
    /**
     * Notify driver about subscription expiration.
     */
    public void notifySubscriptionExpired(UUID driverId, String planType) {
        String contentAR = String.format("انتهى اشتراكك من نوع %s", planType);
        String contentFR = String.format("Votre abonnement %s a expiré", planType);
        String contentEN = String.format("Your %s subscription has expired", planType);

        NotificationRequest request = NotificationRequest.withCustomContent(
                NotificationType.DRIVER_SUBSCRIPTION_EXPIRED,
                driverId,
                contentAR,
                contentFR,
                contentEN);
        sendNotification(request);
    }

    /**
     * Notify driver about insufficient balance for renewal.
     */
    public void notifyInsufficientBalanceForRenewal(UUID driverId, String planType,
            double price, double currentBalance) {
        String contentAR = String.format(
                "لا يمكن تجديد اشتراك %s. المطلوب: %.2f درهم، الرصيد: %.2f درهم. يرجى شحن محفظتك.",
                planType, price, currentBalance);

        String contentFR = String.format(
                "Impossible de renouveler l'abonnement %s. Requis: %.2f DH, Solde: %.2f DH. Veuillez recharger votre portefeuille.",
                planType, price, currentBalance);

        String contentEN = String.format(
                "Cannot renew %s subscription. Required: %.2f DH, Balance: %.2f DH. Please top up your wallet.",
                planType, price, currentBalance);

        NotificationRequest request = NotificationRequest.withCustomContent(
                NotificationType.DRIVER_SUBSCRIPTION_RENEWAL_FAILED,
                driverId,
                contentAR,
                contentFR,
                contentEN);
        sendNotification(request);
    }

    /**
     * Notify driver about successful subscription renewal.
     */
    public void notifySubscriptionRenewed(UUID driverId, String planType,
            double price, LocalDateTime endDate) {
        String dateStr = endDate.toLocalDate().toString();

        String contentAR = String.format(
                "تم تجديد اشتراكك من نوع %s بمبلغ %.2f درهم. صالح حتى: %s",
                planType, price, dateStr);

        String contentFR = String.format(
                "Votre abonnement %s a été renouvelé pour %.2f DH. Valable jusqu'au: %s",
                planType, price, dateStr);

        String contentEN = String.format(
                "Your %s subscription has been renewed for %.2f DH. Valid until: %s",
                planType, price, dateStr);

        NotificationRequest request = NotificationRequest.withCustomContent(
                NotificationType.DRIVER_SUBSCRIPTION_RENEWED,
                driverId,
                contentAR,
                contentFR,
                contentEN);
        sendNotification(request);
    }

    /**
     * Get paginated notifications for passenger.
     * Returns notifications from the last 24 hours filtered by category.
     * 
     * @param passengerId the passenger ID
     * @param pageable pagination parameters
     * @return paginated notifications
     */
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getNotificationsForPassenger(UUID passengerId, Pageable pageable) {
        LocalDateTime oneDayAgo = LocalDateTime.now().minusDays(1);

        // Fetch all notifications and filter by category
        List<Notification> allNotifications = notificationRepo.findByReceiverAndDate(
            passengerId, 
            oneDayAgo
        );

        // Filter by PASSENGER and ACCOUNT categories
        List<Notification> filtered = allNotifications.stream()
            .filter(n -> "PASSENGER".equals(n.getCategory()) || "ACCOUNT".equals(n.getCategory()))
            .sorted(Comparator.comparing(Notification::getCreatedAt).reversed())
            .collect(Collectors.toList());

        // Apply pagination manually
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        
        List<Notification> pageContent = start < filtered.size() 
            ? filtered.subList(start, end) 
            : new ArrayList<>();

        // Convert to response DTOs
        List<NotificationResponse> responseList = pageContent.stream()
            .map(this::mapToResponse)
            .collect(Collectors.toList());

        if (filtered.isEmpty()) {
            log.info("No passenger notifications found for ID {} in the last 24 hours", passengerId);
        }

        return new PageImpl<>(responseList, pageable, filtered.size());
    }

    /**
     * Get paginated notifications for driver.
     * Returns notifications from the last 24 hours filtered by category.
     * 
     * @param driverId the driver ID
     * @param pageable pagination parameters
     * @return paginated notifications
     */
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getNotificationsForDriver(UUID driverId, Pageable pageable) {
        Driver driver = driverRepository.findById(driverId)
            .orElseThrow(() -> new IllegalArgumentException("Driver not found with ID: " + driverId));

        Passenger driverPassenger = driver.getPassenger();
        if (driverPassenger == null) {
            throw new IllegalStateException("Driver has no linked passenger account");
        }

        LocalDateTime oneDayAgo = LocalDateTime.now().minusDays(1);

        // Fetch all notifications and filter by category
        List<Notification> allNotifications = notificationRepo.findByReceiverAndDate(
            driverPassenger.getId(), 
            oneDayAgo
        );

        // Filter by DRIVER and ACCOUNT categories
        List<Notification> filtered = allNotifications.stream()
            .filter(n -> "DRIVER".equals(n.getCategory()) || "ACCOUNT".equals(n.getCategory()))
            .sorted(Comparator.comparing(Notification::getCreatedAt).reversed())
            .collect(Collectors.toList());

        // Apply pagination manually
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        
        List<Notification> pageContent = start < filtered.size() 
            ? filtered.subList(start, end) 
            : new ArrayList<>();

        // Convert to response DTOs
        List<NotificationResponse> responseList = pageContent.stream()
            .map(this::mapToResponse)
            .collect(Collectors.toList());

        if (filtered.isEmpty()) {
            log.info("No driver notifications found for driver ID {} in the last 24 hours", driverId);
        }

        return new PageImpl<>(responseList, pageable, filtered.size());
    }
    
    /**
     * Scheduled task to delete notifications older than 1 day.
     */
    @Scheduled(cron = "0 0 0 * * *")
    public void deleteOldNotifications() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(1);
        notificationRepo.deleteByCreatedAtBefore(cutoff);
        log.info("Notifications older than {} deleted", cutoff);
    }

    /**
     * Mark specific notification as read.
     */
    @Transactional
    public NotificationResponse markAsRead(UUID notificationId, UUID receiverId) {
        Notification notif = notificationRepo.findById(notificationId)
            .orElseThrow(() -> new IllegalArgumentException("Notification not found"));

        if (!notif.getReceiver().getId().equals(receiverId)) {
            throw new IllegalStateException("You do not have permission to modify this notification");
        }

        notif.setStatus("READ");
        notificationRepo.save(notif);

        return mapToResponse(notif);
    }

    /**
     * Mark all notifications as read for a user.
     */
    @Transactional
    public void markAllAsRead(UUID receiverId) {
        notificationRepo.markAllAsRead(receiverId);
    }

    /**
     * Create notification entity from request.
     * Type is enforced through enum.
     */
    private Notification createNotificationEntity(NotificationRequest request, Passenger receiver) {
        Notification notification = new Notification();
        notification.setReceiver(receiver);

        notification.setTitleAR(request.getTitleAR());
        notification.setTitleFR(request.getTitleFR());
        notification.setTitleEN(request.getTitleEN());

        notification.setContentAR(request.getContentAR());
        notification.setContentFR(request.getContentFR());
        notification.setContentEN(request.getContentEN());

        notification.setType(request.getType());
        notification.setStatus(request.getStatus());
        return notification;
    }

    /**
     * Send WebSocket notification for real-time updates.
     */
    private void sendWebSocketNotification(Notification notification) {
        try {
            NotificationResponse response = mapToResponse(notification);
            String payload = objectMapper.writeValueAsString(response);
            socketHandler.broadcastMessage(
                notification.getReceiver().getId().toString(),
                new TextMessage(payload)
            );
        } catch (IOException e) {
            log.error("Failed to send WebSocket notification", e);
        }
    }

    /**
     * Send Firebase push notification.
     * Handles UNREGISTERED tokens gracefully.
     */
    private void sendPushNotification(Passenger receiver, String title, String content) {
        try {
            Authentication auth = authenticationRepository.findByPassenger(receiver).orElse(null);
            if (auth == null) {
                log.warn("No authentication found for user: {}", receiver.getId());
                return;
            }

            if (auth.getFcmToken() == null || auth.getFcmToken().isBlank()) {
                log.warn("No FCM token found for user: {}", receiver.getId());
                return;
            }

            try {
                firebaseMessaging.sendMessage(auth.getFcmToken(), title, content);
                log.info("Push notification sent to user: {}", receiver.getId());
            } catch (FirebaseMessagingException e) {
                String errorCode = e.getMessagingErrorCode() != null
                        ? e.getMessagingErrorCode().name()
                        : "UNKNOWN";

                if ("UNREGISTERED".equals(errorCode)) {
                    log.warn("Token unregistered for user {}, clearing token", receiver.getId());
                    // auth.setFcmToken(null);
                    // authenticationRepository.save(auth);
                } else {
                    log.error("Failed to send push notification to {}: {}",
                            receiver.getId(), e.getMessage());
                }
            }
        } catch (Exception e) {
            log.error("Unexpected error sending push notification to {}: {}",
                    receiver.getId(), e.getMessage());
        }
    }

    /**
     * Map notification entity to response DTO.
     * Category is automatically set from enum.
     */
    private NotificationResponse mapToResponse(Notification notification) {
        NotificationResponse response = new NotificationResponse();
        response.setId(notification.getId());
        response.setCreatedAt(notification.getCreatedAt());

        response.setTitleAR(notification.getTitleAR());
        response.setTitleFR(notification.getTitleFR());
        response.setTitleEN(notification.getTitleEN());

        response.setContentAR(notification.getContentAR());
        response.setContentFR(notification.getContentFR());
        response.setContentEN(notification.getContentEN());

        response.setType(notification.getType());
        response.setCategory(notification.getCategory());
        response.setStatus(notification.getStatus());
        response.setReceiverId(notification.getReceiver().getId());
        return response;
    }
}