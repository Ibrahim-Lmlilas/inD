package com.srrfrr.api.services.subscription;

import com.srrfrr.api.domain.subscription.SubscriptionPlanCalculator;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.SubscriptionStatus;
import com.srrfrr.api.enums.Wallet.TransactionType;
import com.srrfrr.api.repositories.main.subscription.DriverSubscriptionRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.services.notification.NotificationService;
import com.srrfrr.api.services.payment.WalletService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for automatic subscription renewal.
 * Handles expiration and renewal of subscriptions.
 */
@Service
@Slf4j
public class SubscriptionRenewalService {
	private final DriverSubscriptionRepository subscriptionRepository;
	private final DriverRepository driverRepository;
	private final WalletService walletService;
	private final NotificationService notificationService;
	private final SubscriptionPlanCalculator planCalculator;

	public SubscriptionRenewalService(
			final DriverSubscriptionRepository subscriptionRepository,
			final DriverRepository driverRepository,
			final WalletService walletService,
			final NotificationService notificationService,
			final SubscriptionPlanCalculator planCalculator) {
		this.subscriptionRepository = subscriptionRepository;
		this.driverRepository = driverRepository;
		this.walletService = walletService;
		this.notificationService = notificationService;
		this.planCalculator = planCalculator;
	}

	/**
	 * Process expiring subscriptions - runs every hour.
	 * Attempts to auto-renew if driver has sufficient balance.
	 */
	@Scheduled(cron = "0 0 * * * *")
	@Transactional
	public void processExpiringSubscriptions() {
		List<DriverSubscription> expiringSubscriptions = subscriptionRepository.findExpiredSubscriptions();

		for (DriverSubscription subscription : expiringSubscriptions) {
			try {
				processSubscriptionExpiration(subscription);
			} catch (Exception e) {
				log.error("Error processing subscription {} expiration: {}",
						subscription.getId(), e.getMessage());
			}
		}

		if (!expiringSubscriptions.isEmpty()) {
			log.info("Processed {} expiring subscriptions", expiringSubscriptions.size());
		}
	}

	/**
	 * Process a single subscription expiration.
	 * Attempts auto-renewal, or expires subscription if renewal fails.
	 */
	private void processSubscriptionExpiration(DriverSubscription subscription) {
		Driver driver = subscription.getDriver();
		SubscriptionPlan plan = subscription.getSubscriptionPlan();

		log.info("Processing expiration for subscription {} (Driver: {})",
				subscription.getId(), driver.getId());

		boolean renewed = attemptAutoRenewal(driver, subscription);

		if (!renewed) {
			expireSubscription(subscription, driver);

			notificationService.notifySubscriptionExpired(
					driver.getPassenger().getId(),
					plan.getType());
		}
	}

	/**
	 * Attempt to automatically renew subscription.
	 */
	private boolean attemptAutoRenewal(Driver driver, DriverSubscription oldSubscription) {
		SubscriptionPlan plan = oldSubscription.getSubscriptionPlan();
		Wallet driverWallet = walletService.getWallet(driver);

		if (driverWallet.getBalance() < plan.getPrice()) {
			log.info("Auto-renewal failed for driver {} - insufficient balance ({} < {})",
					driver.getId(), driverWallet.getBalance(), plan.getPrice());

			notificationService.notifyInsufficientBalanceForRenewal(
					driver.getPassenger().getId(),
					plan.getType(),
					plan.getPrice(),
					driverWallet.getBalance());

			return false;
		}

		try {
			walletService.debit(driverWallet, plan.getPrice(), TransactionType.SUBSCRIPTION);

			oldSubscription.setStatus(SubscriptionStatus.EXPIRED);
			subscriptionRepository.save(oldSubscription);

			int durationDays = planCalculator.getSubscriptionDuration(plan.getType());
			DriverSubscription newSubscription = DriverSubscription.builder()
					.driver(driver)
					.subscriptionPlan(plan)
					.startDate(LocalDateTime.now())
					.endDate(LocalDateTime.now().plusDays(durationDays))
					.status(SubscriptionStatus.ACTIVE)
					.ridesUsed(0)
					.build();

			newSubscription = subscriptionRepository.save(newSubscription);

			driver.setActiveSubscription(newSubscription);
			driverRepository.save(driver);

			log.info("Auto-renewed subscription for driver {} - {} plan for {} DH",
					driver.getId(), plan.getType(), plan.getPrice());

			notificationService.notifySubscriptionRenewed(
					driver.getPassenger().getId(),
					plan.getType(),
					plan.getPrice(),
					newSubscription.getEndDate());

			return true;

		} catch (Exception e) {
			log.error("Auto-renewal failed for driver {}: {}", driver.getId(), e.getMessage());
			return false;
		}
	}

	/**
	 * Expire subscription without renewal.
	 */
	private void expireSubscription(DriverSubscription subscription, Driver driver) {
		subscription.setStatus(SubscriptionStatus.EXPIRED);
		subscriptionRepository.save(subscription);

		if (driver.getActiveSubscription() != null &&
				driver.getActiveSubscription().getId().equals(subscription.getId())) {
			driver.setActiveSubscription(null);
			driverRepository.save(driver);
		}

		log.info("Subscription {} expired for driver {}", subscription.getId(), driver.getId());
	}
}