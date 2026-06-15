package com.srrfrr.api.services.subscription;

import com.srrfrr.api.domain.subscription.SubscriptionPlanCalculator;
import com.srrfrr.api.dto.subscription.*;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.SubscriptionStatus;
import com.srrfrr.api.enums.Wallet.TransactionType;
import com.srrfrr.api.exceptions.subscription.*;
import com.srrfrr.api.exceptions.user.DriverProfileNotFoundException;
import com.srrfrr.api.repositories.main.subscription.DriverSubscriptionRepository;
import com.srrfrr.api.repositories.main.subscription.SubscriptionPlanRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.services.notification.NotificationService;
import com.srrfrr.api.services.payment.WalletService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for subscription operations.
 * Handles driver subscriptions, payments, and subscription lifecycle
 * management.
 */
@Service
@Slf4j
public class SubscriptionService {
    private final DriverSubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository planRepository;
    private final DriverRepository driverRepository;
    private final WalletService walletService;
    private final NotificationService notificationService;
    private final SubscriptionPlanCalculator planCalculator;

    public SubscriptionService(
            final DriverSubscriptionRepository subscriptionRepository,
            final SubscriptionPlanRepository planRepository,
            final WalletService walletService,
            final DriverRepository driverRepository,
            final NotificationService notificationService,
            final SubscriptionPlanCalculator planCalculator) {
        this.subscriptionRepository = subscriptionRepository;
        this.planRepository = planRepository;
        this.walletService = walletService;
        this.driverRepository = driverRepository;
        this.notificationService = notificationService;
        this.planCalculator = planCalculator;
    }

    /**
     * Subscribe or resubscribe a driver to a subscription plan.
     * Allows resubscription even if driver previously had a subscription.
     * Only blocks if there's an ACTIVE subscription.
     * 
     * @param passenger the passenger (must have driver profile)
     * @param request   subscription request with plan type
     * @return subscription response
     * @throws DriverProfileRequiredException           if passenger has no driver
     *                                                  profile
     * @throws ActiveSubscriptionAlreadyExistsException if driver already has active
     *                                                  subscription
     * @throws SubscriptionPlanNotFoundException        if plan not found
     * @throws InsufficientWalletBalanceException       if wallet balance
     *                                                  insufficient
     */
    @Transactional
    public SubscriptionResponse subscribeDriver(Passenger passenger, SubscribeDriverRequest request) {
        if (passenger.getDriverProfile() == null) {
            throw new DriverProfileRequiredException(passenger.getId());
        }

        Driver driver = driverRepository.findById(passenger.getDriverProfile().getId())
                .orElseThrow(() -> new DriverProfileNotFoundException(
                        "Driver profile not found for passenger: " + passenger.getId()));

        Optional<DriverSubscription> existingSubscription = subscriptionRepository.findActiveSubscription(driver);
        if (existingSubscription.isPresent()) {
            throw new ActiveSubscriptionAlreadyExistsException(driver.getId());
        }

        SubscriptionPlan plan = planRepository.findByType(request.getPlanType())
                .orElseThrow(() -> new SubscriptionPlanNotFoundException(request.getPlanType()));

        try {
            processWalletPayment(driver, plan.getPrice());
        } catch (Exception e) {
            throw new SubscriptionPaymentException("Failed to process subscription payment", e);
        }

        // Check if this is first-time subscriber (never had any subscription before)
        boolean isFirstTimeSubscriber = !subscriptionRepository.existsByDriver(driver);

        // First-time subscribers get 60 days (2 months), others get 30 days
        int durationDays = isFirstTimeSubscriber ? 60 : planCalculator.getSubscriptionDuration(plan.getType());

        DriverSubscription subscription = DriverSubscription.builder()
                .driver(driver)
                .subscriptionPlan(plan)
                .startDate(LocalDateTime.now())
                .endDate(LocalDateTime.now().plusDays(durationDays))
                .status(SubscriptionStatus.ACTIVE)
                .ridesUsed(0)
                .build();

        subscription = subscriptionRepository.save(subscription);

        driver.setActiveSubscription(subscription);
        driverRepository.save(driver);

        String message = isFirstTimeSubscriber
                ? String.format(
                        "Welcome! First subscription comes with 2 months for the price of 1 (valid for %d days)",
                        durationDays)
                : "Subscription activated successfully";

        log.info("Driver {} subscribed to {} plan for {} DH - {} (valid until {})",
                driver.getId(),
                plan.getType(),
                plan.getPrice(),
                isFirstTimeSubscriber ? "FIRST-TIME PROMO (60 days)" : "REGULAR (30 days)",
                subscription.getEndDate());

        notificationService.notifyWalletTransaction(
                driver.getPassenger().getId(),
                plan.getPrice(),
                TransactionType.SUBSCRIPTION);

        return buildSubscriptionResponse(subscription, message);
    }

    /**
     * Get active subscription for a driver.
     * 
     * @param driverId the driver ID
     * @return subscription response or response indicating no active subscription
     * @throws DriverProfileNotFoundException if driver not found
     */
    @Transactional(readOnly = true)
    public SubscriptionResponse getActiveSubscription(UUID driverId) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new DriverProfileNotFoundException(
                        "Driver not found with ID: " + driverId));

        DriverSubscription subscription = subscriptionRepository.findActiveSubscription(driver)
                .orElse(null);

        if (subscription == null) {
            return SubscriptionResponse.builder()
                    .driverId(driverId)
                    .message("No active subscription")
                    .build();
        }

        return buildSubscriptionResponse(subscription, "Active subscription found");
    }

    /**
     * Get paginated subscription history for a driver.
     * Returns subscriptions in reverse chronological order.
     * 
     * @param passengerId the passenger ID
     * @param pageable    pagination parameters
     * @return paginated subscription history
     * @throws DriverProfileNotFoundException if driver not found
     */
    @Transactional(readOnly = true)
    public Page<SubscriptionResponse> getSubscriptionHistory(UUID passengerId, Pageable pageable) {
        // Get driver by passenger ID
        Driver driver = driverRepository.findByPassengerId(passengerId)
                .orElseThrow(() -> new DriverProfileNotFoundException(
                        "Driver profile not found for passenger: " + passengerId));

        Page<DriverSubscription> subscriptions = subscriptionRepository
                .findByDriverOrderByCreatedAtDesc(driver, pageable);

        return subscriptions.map(sub -> buildSubscriptionResponse(sub, null));
    }

    /**
     * Change subscription plan.
     * Cancels current subscription and creates new one immediately.
     * 
     * @param passenger the passenger (must have driver profile)
     * @param request   new subscription plan request
     * @return new subscription response
     * @throws DriverProfileNotFoundException      if driver not found
     * @throws ActiveSubscriptionNotFoundException if no active subscription
     * @throws SameSubscriptionPlanException       if requesting same plan
     * @throws SubscriptionPlanNotFoundException   if new plan not found
     * @throws InsufficientWalletBalanceException  if wallet balance insufficient
     */
    @Transactional
    public SubscriptionResponse changeSubscription(Passenger passenger, SubscribeDriverRequest request) {
        // Verify driver profile exists
        if (passenger.getDriverProfile() == null) {
            throw new DriverProfileRequiredException(passenger.getId());
        }

        Driver driver = driverRepository.findById(passenger.getDriverProfile().getId())
                .orElseThrow(() -> new DriverProfileNotFoundException(
                        "Driver profile not found for passenger: " + passenger.getId()));

        // Get current subscription
        DriverSubscription current = subscriptionRepository.findActiveSubscription(driver)
                .orElseThrow(() -> new ActiveSubscriptionNotFoundException(driver.getId()));

        // Get new plan
        SubscriptionPlan newPlan = planRepository.findByType(request.getPlanType())
                .orElseThrow(() -> new SubscriptionPlanNotFoundException(request.getPlanType()));

        // Check if requesting the same plan
        if (current.getSubscriptionPlan().getType().equals(newPlan.getType())) {
            throw new SameSubscriptionPlanException(newPlan.getType());
        }

        // Process payment using WalletService
        try {
            processWalletPayment(driver, newPlan.getPrice());
        } catch (Exception e) {
            throw new SubscriptionPaymentException("Failed to process subscription change payment", e);
        }

        // Deactivate old subscription
        current.setStatus(SubscriptionStatus.EXPIRED);
        subscriptionRepository.save(current);

        // Calculate subscription duration
        int durationDays = planCalculator.getSubscriptionDuration(newPlan.getType());

        // Create new subscription
        DriverSubscription newSubscription = DriverSubscription.builder()
                .driver(driver)
                .subscriptionPlan(newPlan)
                .startDate(LocalDateTime.now())
                .endDate(LocalDateTime.now().plusDays(durationDays))
                .status(SubscriptionStatus.ACTIVE)
                .ridesUsed(0)
                .build();

        newSubscription = subscriptionRepository.save(newSubscription);

        // Update driver
        driver.setActiveSubscription(newSubscription);
        driverRepository.save(driver);

        log.info("Driver {} changed subscription from {} to {}",
                driver.getId(), current.getSubscriptionPlan().getType(), newPlan.getType());

        // Send notification for wallet debit
        notificationService.notifyWalletTransaction(
                driver.getPassenger().getId(),
                newPlan.getPrice(),
                TransactionType.SUBSCRIPTION);

        return buildSubscriptionResponse(newSubscription,
                String.format("Subscription changed successfully from %s to %s",
                        current.getSubscriptionPlan().getType(), newPlan.getType()));
    }

    /**
     * Stop/cancel active subscription.
     * Sets subscription status to STOPPED and removes from driver.
     * 
     * @param passenger the passenger (must have driver profile)
     * @return cancellation confirmation
     * @throws DriverProfileNotFoundException      if driver not found
     * @throws ActiveSubscriptionNotFoundException if no active subscription
     */
    @Transactional
    public SubscriptionResponse stopSubscription(Passenger passenger) {
        // Verify driver profile exists
        if (passenger.getDriverProfile() == null) {
            throw new DriverProfileRequiredException(passenger.getId());
        }

        Driver driver = driverRepository.findById(passenger.getDriverProfile().getId())
                .orElseThrow(() -> new DriverProfileNotFoundException(
                        "Driver profile not found for passenger: " + passenger.getId()));

        DriverSubscription activeSub = subscriptionRepository.findActiveSubscription(driver)
                .orElseThrow(() -> new ActiveSubscriptionNotFoundException(driver.getId()));

        // Set status to CANCELLED
        activeSub.setStatus(SubscriptionStatus.CANCELLED);
        activeSub.setEndDate(LocalDateTime.now());
        subscriptionRepository.save(activeSub);

        // Remove active subscription from driver
        driver.setActiveSubscription(null);
        driverRepository.save(driver);

        log.info("Driver {} stopped subscription", driver.getId());

        return buildSubscriptionResponse(
                activeSub,
                "Subscription has been stopped successfully");
    }

    /**
     * Get all available subscription plans.
     * 
     * @return list of all subscription plans
     */
    @Transactional(readOnly = true)
    public List<SubscriptionPlan> getAllPlans() {
        return planRepository.findAll();
    }

    /**
     * Automatically expire subscriptions (scheduled task).
     * Runs every hour to check and expire subscriptions.
     */
    @Scheduled(cron = "0 0 * * * *") // Every hour
    @Transactional
    public void expireSubscriptions() {
        List<DriverSubscription> expiredSubscriptions = subscriptionRepository.findExpiredSubscriptions();

        for (DriverSubscription subscription : expiredSubscriptions) {
            subscription.setStatus(SubscriptionStatus.EXPIRED);
            subscriptionRepository.save(subscription);

            // Remove active subscription from driver
            Driver driver = subscription.getDriver();
            if (driver.getActiveSubscription() != null &&
                    driver.getActiveSubscription().getId().equals(subscription.getId())) {
                driver.setActiveSubscription(null);
                driverRepository.save(driver);
            }

            log.info("Subscription {} expired for driver {}", subscription.getId(), driver.getId());
        }

        if (!expiredSubscriptions.isEmpty()) {
            log.info("Expired {} subscriptions", expiredSubscriptions.size());
        }
    }

    /**
     * Process wallet payment using WalletService.
     * 
     * @param driver the driver
     * @param amount payment amount
     * @throws InsufficientWalletBalanceException if balance insufficient
     */
    private void processWalletPayment(Driver driver, double amount) {
        Wallet driverWallet = walletService.getWallet(driver.getId());

        // Check balance before attempting debit
        if (driverWallet.getBalance() < amount) {
            throw new InsufficientWalletBalanceException(amount, driverWallet.getBalance());
        }

        walletService.debit(driverWallet, amount, TransactionType.SUBSCRIPTION);
        log.info("Driver {} paid {} DH from wallet for subscription", driver.getId(), amount);
    }

    /**
     * Build subscription response DTO.
     * 
     * @param subscription the subscription entity
     * @param message      optional message
     * @return subscription response
     */
    private SubscriptionResponse buildSubscriptionResponse(DriverSubscription subscription, String message) {
        SubscriptionPlan plan = subscription.getSubscriptionPlan();
        int maxRides = planCalculator.getMaxRides(plan.getType());

        return SubscriptionResponse.builder()
                .subscriptionId(subscription.getId())
                .driverId(subscription.getDriver().getId())
                .planType(plan.getType())
                .price(plan.getPrice())
                .descriptions(plan.getDescriptions())
                .startDate(subscription.getStartDate())
                .endDate(subscription.getEndDate())
                .ridesUsed(subscription.getRidesUsed())
                .maxRides(maxRides)
                .status(subscription.getStatus())
                .message(message)
                .build();
    }

    /**
     * Check if passenger is a first-time subscriber.
     */
    @Transactional(readOnly = true)
    public boolean isFirstTimeSubscriber(Passenger passenger) {
        if (passenger.getDriverProfile() == null) {
            return false;
        }
        
        Driver driver = driverRepository.findById(passenger.getDriverProfile().getId())
                .orElse(null);
        
        if (driver == null) {
            return false;
        }
        
        return !subscriptionRepository.existsByDriver(driver);
    }

    /**
     * Get all plans with promotional eligibility info.
     */
    @Transactional(readOnly = true)
    public PlansWithPromoResponse getPlansWithPromo(Passenger passenger) {
        List<SubscriptionPlan> plans = planRepository.findAll();
        boolean firstTimeEligible = isFirstTimeSubscriber(passenger);
        
        PlansWithPromoResponse.PromoMessages promoMessage = null;
        if (firstTimeEligible) {
            promoMessage = PlansWithPromoResponse.PromoMessages.builder()
                    .en("🎉 First-time offer: Get 2 months for the price of 1!")
                    .fr("🎉 Offre première fois : Obtenez 2 mois au prix d'1 !")
                    .ar("🎉 عرض المرة الأولى: احصل على شهرين بسعر شهر واحد!")
                    .build();
        }
        
        return PlansWithPromoResponse.builder()
                .plans(plans)
                .firstTimePromoEligible(firstTimeEligible)
                .promoDurationDays(firstTimeEligible ? 60 : null)
                .promoMessage(promoMessage)
                .build();
    }
}