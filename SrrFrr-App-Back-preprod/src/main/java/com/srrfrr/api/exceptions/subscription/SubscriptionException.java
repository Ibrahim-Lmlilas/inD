package com.srrfrr.api.exceptions.subscription;

/**
 * Base exception for all subscription-related errors.
 */
public abstract class SubscriptionException extends RuntimeException {
    protected SubscriptionException(String message) {
        super(message);
    }

    protected SubscriptionException(String message, Throwable cause) {
        super(message, cause);
    }
}