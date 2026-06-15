package com.srrfrr.api.exceptions.subscription;

import java.util.UUID;

/**
 * Thrown when driver already has an active subscription.
 */
public class ActiveSubscriptionAlreadyExistsException extends SubscriptionException {
    public ActiveSubscriptionAlreadyExistsException(String message) {
        super(message);
    }

    public ActiveSubscriptionAlreadyExistsException(UUID driverId) {
        super(String.format("Driver %s already has an active subscription. Please cancel it first.", driverId));
    }
}