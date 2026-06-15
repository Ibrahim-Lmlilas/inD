package com.srrfrr.api.domain.payment;

import com.srrfrr.api.entities.main.Wallet;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.stereotype.Component;

/**
 * Domain service for wallet balance validation and calculations.
 * Pure business logic for wallet operations without side effects.
 */
@Component
public class WalletBalanceValidator {

    private static final double MINIMUM_BALANCE = 0.0;
    private static final double MAXIMUM_TRANSACTION = 10000.0; // 10k DH max per transaction
    private static final double LOW_BALANCE_THRESHOLD = 50.0; // Warning threshold

    /**
     * Validate if wallet has sufficient balance for a transaction.
     * 
     * @param wallet the wallet to check
     * @param amount the amount to validate
     * @return validation result
     */
    public ValidationResult validateSufficientBalance(Wallet wallet, double amount) {
        if (wallet == null) {
            return ValidationResult.failure("Wallet not found");
        }

        if (amount <= 0) {
            return ValidationResult.failure("Amount must be positive");
        }

        if (amount > MAXIMUM_TRANSACTION) {
            return ValidationResult.failure(
                String.format("Transaction amount exceeds maximum limit of %.2f DH", MAXIMUM_TRANSACTION)
            );
        }

        double balance = wallet.getBalance();

        if (balance < amount) {
            return ValidationResult.failure(
                String.format("Insufficient balance: %.2f DH required, %.2f DH available", 
                    amount, balance)
            );
        }

        if (balance - amount < MINIMUM_BALANCE) {
            return ValidationResult.failure(
                String.format("Transaction would result in negative balance: %.2f DH", 
                    balance - amount)
            );
        }

        return ValidationResult.success("Sufficient balance available");
    }

    /**
     * Check if balance is below warning threshold.
     * 
     * @param wallet the wallet to check
     * @return true if balance is low
     */
    public boolean isLowBalance(Wallet wallet) {
        if (wallet == null) {
            return true;
        }
        return wallet.getBalance() < LOW_BALANCE_THRESHOLD;
    }

    /**
     * Calculate balance after a transaction.
     * 
     * @param currentBalance current wallet balance
     * @param amount transaction amount
     * @param isDebit true for debit, false for credit
     * @return projected balance
     */
    public double calculateProjectedBalance(double currentBalance, double amount, boolean isDebit) {
        return isDebit ? currentBalance - amount : currentBalance + amount;
    }

    /**
     * Validate amount is within acceptable range.
     * 
     * @param amount the amount to validate
     * @return validation result
     */
    public ValidationResult validateAmount(double amount) {
        if (amount <= 0) {
            return ValidationResult.failure("Amount must be positive");
        }

        if (amount > MAXIMUM_TRANSACTION) {
            return ValidationResult.failure(
                String.format("Amount exceeds maximum limit of %.2f DH", MAXIMUM_TRANSACTION)
            );
        }

        return ValidationResult.success("Amount is valid");
    }

    /**
     * Get wallet health status based on balance.
     * 
     * @param wallet the wallet to check
     * @return health status
     */
    public WalletHealth getWalletHealth(Wallet wallet) {
        if (wallet == null) {
            return new WalletHealth(HealthStatus.UNKNOWN, "Wallet not found", false);
        }

        double balance = wallet.getBalance();

        if (balance < MINIMUM_BALANCE) {
            return new WalletHealth(
                HealthStatus.CRITICAL,
                "Negative balance - immediate action required",
                true
            );
        }

        if (balance < LOW_BALANCE_THRESHOLD) {
            return new WalletHealth(
                HealthStatus.LOW,
                String.format("Balance below %.2f DH - consider adding funds", LOW_BALANCE_THRESHOLD),
                true
            );
        }

        if (balance < 200.0) {
            return new WalletHealth(
                HealthStatus.MODERATE,
                "Balance is moderate",
                false
            );
        }

        return new WalletHealth(
            HealthStatus.HEALTHY,
            "Wallet balance is healthy",
            false
        );
    }

    /**
     * Calculate how many transactions of a given amount are possible.
     * 
     * @param wallet the wallet
     * @param transactionAmount the amount per transaction
     * @return number of possible transactions
     */
    public int calculatePossibleTransactions(Wallet wallet, double transactionAmount) {
        if (wallet == null || transactionAmount <= 0) {
            return 0;
        }

        return (int) Math.floor(wallet.getBalance() / transactionAmount);
    }

    /**
     * Validation result value object.
     */
    @Getter
    @AllArgsConstructor
    public static class ValidationResult {
        private final boolean valid;
        private final String message;

        public static ValidationResult success(String message) {
            return new ValidationResult(true, message);
        }

        public static ValidationResult failure(String message) {
            return new ValidationResult(false, message);
        }

        public void throwIfInvalid() {
            if (!valid) {
                throw new IllegalStateException(message);
            }
        }
    }

    /**
     * Wallet health status value object.
     */
    @Getter
    @AllArgsConstructor
    public static class WalletHealth {
        private final HealthStatus status;
        private final String message;
        private final boolean requiresAttention;
    }

    /**
     * Health status enum.
     */
    public enum HealthStatus {
        HEALTHY,
        MODERATE,
        LOW,
        CRITICAL,
        UNKNOWN
    }
}