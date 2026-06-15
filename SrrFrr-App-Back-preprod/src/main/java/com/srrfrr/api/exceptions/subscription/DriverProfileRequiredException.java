package com.srrfrr.api.exceptions.subscription;

import java.util.UUID;

/**
 * Thrown when user without driver profile tries to subscribe.
 */
public class DriverProfileRequiredException extends SubscriptionException {
    public DriverProfileRequiredException() {
        super("Driver profile required to subscribe to a plan");
    }

    public DriverProfileRequiredException(UUID passengerId) {
        super(String.format("User %s does not have a driver profile", passengerId));
    }
}