package com.srrfrr.api.exceptions.subscription;

import java.util.UUID;

/**
 * Thrown when a subscription is not found.
 */
public class SubscriptionNotFoundException extends SubscriptionException {
    public SubscriptionNotFoundException(String message) {
        super(message);
    }

    public SubscriptionNotFoundException(UUID subscriptionId) {
        super(String.format("Subscription not found with ID: %s", subscriptionId));
    }
}