package com.srrfrr.api.exceptions.subscription;

/**
 * Thrown when driver tries to change to the same plan they already have.
 */
public class SameSubscriptionPlanException extends SubscriptionException {
    public SameSubscriptionPlanException() {
        super("You are already subscribed to this plan");
    }

    public SameSubscriptionPlanException(String planType) {
        super(String.format("You are already subscribed to the %s plan", planType));
    }
}