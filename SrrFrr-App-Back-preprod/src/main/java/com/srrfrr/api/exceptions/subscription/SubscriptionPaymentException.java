package com.srrfrr.api.exceptions.subscription;

/**
 * Thrown when subscription payment processing fails.
 */
public class SubscriptionPaymentException extends SubscriptionException {
    public SubscriptionPaymentException(String message) {
        super(message);
    }

    public SubscriptionPaymentException(String message, Throwable cause) {
        super(message, cause);
    }
}