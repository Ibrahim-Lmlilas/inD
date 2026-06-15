package com.srrfrr.api.exceptions.subscription;

import java.util.UUID;

/**
 * Thrown when driver has no active subscription.
 */
public class ActiveSubscriptionNotFoundException extends SubscriptionException {
    public ActiveSubscriptionNotFoundException(String message) {
        super(message);
    }

    public ActiveSubscriptionNotFoundException(UUID driverId) {
        super(String.format("No active subscription found for driver: %s", driverId));
    }
}
