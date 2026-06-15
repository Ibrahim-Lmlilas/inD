package com.srrfrr.api.domain.subscription;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.stereotype.Component;

/**
 * Domain service for subscription plan calculations and business rules.
 * Contains pure business logic about subscription features and limits.
 */
@Component
public class SubscriptionPlanCalculator {

    /**
     * Get maximum rides allowed for a subscription plan.
     * 
     * @param planType the plan type (BASIC, PREMIUM, PRO)
     * @return max rides (0 means unlimited)
     */
    public int getMaxRides(String planType) {
        if (planType == null) {
            return 0;
        }

        switch (planType.toUpperCase()) {
            case "PRO":
                return 0; // Unlimited
            case "PREMIUM":
                return 150;
            case "BASIC":
                return 60;
            default:
                return 0;
        }
    }

    /**
     * Check if a plan has unlimited rides.
     * 
     * @param planType the plan type
     * @return true if unlimited, false otherwise
     */
    public boolean isUnlimitedPlan(String planType) {
        return "PRO".equalsIgnoreCase(planType);
    }

    /**
     * Get subscription duration in days.
     * Currently all plans have 30-day duration.
     * 
     * @param planType the plan type
     * @return duration in days
     */
    public int getSubscriptionDuration(String planType) {
        // All plans currently have 30-day duration
        // This method allows future flexibility for different durations
        return 30;
    }

    /**
     * Calculate remaining rides for a subscription.
     * 
     * @param planType the plan type
     * @param ridesUsed number of rides already used
     * @return rides remaining (negative if exceeded, 0 if unlimited)
     */
    public int calculateRemainingRides(String planType, int ridesUsed) {
        if (isUnlimitedPlan(planType)) {
            return Integer.MAX_VALUE; // Unlimited
        }

        int maxRides = getMaxRides(planType);
        return Math.max(0, maxRides - ridesUsed);
    }

    /**
     * Get plan tier level (higher is better).
     * Useful for upgrade/downgrade logic.
     * 
     * @param planType the plan type
     * @return tier level (1=BASIC, 2=PREMIUM, 3=PRO)
     */
    public int getPlanTier(String planType) {
        if (planType == null) {
            return 0;
        }

        switch (planType.toUpperCase()) {
            case "BASIC":
                return 1;
            case "PREMIUM":
                return 2;
            case "PRO":
                return 3;
            default:
                return 0;
        }
    }

    /**
     * Check if plan change is an upgrade.
     * 
     * @param currentPlan current subscription plan type
     * @param newPlan new plan type
     * @return true if upgrade, false if downgrade or same
     */
    public boolean isUpgrade(String currentPlan, String newPlan) {
        return getPlanTier(newPlan) > getPlanTier(currentPlan);
    }

    /**
     * Get plan features summary.
     * 
     * @param planType the plan type
     * @return plan features
     */
    public PlanFeatures getPlanFeatures(String planType) {
        int maxRides = getMaxRides(planType);
        boolean unlimited = isUnlimitedPlan(planType);
        int duration = getSubscriptionDuration(planType);
        double commissionRate = unlimited || maxRides > 0 ? 0.0 : 0.08;

        return new PlanFeatures(
            planType,
            maxRides,
            unlimited,
            duration,
            commissionRate
        );
    }

    /**
     * Value object for plan features.
     */
    @Getter
    @AllArgsConstructor
    public static class PlanFeatures {
        private final String planType;
        private final int maxRides;
        private final boolean unlimited;
        private final int durationDays;
        private final double commissionRate;

        public String getMaxRidesDisplay() {
            return unlimited ? "Unlimited" : String.valueOf(maxRides);
        }

        public String getCommissionDisplay() {
            return commissionRate == 0.0 ? "0%" : String.format("%.0f%%", commissionRate * 100);
        }
    }
}