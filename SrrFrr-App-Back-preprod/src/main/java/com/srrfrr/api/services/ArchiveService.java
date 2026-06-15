package com.srrfrr.api.services;

import com.srrfrr.api.entities.archive.*;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.exceptions.ArchiveException;
import com.srrfrr.api.repositories.archive.*;
import com.srrfrr.api.repositories.main.AuthenticationRepository;
import com.srrfrr.api.repositories.main.InviteRepository;
import com.srrfrr.api.repositories.main.NotificationRepository;
import com.srrfrr.api.repositories.main.ReclamationRepository;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.repositories.main.chat.ChatChannelRepository;
import com.srrfrr.api.repositories.main.chat.ChatMessageRepository;
import com.srrfrr.api.repositories.main.loyalty.LoyaltyTransactionRepository;
import com.srrfrr.api.repositories.main.rating.RatingRepository;
import com.srrfrr.api.repositories.main.subscription.DriverSubscriptionRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.repositories.main.wallet.WalletTransactionRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Service for archiving deleted user data using JPA.
 * Migrates user records from main schema to archive schema.
 * Archive schema has NO foreign key constraints for flexibility.
 * 
 * Process:
 * 1. Load all related entities from main schema
 * 2. Convert to archive entities (no FK relationships)
 * 3. Save to archive schema
 * 4. Delete from main schema (respecting FK constraints)
 */
@Service
@Slf4j
public class ArchiveService {

    @PersistenceContext
    private EntityManager entityManager;

    // Main schema repositories
    private final PassengerRepository passengerRepository;
    private final DriverRepository driverRepository;
    private final RideRepository rideRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final LoyaltyTransactionRepository loyaltyTransactionRepository;
    private final DriverSubscriptionRepository driverSubscriptionRepository;
    private final RatingRepository ratingRepository;
    private final ChatChannelRepository chatChannelRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final InviteRepository inviteRepository;
    private final NotificationRepository notificationRepository;
    private final ReclamationRepository reclamationRepository;
    private final AuthenticationRepository authenticationRepository;

    // Archive schema repositories
    private final ArchivePassengerRepository archivePassengerRepository;
    private final ArchiveDriverRepository archiveDriverRepository;
    private final ArchiveRideRepository archiveRideRepository;
    private final ArchiveWalletRepository archiveWalletRepository;
    private final ArchiveWalletTransactionRepository archiveWalletTransactionRepository;
    private final ArchiveLoyaltyTransactionRepository archiveLoyaltyTransactionRepository;
    private final ArchiveDriverSubscriptionRepository archiveDriverSubscriptionRepository;
    private final ArchiveRatingRepository archiveRatingRepository;
    private final ArchiveChatChannelRepository archiveChatChannelRepository;
    private final ArchiveChatMessageRepository archiveChatMessageRepository;
    private final ArchiveMessageFileRepository archiveMessageFileRepository;
    private final ArchiveInviteRepository archiveInviteRepository;
    private final ArchiveNotificationRepository archiveNotificationRepository;
    private final ArchiveReclamationRepository archiveReclamationRepository;

    public ArchiveService(
            PassengerRepository passengerRepository,
            DriverRepository driverRepository,
            RideRepository rideRepository,
            WalletTransactionRepository walletTransactionRepository,
            LoyaltyTransactionRepository loyaltyTransactionRepository,
            DriverSubscriptionRepository driverSubscriptionRepository,
            RatingRepository ratingRepository,
            ChatChannelRepository chatChannelRepository,
            ChatMessageRepository chatMessageRepository,
            InviteRepository inviteRepository,
            NotificationRepository notificationRepository,
            ReclamationRepository reclamationRepository,
            AuthenticationRepository authenticationRepository,
            ArchivePassengerRepository archivePassengerRepository,
            ArchiveDriverRepository archiveDriverRepository,
            ArchiveRideRepository archiveRideRepository,
            ArchiveWalletRepository archiveWalletRepository,
            ArchiveWalletTransactionRepository archiveWalletTransactionRepository,
            ArchiveLoyaltyTransactionRepository archiveLoyaltyTransactionRepository,
            ArchiveDriverSubscriptionRepository archiveDriverSubscriptionRepository,
            ArchiveRatingRepository archiveRatingRepository,
            ArchiveChatChannelRepository archiveChatChannelRepository,
            ArchiveChatMessageRepository archiveChatMessageRepository,
            ArchiveMessageFileRepository archiveMessageFileRepository,
            ArchiveInviteRepository archiveInviteRepository,
            ArchiveNotificationRepository archiveNotificationRepository,
            ArchiveReclamationRepository archiveReclamationRepository) {
        this.passengerRepository = passengerRepository;
        this.driverRepository = driverRepository;
        this.rideRepository = rideRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.loyaltyTransactionRepository = loyaltyTransactionRepository;
        this.driverSubscriptionRepository = driverSubscriptionRepository;
        this.ratingRepository = ratingRepository;
        this.chatChannelRepository = chatChannelRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.inviteRepository = inviteRepository;
        this.notificationRepository = notificationRepository;
        this.reclamationRepository = reclamationRepository;
        this.authenticationRepository = authenticationRepository;
        this.archivePassengerRepository = archivePassengerRepository;
        this.archiveDriverRepository = archiveDriverRepository;
        this.archiveRideRepository = archiveRideRepository;
        this.archiveWalletRepository = archiveWalletRepository;
        this.archiveWalletTransactionRepository = archiveWalletTransactionRepository;
        this.archiveLoyaltyTransactionRepository = archiveLoyaltyTransactionRepository;
        this.archiveDriverSubscriptionRepository = archiveDriverSubscriptionRepository;
        this.archiveRatingRepository = archiveRatingRepository;
        this.archiveChatChannelRepository = archiveChatChannelRepository;
        this.archiveChatMessageRepository = archiveChatMessageRepository;
        this.archiveMessageFileRepository = archiveMessageFileRepository;
        this.archiveInviteRepository = archiveInviteRepository;
        this.archiveNotificationRepository = archiveNotificationRepository;
        this.archiveReclamationRepository = archiveReclamationRepository;
    }

    /**
     * Archive a passenger and all related data.
     * 
     * @param passengerId the passenger ID to archive
     * @param reason reason for archiving (e.g., "USER_DELETION_REQUEST")
     * @throws ArchiveException if archival fails
     */
    @Transactional
    public void archivePassenger(UUID passengerId, String reason) {
        try {
            log.info("Starting archive process for passenger: {} (reason: {})", passengerId, reason);

            // Load passenger
            Passenger passenger = passengerRepository.findById(passengerId)
                    .orElseThrow(() -> new IllegalArgumentException("Passenger not found: " + passengerId));

            // If a transient (unsaved) Driver was set on this Passenger in the current
            // session (e.g. during a negotiation flow), Hibernate will attempt to flush it
            // before any subsequent query and throw TransientObjectException. Clear it here
            // since a transient driver has no persisted data to archive.
            if (passenger.getDriverProfile() != null && passenger.getDriverProfile().getId() == null) {
                passenger.setDriverProfile(null);
            }

            // Check if already archived
            if (archivePassengerRepository.existsById(passengerId)) {
                log.warn("Passenger {} already archived", passengerId);
                return;
            }

            // Step 1: Archive all related data (order doesn't matter - no FKs in archive)
            archivePassengerData(passenger);
            archiveDriverData(passenger);
            archiveRideData(passenger);
            archiveWalletData(passenger);
            archiveLoyaltyData(passenger);
            archiveRatingData(passenger);
            archiveChatData(passenger);
            archiveInviteData(passenger);
            archiveNotificationData(passenger);
            archiveReclamationData(passenger);

            // Step 2: Delete from main schema (respecting FK constraints)
            deleteFromMainSchema(passenger);

            log.info("Successfully archived and deleted passenger: {}", passengerId);

        } catch (IllegalArgumentException e) {
            log.error("Failed to archive passenger {}: {}", passengerId, e.getMessage(), e);
            throw e;
        } catch (Exception e) {
            log.error("Failed to archive passenger {}: {}", passengerId, e.getMessage(), e);
            throw new ArchiveException("Failed to archive passenger: " + e.getMessage(), e);
        }
    }

    /**
     * Archive passenger record.
     */
    private void archivePassengerData(Passenger passenger) {
        ArchivePassenger archive = ArchivePassenger.fromMain(passenger);
        archivePassengerRepository.save(archive);
        log.debug("Archived passenger: {}", passenger.getId());
    }

    /**
     * Archive driver profile if exists.
     */
    private void archiveDriverData(Passenger passenger) {
        if (passenger.getDriverProfile() == null) {
            log.debug("No driver profile to archive for passenger: {}", passenger.getId());
            return;
        }

        Driver driver = passenger.getDriverProfile();

        // Archive driver profile
        ArchiveDriver archiveDriver = ArchiveDriver.fromMain(driver);
        archiveDriverRepository.save(archiveDriver);

        // Archive driver subscriptions
        List<DriverSubscription> subscriptions = driverSubscriptionRepository
                .findByDriverOrderByCreatedAtDesc(driver);

        List<ArchiveDriverSubscription> archiveSubscriptions = subscriptions.stream()
                .map(ArchiveDriverSubscription::fromMain)
                .toList();

        archiveDriverSubscriptionRepository.saveAll(archiveSubscriptions);

        log.debug("Archived driver profile and {} subscriptions", archiveSubscriptions.size());
    }

    /**
     * Archive rides (as passenger and driver).
     */
    private void archiveRideData(Passenger passenger) {
        List<Ride> passengerRides = rideRepository.findByPassengerIdOrderByCreatedAtDesc(passenger.getId());
        
        List<Ride> driverRides = passenger.getDriverProfile() != null ?
                rideRepository.findByDriverIdOrderByCreatedAtDesc(passenger.getDriverProfile().getId()) :
                List.of();

        // Combine and deduplicate rides
        List<Ride> allRides = new ArrayList<>(passengerRides);
        allRides.addAll(driverRides);
        List<Ride> uniqueRides = allRides.stream()
                .distinct()
                .toList();

        List<ArchiveRide> archiveRides = uniqueRides.stream()
                .map(ArchiveRide::fromMain)
                .toList();

        archiveRideRepository.saveAll(archiveRides);
        log.debug("Archived {} rides", archiveRides.size());
    }

    /**
     * Archive wallets and transactions.
     */
    private void archiveWalletData(Passenger passenger) {
        // Only archive driver wallet if driver profile exists
        if (passenger.getDriverProfile() == null) {
            log.debug("No driver profile, skipping wallet archival for passenger: {}", passenger.getId());
            return;
        }

        Driver driver = passenger.getDriverProfile();
        Wallet wallet = driver.getWallet();

        if (wallet != null) {
            // Archive wallet
            ArchiveWallet archiveWallet = ArchiveWallet.fromMain(wallet);
            archiveWalletRepository.save(archiveWallet);

            // Archive wallet transactions
            List<WalletTransaction> transactions = walletTransactionRepository.findByWalletId(wallet.getId());
            List<ArchiveWalletTransaction> archiveTransactions = transactions.stream()
                    .map(ArchiveWalletTransaction::fromMain)
                    .toList();

            archiveWalletTransactionRepository.saveAll(archiveTransactions);

            log.debug("Archived driver wallet with {} transactions", archiveTransactions.size());
        } else {
            log.debug("No wallet found for driver {}", driver.getId());
        }
    }

    /**
     * Archive loyalty transactions.
     */
    private void archiveLoyaltyData(Passenger passenger) {
        List<LoyaltyTransaction> transactions = loyaltyTransactionRepository
                .findByPassengerIdOrderByCreatedAtDesc(passenger.getId(), Pageable.unpaged())
                .getContent();

        List<ArchiveLoyaltyTransaction> archiveTransactions = transactions.stream()
                .map(ArchiveLoyaltyTransaction::fromMain)
                .toList();

        archiveLoyaltyTransactionRepository.saveAll(archiveTransactions);
        log.debug("Archived {} loyalty transactions", archiveTransactions.size());
    }

    /**
     * Archive ratings (given and received).
     */
    private void archiveRatingData(Passenger passenger) {
        // Get ratings where passenger is sender or receiver
        List<Rating> sentRatings = ratingRepository.findBySenderId(passenger.getId());
        List<Rating> receivedRatings = ratingRepository.findByReceiverId(passenger.getId());

        // Combine and deduplicate
        List<Rating> allRatings = new ArrayList<>(sentRatings);
        allRatings.addAll(receivedRatings);
        List<Rating> uniqueRatings = allRatings.stream()
                .distinct()
                .toList();

        List<ArchiveRating> archiveRatings = uniqueRatings.stream()
                .map(ArchiveRating::fromMain)
                .toList();

        archiveRatingRepository.saveAll(archiveRatings);
        log.debug("Archived {} ratings", archiveRatings.size());
    }

    /**
     * Archive chat data (channels, messages, files).
     */
    private void archiveChatData(Passenger passenger) {
        UUID passengerId = passenger.getId();

        // Find all chat channels where user participated
        List<ChatChannel> channels = chatChannelRepository.findActiveChannelsByUserId(passengerId);

        for (ChatChannel channel : channels) {
            // Archive channel
            ArchiveChatChannel archiveChannel = ArchiveChatChannel.fromMain(channel);
            archiveChatChannelRepository.save(archiveChannel);

            // Archive messages
            List<ChatMessage> messages = chatMessageRepository
                    .findByChannelIdOrderBySentAtDesc(channel.getId(), Pageable.unpaged())
                    .getContent();

            List<ArchiveChatMessage> archiveMessages = messages.stream()
                    .map(ArchiveChatMessage::fromMain)
                    .toList();

            archiveChatMessageRepository.saveAll(archiveMessages);

            // Archive message files
            for (ChatMessage message : messages) {
                if (message.getFile() != null) {
                    ArchiveMessageFile archiveFile = ArchiveMessageFile.fromMain(message.getFile());
                    archiveMessageFileRepository.save(archiveFile);
                }
            }
        }

        log.debug("Archived {} chat channels", channels.size());
    }

    /**
     * Archive invites.
     */
    private void archiveInviteData(Passenger passenger) {
        List<Invite> invites = inviteRepository.findAllByInviter(passenger);

        List<ArchiveInvite> archiveInvites = invites.stream()
                .map(ArchiveInvite::fromMain)
                .toList();

        archiveInviteRepository.saveAll(archiveInvites);
        log.debug("Archived {} invites", archiveInvites.size());
    }

    /**
     * Archive notifications.
     */
    private void archiveNotificationData(Passenger passenger) {
        // Get all notifications for this passenger
        List<Notification> notifications = notificationRepository.findByReceiverId(passenger.getId());

        List<ArchiveNotification> archiveNotifications = notifications.stream()
                .map(ArchiveNotification::fromMain)
                .toList();

        archiveNotificationRepository.saveAll(archiveNotifications);
        log.debug("Archived {} notifications", archiveNotifications.size());
    }

    /**
     * Archive reclamations.
     */
    private void archiveReclamationData(Passenger passenger) {
        List<Reclamation> reclamations = reclamationRepository
                .findByPassengerIdOrderByCreatedAtDesc(passenger.getId());

        List<ArchiveReclamation> archiveReclamations = reclamations.stream()
                .map(ArchiveReclamation::fromMain)
                .toList();

        archiveReclamationRepository.saveAll(archiveReclamations);
        log.debug("Archived {} reclamations", archiveReclamations.size());
    }

    /**
     * Delete all data from main schema in correct order to respect FK constraints.
     * 
     * Deletion order (respects foreign key constraints):
     * 1. Child records first (messages, transactions, etc.)
     * 2. Junction/relationship records (ratings, invites)
     * 3. Parent records last (passenger, driver)
     */
    private void deleteFromMainSchema(Passenger passenger) {
        log.info("Deleting passenger {} from main schema", passenger.getId());

        UUID passengerId = passenger.getId();

        // 1. Delete chat messages and files (cascade handles files via OneToOne)
        List<ChatChannel> channels = chatChannelRepository.findActiveChannelsByUserId(passengerId);
        for (ChatChannel channel : channels) {
            chatMessageRepository.deleteAll(
                chatMessageRepository.findByChannelIdOrderBySentAtDesc(
                    channel.getId(), 
                    Pageable.unpaged()
                ).getContent()
            );
        }

        // 2. Delete chat channels
        chatChannelRepository.deleteAll(channels);

        // 3. Delete reclamations (references passenger)
        reclamationRepository.deleteAll(
            reclamationRepository.findByPassengerIdOrderByCreatedAtDesc(passengerId)
        );

        // 4. Delete notifications (references passenger as receiver)
        notificationRepository.deleteAll(
            notificationRepository.findByReceiverId(passengerId)
        );

        // 5. Delete invites (references passenger as inviter)
        inviteRepository.deleteAll(inviteRepository.findAllByInviter(passenger));

        // 6. Delete ratings (references passenger as sender/receiver)
        ratingRepository.deleteAll(ratingRepository.findBySenderId(passengerId));
        ratingRepository.deleteAll(ratingRepository.findByReceiverId(passengerId));

        // 7. Handle rides - nullify references instead of deleting
        // This preserves ride history for other participants
        List<Ride> passengerRides = rideRepository.findByPassengerIdOrderByCreatedAtDesc(passengerId);
        passengerRides.forEach(ride -> ride.setPassengerId(null));
        rideRepository.saveAll(passengerRides);

        if (passenger.getDriverProfile() != null) {
            UUID driverId = passenger.getDriverProfile().getId();
            List<Ride> driverRides = rideRepository.findByDriverIdOrderByCreatedAtDesc(driverId);
            driverRides.forEach(ride -> ride.setDriverId(null));
            rideRepository.saveAll(driverRides);
        }

        // Delete orphaned rides (both passenger and driver are null)
        rideRepository.deleteAll(
            rideRepository.findAll().stream()
                .filter(r -> r.getPassengerId() == null && r.getDriverId() == null)
                .toList()
        );

        // 8. Delete loyalty transactions (references passenger)
        loyaltyTransactionRepository.deleteAll(
            loyaltyTransactionRepository.findByPassengerIdOrderByCreatedAtDesc(
                passengerId, 
                Pageable.unpaged()
            ).getContent()
        );

        // Capture driver reference once; used across steps 9-11 after driverProfile is nulled.
        Driver driverToDelete = passenger.getDriverProfile();

        // 9. Delete wallet transactions (driver wallet; cascade deletes Wallet entity itself)
        if (driverToDelete != null) {
            Wallet wallet = driverToDelete.getWallet();
            if (wallet != null) {
                walletTransactionRepository.deleteAll(
                        walletTransactionRepository.findByWalletId(wallet.getId()));
            }
            // Null the active-subscription FK on Driver so the subscription row can be
            // deleted first without violating the driver.active_subscription_id → driver_subscription.id
            // FK constraint. The auto-flush before the next query will write this UPDATE.
            if (driverToDelete.getActiveSubscription() != null) {
                driverToDelete.setActiveSubscription(null);
            }
        }

        // 10. Delete driver subscriptions before driver (FK: driver_subscription.driver_id → driver.id)
        if (driverToDelete != null) {
            driverSubscriptionRepository.deleteAll(
                driverSubscriptionRepository.findByDriverOrderByCreatedAtDesc(driverToDelete)
            );
        }

        // 11. Delete driver profile (Wallet cascades via CascadeType.ALL on Driver.wallet).
        //     Null driverProfile immediately so the next query's pre-flush CHECK_ON_FLUSH
        //     does not find a non-contained (REMOVED) Driver on the Passenger and throw
        //     TransientObjectException.
        if (driverToDelete != null) {
            driverRepository.delete(driverToDelete);
            passenger.setDriverProfile(null);
        }

        // 12. Delete authentication (references passenger)
        authenticationRepository.findByPassenger(passenger)
                .ifPresent(authenticationRepository::delete);

        // 13. Flush all pending SQL while the Passenger is still MANAGED (no transient
        //     references at this point), then clear the session. Without this, Ride entities
        //     left in the session from cancelActiveRides hold lazy passenger proxies that
        //     Hibernate's CHECK_ON_FLUSH catches as transient after the Passenger is removed,
        //     causing TransientObjectException on the commit flush.
        entityManager.flush();
        entityManager.clear();

        // 14. Delete passenger (all FK references resolved; fresh load after clear)
        passengerRepository.deleteById(passengerId);

        log.info("Successfully deleted passenger {} from main schema", passengerId);
    }

    /**
     * Check if passenger exists in main schema.
     */
    public boolean passengerExists(UUID passengerId) {
        return passengerRepository.existsById(passengerId);
    }

    /**
     * Check if passenger is already archived.
     */
    public boolean isAlreadyArchived(UUID passengerId) {
        return archivePassengerRepository.existsById(passengerId);
    }
}