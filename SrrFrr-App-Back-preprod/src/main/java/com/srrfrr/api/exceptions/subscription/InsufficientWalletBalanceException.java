package com.srrfrr.api.exceptions.subscription;

/**
 * Thrown when wallet balance is insufficient for subscription payment.
 */
public class InsufficientWalletBalanceException extends SubscriptionException {
    public InsufficientWalletBalanceException(double required, double available) {
        super(String.format("Insufficient wallet balance. Required: %.2f DH, Available: %.2f DH", 
            required, available));
    }
}