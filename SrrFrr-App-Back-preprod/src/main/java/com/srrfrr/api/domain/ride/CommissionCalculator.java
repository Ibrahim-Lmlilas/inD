package com.srrfrr.api.domain.ride;

import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.DriverSubscription;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Domain service for commission calculations based on subscription plans.
 * Handles the business logic for determining commission rates.
 */
@Component
@Slf4j
public class CommissionCalculator {

    private static final double DEFAULT_COMMISSION_RATE = 0.08; // 8%
    private static final double NO_COMMISSION_RATE = 0.0;

    /**
     * Calculate commission for a ride based on driver's subscription status.
     * 
     * Business rules:
     * - PRO plan: 0% commission (unlimited rides)
     * - PREMIUM/BASIC with rides remaining: 0% commission
     * - PREMIUM/BASIC exceeded limit: 8% commission
     * - No active subscription: 8% commission
     * 
     * @param driver the driver
     * @param ridePrice the final ride price
     * @return commission calculation result
     */
    public CommissionResult calculateCommission(Driver driver, double ridePrice) {
        if (driver == null) {
            return new CommissionResult(0.0, DEFAULT_COMMISSION_RATE, false, "No driver");
        }

        DriverSubscription activeSubscription = driver.getActiveSubscription();

        // No active subscription → default commission
        if (activeSubscription == null || !activeSubscription.isActive()) {
            double commission = ridePrice * DEFAULT_COMMISSION_RATE;
            log.debug("Driver {} has no active subscription - 8% commission applied", driver.getId());
            return new CommissionResult(
                commission, 
                DEFAULT_COMMISSION_RATE, 
                true, 
                "No active subscription"
            );
        }

        String planType = activeSubscription.getSubscriptionPlan().getType();

        // PRO plan: 0% commission unlimited
        if ("PRO".equals(planType)) {
            log.debug("Driver {} using PRO subscription - 0% commission (unlimited)", driver.getId());
            return new CommissionResult(
                0.0, 
                NO_COMMISSION_RATE, 
                false, 
                "PRO subscription (unlimited)"
            );
        }

        // PREMIUM/BASIC with rides remaining: 0% commission
        if (activeSubscription.hasRidesRemaining()) {
            log.debug("Driver {} using {} subscription - 0% commission ({} rides used)",
                    driver.getId(), planType, activeSubscription.getRidesUsed());
            return new CommissionResult(
                0.0, 
                NO_COMMISSION_RATE, 
                false, 
                planType + " subscription (" + activeSubscription.getRidesUsed() + " rides used)"
            );
        }

        // PREMIUM/BASIC exceeded limit: 8% commission
        double commission = ridePrice * DEFAULT_COMMISSION_RATE;
        log.debug("Driver {} exceeded {} subscription limit - 8% commission applied",
                driver.getId(), planType);
        return new CommissionResult(
            commission, 
            DEFAULT_COMMISSION_RATE, 
            true, 
            planType + " subscription limit exceeded"
        );
    }

    /**
     * Check if commission should be applied based on subscription.
     * 
     * @param driver the driver
     * @return true if commission applies, false otherwise
     */
    public boolean shouldApplyCommission(Driver driver) {
        if (driver == null) {
            return false;
        }

        DriverSubscription activeSubscription = driver.getActiveSubscription();

        // No subscription → apply commission
        if (activeSubscription == null || !activeSubscription.isActive()) {
            return true;
        }

        // PRO plan → never apply commission
        if ("PRO".equals(activeSubscription.getSubscriptionPlan().getType())) {
            return false;
        }

        // PREMIUM/BASIC → apply if no rides remaining
        return !activeSubscription.hasRidesRemaining();
    }

    /**
     * Value object for commission calculation result.
     */
    @Getter
    @AllArgsConstructor
    public static class CommissionResult {
        private final double commissionAmount;
        private final double commissionRate;
        private final boolean commissionApplied;
        private final String reason;

        public boolean hasCommission() {
            return commissionApplied && commissionAmount > 0;
        }
    }
}