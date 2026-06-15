package com.srrfrr.api.services.ride;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.domain.ride.CommissionCalculator;
import com.srrfrr.api.domain.ride.CommissionCalculator.CommissionResult;
import com.srrfrr.api.domain.ride.RidePaymentHandler;
import com.srrfrr.api.domain.ride.RidePricingService;
import com.srrfrr.api.domain.ride.RideValidationService;
import com.srrfrr.api.domain.ride.RideValidationService.ValidationResult;
import com.srrfrr.api.dto.ride.RideDTO;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.Wallet.TransactionType;
import com.srrfrr.api.mapper.RideMapper;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.repositories.main.subscription.DriverSubscriptionRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.notification.NotificationService;
import com.srrfrr.api.services.payment.WalletService;
import com.srrfrr.api.services.referral.InviteService;
import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.model.RideOffer;
import jakarta.persistence.criteria.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Application service for ride management.
 * Orchestrates domain services and handles persistence.
 */
@Service
@Slf4j
public class RideService {
    private final DriverRepository driverRepository;
    private final RideRepository rideRepository;
    private final PassengerRepository passengerRepository;
    private final ObjectMapper objectMapper;
    private final NotificationService notificationService;
    private final DriverSubscriptionRepository driverSubscriptionRepository;
    private final WalletService walletService;
    private final InviteService inviteService;
    private final RideMapper rideMapper; // Added

    // Domain services
    private final RidePricingService pricingService;
    private final CommissionCalculator commissionCalculator;
    private final RideValidationService validationService;
    private final RidePaymentHandler ridePaymentHandler;

    public RideService(
            final RideRepository rideRepository,
            final DriverRepository driverRepository,
            final PassengerRepository passengerRepository,
            final NotificationService notificationService,
            final ObjectMapper objectMapper,
            final DriverSubscriptionRepository driverSubscriptionRepository,
            final WalletService walletService,
            final InviteService inviteService,
            final RidePaymentHandler ridePaymentHandler,
            final RidePricingService pricingService,
            final CommissionCalculator commissionCalculator,
            final RideValidationService validationService,
            final RideMapper rideMapper) { // Added
        this.rideRepository = rideRepository;
        this.driverRepository = driverRepository;
        this.objectMapper = objectMapper;
        this.passengerRepository = passengerRepository;
        this.notificationService = notificationService;
        this.driverSubscriptionRepository = driverSubscriptionRepository;
        this.walletService = walletService;
        this.inviteService = inviteService;
        this.ridePaymentHandler = ridePaymentHandler;
        this.pricingService = pricingService;
        this.commissionCalculator = commissionCalculator;
        this.validationService = validationService;
        this.rideMapper = rideMapper; // Added
    }

    @Transactional
    public Ride saveRide(RideOffer offer, RideStatus status) {
        try {
            // 1. Validate offer structure
            ValidationResult offerValidation = validationService.validateRideOffer(offer);
            offerValidation.throwIfInvalid();

            // 2. Retrieve entities
            Passenger passenger = passengerRepository.findById(UUID.fromString(offer.getPassengerId()))
                    .orElseThrow(() -> new IllegalStateException("Passenger not found"));

            Driver driver = null;
            if (offer.getAcceptedDriverId() != null) {
                driver = driverRepository.findById(UUID.fromString(offer.getAcceptedDriverId()))
                        .orElseThrow(() -> new IllegalStateException("Driver not found"));
            }

            // 3. Process payment (when ride is actually accepted)
            RidePaymentHandler.PaymentResult paymentResult = ridePaymentHandler.processPayment(
                    passenger,
                    offer.getPaymentType(),
                    offer.getPrice());

            // 4. Update offer with payment info
            offer.setFreeRide(paymentResult.isFreeRide());

            // 5. Generate or parse ride ID
            UUID rideId = parseOrGenerateRideId(offer.getRideId());

            // 6. Create ride entity
            Ride ride = buildRideEntity(
                    rideId,
                    passenger,
                    driver,
                    offer,
                    status);

            // Check for duplicate
            if (rideRepository.existsById(ride.getId())) {
                throw new IllegalStateException("Ride ID already exists: " + ride.getId());
            }

            ride = rideRepository.save(ride);
            log.debug("Ride {} saved with status {} (free ride: {}, price: {} DH, points used: {})",
                    offer.getRideId(), status, paymentResult.isFreeRide(),
                    offer.getPrice(), paymentResult.getPointsUsed());

            // 7. Update ride counts
            updateRideCounts(passenger, driver);

            // 8. Handle driver commission
            if (driver != null && status == RideStatus.ACCEPTED) {
                processDriverCommission(driver, offer.getPrice());
            }

            // 9. Send notifications
            if (driver != null && status == RideStatus.ACCEPTED) {
                sendRideNotifications(driver, paymentResult);
                notificationService.notifyPassengerRideConfirmed(ride.getPassengerId());
            }

            return ride;

        } catch (Exception e) {
            DebugConsole.methodError("RideService", "saveRide",
                    String.format("Failed to save ride %s", offer.getRideId()), e);
            throw e;
        }
    }

    @Transactional
    public void updateRideStatus(UUID rideId, RideStatus newStatus) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        RideStatus oldStatus = ride.getStatus();
        ride.setStatus(newStatus);
        ride.setUpdatedAt(LocalDateTime.now());
        rideRepository.save(ride);

        log.info("Ride {} updated from {} to {}", rideId, oldStatus, newStatus);

        // Send ride status notifications
        if (newStatus == RideStatus.STARTED) {
            notificationService.notifyPassengerRideStarted(ride.getPassengerId());
        } else if (newStatus == RideStatus.COMPLETED) {
            notificationService.notifyPassengerRideCompleted(ride.getPassengerId());
        } else if (newStatus == RideStatus.CANCELED) {
            notificationService.notifyPassengerRideCancelled(ride.getPassengerId());
            if (ride.getDriverId() != null) {
                notificationService.notifyDriverRideCancelled(ride.getDriverId());
            }
        }

        // Check if this is the first completed ride for passenger or driver
        if (newStatus == RideStatus.COMPLETED && oldStatus != RideStatus.COMPLETED) {
            handleFirstRideCompletion(ride);
        }
    }

    /**
     * Handle referral rewards when a user completes their first ride.
     * Checks both passenger and driver roles.
     */
    private void handleFirstRideCompletion(Ride ride) {
        try {
            // Check passenger's first completed ride
            Passenger passenger = passengerRepository.findById(ride.getPassengerId())
                    .orElse(null);

            if (passenger != null) {
                long passengerCompletedRides = rideRepository.countCompletedRidesByPassenger(passenger.getId());
                if (passengerCompletedRides == 1) {
                    log.info("First ride completed by passenger {} - checking for referral rewards", passenger.getId());
                    inviteService.awardReferralPointsForFirstRide(passenger);
                }
            }

            // Check driver's first completed ride (if driver exists)
            if (ride.getDriverId() != null) {
                Driver driver = driverRepository.findById(ride.getDriverId()).orElse(null);
                if (driver != null && driver.getPassenger() != null) {
                    long driverCompletedRides = rideRepository.countCompletedRidesByDriver(driver.getId());
                    if (driverCompletedRides == 1) {
                        log.info("First ride completed by driver {} - checking for referral rewards", driver.getId());
                        inviteService.awardReferralPointsForFirstRide(driver.getPassenger());
                    }
                }
            }
        } catch (Exception e) {
            // Don't let referral processing break ride completion
            log.error("Error processing referral rewards for ride {}", ride.getId(), e);
        }
    }

    // Helper methods for clarity

    private UUID parseOrGenerateRideId(String rideIdStr) {
        try {
            return UUID.fromString(rideIdStr);
        } catch (Exception e) {
            return UUID.randomUUID();
        }
    }

    private Ride buildRideEntity(
            UUID rideId,
            Passenger passenger,
            Driver driver,
            RideOffer offer,
            RideStatus status) {

        return Ride.builder()
                .id(rideId)
                .passengerId(passenger.getId())
                .driverId(driver != null ? driver.getId() : null)
                .departureAddress(offer.getDepartureAddress())
                .departureLat(offer.getFromLat())
                .departureLng(offer.getFromLng())
                .departureCity(offer.getDepartureCity())
                .destinationAddress(offer.getDestinationAddress())
                .destinationLat(offer.getToLat())
                .destinationLng(offer.getToLng())
                .destinationCity(offer.getDestinationCity())
                .price(offer.getPrice())
                .rideType(offer.getRideType())
                .vehicleType(VehicleType.valueOf(offer.getVehicleType()))
                .seats(offer.getSeats())
                .distanceKm(offer.getDistanceKm())
                .estimatedTime(offer.getEstimatedTime())
                .paymentType(offer.getPaymentType())
                .status(status)
                .build();
    }

    private void updateRideCounts(Passenger passenger, Driver driver) {
        passenger.setTotalRides(passenger.getTotalRides() + 1);
        if (driver != null) {
            driver.setTotalRides(driver.getTotalRides() + 1);
        }
    }

    private void processDriverCommission(Driver driver, double ridePrice) {
        CommissionResult commissionResult = commissionCalculator.calculateCommission(driver, ridePrice);

        DriverSubscription activeSubscription = driver.getActiveSubscription();
        if (activeSubscription != null && activeSubscription.isActive()) {
            activeSubscription.incrementRideUsage();
            driverSubscriptionRepository.save(activeSubscription);

            log.info("Driver {} using {} subscription - {}",
                    driver.getId(),
                    activeSubscription.getSubscriptionPlan().getType(),
                    commissionResult.getReason());
        }

        if (commissionResult.hasCommission()) {
            Wallet driverWallet = walletService.getWallet(driver.getPassenger().getId());

            ValidationResult commissionValidation = validationService.validateDriverCommissionBalance(
                    driverWallet, commissionResult.getCommissionAmount());
            commissionValidation.throwIfInvalid();

            walletService.debit(driverWallet, commissionResult.getCommissionAmount(), TransactionType.COMMISSION);
            log.info("Commission of {} DH debited from driver {} wallet",
                    commissionResult.getCommissionAmount(), driver.getId());
        }
    }

    private void sendRideNotifications(Driver driver, RidePaymentHandler.PaymentResult paymentResult) {
        Passenger driverPassenger = driver.getPassenger();

        if (driverPassenger == null) {
            log.warn("Driver {} has no passenger associated for notification", driver.getId());
            return;
        }

        notificationService.notifyRideConfirmed(driverPassenger.getId());

        CommissionResult commissionResult = commissionCalculator.calculateCommission(
                driver,
                paymentResult.getRidePrice());

        if (commissionResult.hasCommission()) {
            notificationService.notifyWalletTransaction(
                    driverPassenger.getId(),
                    commissionResult.getCommissionAmount(),
                    TransactionType.COMMISSION);
        }

        log.info("Notifications sent to driver {} via passenger {}",
                driver.getId(), driverPassenger.getId());
    }

    public Ride getRideById(UUID rideId) {
        return rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));
    }

    public Ride getRideWithPassenger(UUID rideId) {
        return rideRepository.findByIdWithPassenger(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));
    }

    public double calculateRidePrice(double distanceKm) {
        return pricingService.calculateRidePrice(distanceKm);
    }

    /**
     * Get paginated ride history for passenger with advanced filters.
     */
    @Transactional(readOnly = true)
    public Page<RideDTO> getRidesForPassengerWithFilters(
            UUID passengerId,
            Pageable pageable,
            RideStatus status,
            PaymentType paymentType,
            String vehicleType,
            String driverName,
            LocalDateTime startDate,
            LocalDateTime endDate,
            Double minPrice,
            Double maxPrice) {

        log.debug("Fetching rides for passenger {} with filters", passengerId);

        Specification<Ride> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            predicates.add(cb.equal(root.get("passengerId"), passengerId));

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            if (paymentType != null) {
                predicates.add(cb.equal(root.get("paymentType"), paymentType));
            }

            if (vehicleType != null && !vehicleType.isEmpty()) {
                predicates.add(cb.equal(root.get("vehicleType"), vehicleType));
            }

            if (driverName != null && !driverName.isEmpty()) {
                Join<Ride, Driver> driverJoin = root.join("driver", JoinType.LEFT);
                Join<Driver, Passenger> passengerJoin = driverJoin.join("passenger", JoinType.LEFT);

                Predicate firstNameMatch = cb.like(
                        cb.lower(passengerJoin.get("firstName")),
                        "%" + driverName.toLowerCase() + "%");
                Predicate lastNameMatch = cb.like(
                        cb.lower(passengerJoin.get("lastName")),
                        "%" + driverName.toLowerCase() + "%");

                predicates.add(cb.or(firstNameMatch, lastNameMatch));
            }

            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), startDate));
            }
            if (endDate != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), endDate));
            }

            if (minPrice != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("price"), minPrice));
            }
            if (maxPrice != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("price"), maxPrice));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<Ride> rides = rideRepository.findAll(spec, pageable);

        // Use instance method with current user context
        return rides.map(ride -> rideMapper.toDTO(ride, passengerId));
    }

    /**
     * Get paginated ride history for driver with advanced filters.
     */
    @Transactional(readOnly = true)
    public Page<RideDTO> getRidesForDriverWithFilters(
            UUID driverId,
            Pageable pageable,
            RideStatus status,
            PaymentType paymentType,
            String vehicleType,
            String passengerName,
            LocalDateTime startDate,
            LocalDateTime endDate,
            Double minPrice,
            Double maxPrice) {

        log.debug("Fetching rides for driver {} with filters", driverId);

        Specification<Ride> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            predicates.add(cb.equal(root.get("driverId"), driverId));

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            if (paymentType != null) {
                predicates.add(cb.equal(root.get("paymentType"), paymentType));
            }

            if (vehicleType != null && !vehicleType.isEmpty()) {
                predicates.add(cb.equal(root.get("vehicleType"), vehicleType));
            }

            if (passengerName != null && !passengerName.isEmpty()) {
                Join<Ride, Passenger> passengerJoin = root.join("passenger", JoinType.LEFT);

                Predicate firstNameMatch = cb.like(
                        cb.lower(passengerJoin.get("firstName")),
                        "%" + passengerName.toLowerCase() + "%");
                Predicate lastNameMatch = cb.like(
                        cb.lower(passengerJoin.get("lastName")),
                        "%" + passengerName.toLowerCase() + "%");

                predicates.add(cb.or(firstNameMatch, lastNameMatch));
            }

            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), startDate));
            }
            if (endDate != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), endDate));
            }

            if (minPrice != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("price"), minPrice));
            }
            if (maxPrice != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("price"), maxPrice));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<Ride> rides = rideRepository.findAll(spec, pageable);

        // Get passenger ID for driver and use instance method
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new IllegalStateException("Driver not found"));

        UUID passengerIdForDriver = driver.getPassenger().getId();

        return rides.map(ride -> rideMapper.toDTO(ride, passengerIdForDriver));
    }

    public ObjectNode getRideStatusForUser(UUID rideId, Passenger user) {
        ObjectNode json = objectMapper.createObjectNode();

        if (rideId == null || user == null) {
            json.putNull("status");
            return json;
        }

        Ride ride = rideRepository.findById(rideId).orElse(null);

        if (ride == null) {
            json.putNull("status");
            return json;
        }

        boolean isPassenger = ride.getPassengerId().equals(user.getId());
        boolean isDriver = user.getDriverProfile() != null &&
                ride.getDriverId() != null &&
                ride.getDriverId().equals(user.getDriverProfile().getId());

        if (!isPassenger && !isDriver) {
            json.put("error", "Unauthorized");
            return json;
        }

        json.put("status", ride.getStatus().name());
        return json;
    }
}