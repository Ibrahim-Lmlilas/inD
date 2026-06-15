package com.srrfrr.api.exceptions.subscription;

/**
 * Thrown when subscription plan is not found.
 */
public class SubscriptionPlanNotFoundException extends SubscriptionException {
    public SubscriptionPlanNotFoundException(String message) {
        super(message);
    }

    public SubscriptionPlanNotFoundException(String planType, Long planId) {
        super(String.format("Subscription plan not found: %s (ID: %d)", planType, planId));
    }
}