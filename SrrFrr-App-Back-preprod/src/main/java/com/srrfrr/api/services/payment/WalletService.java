package com.srrfrr.api.services.payment;

import com.srrfrr.api.domain.payment.WalletBalanceValidator;
import com.srrfrr.api.domain.payment.WalletBalanceValidator.ValidationResult;
import com.srrfrr.api.dto.WalletDTO;
import com.srrfrr.api.dto.WalletTransactionDTO;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Wallet;
import com.srrfrr.api.entities.main.WalletTransaction;
import com.srrfrr.api.enums.Wallet.TransactionStatus;
import com.srrfrr.api.enums.Wallet.TransactionType;
import com.srrfrr.api.exceptions.wallet.InsufficientBalanceException;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.wallet.WalletRepository;
import com.srrfrr.api.repositories.main.wallet.WalletTransactionRepository;


import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Application service for wallet management.
 * Orchestrates domain validation and handles persistence.
 * Wallets are now directly linked to Driver entities only.
 */
@Service
@Slf4j
public class WalletService {
    private final WalletRepository walletRepository;
    private final WalletTransactionRepository transactionRepository;
    private final WalletBalanceValidator balanceValidator;

    @Value("${wallet.initial.balance}")
    private double initialBalance;

    public WalletService(
            final WalletRepository walletRepository,
            final WalletTransactionRepository transactionRepository,
            final WalletBalanceValidator balanceValidator) {
        this.walletRepository = walletRepository;
        this.transactionRepository = transactionRepository;
        this.balanceValidator = balanceValidator;
    }

    /**
     * Get or create wallet for driver.
     */
    @Transactional
    public Wallet getOrCreateWallet(Driver driver) {
        if (driver == null) {
            throw new IllegalArgumentException("Driver cannot be null");
        }

        return walletRepository.findByDriverId(driver.getId())
                .orElseGet(() -> createWallet(driver));
    }

    /**
     * Get wallet by driver ID - throws exception if not found.
     */
    public Wallet getWallet(UUID driverId) {
        return walletRepository.findByDriverId(driverId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "Wallet not found for driver: " + driverId));
    }

    /**
     * Get wallet for driver entity - throws exception if not found.
     */
    public Wallet getWallet(Driver driver) {
        if (driver == null) {
            throw new IllegalArgumentException("Driver cannot be null");
        }
        return getWallet(driver.getId());
    }

    /**
     * Get wallet with transactions.
     */
    public WalletDTO getWalletWithTransactions(UUID driverId) {
        Wallet wallet = walletRepository
                .findWalletWithTransactionsByDriverId(driverId)
                .orElseThrow(() -> new EntityNotFoundException("Wallet not found"));

        return mapToDTO(wallet);
    }

    /**
     * Credit wallet - used by ride completions, refunds, etc.
     */
    @Transactional
    public WalletTransaction credit(Wallet wallet, double amount, TransactionType type) {
        ValidationResult validation = balanceValidator.validateAmount(amount);
        validation.throwIfInvalid();

        wallet.credit(amount);
        walletRepository.save(wallet);

        log.info("Credited {} DH to driver {} wallet ({})",
                amount, wallet.getDriver().getId(), type);

        return createTransaction(wallet, amount, type);
    }

    /**
     * Debit wallet - used by payments, commissions, subscriptions.
     */
    @Transactional
    public WalletTransaction debit(Wallet wallet, double amount, TransactionType type) {
        ValidationResult validation = balanceValidator.validateSufficientBalance(wallet, amount);

        if (!validation.isValid()) {
            throw new InsufficientBalanceException(validation.getMessage());
        }

        wallet.debit(amount);
        walletRepository.save(wallet);

        if (balanceValidator.isLowBalance(wallet)) {
            log.warn("Driver {} wallet has low balance: {} DH",
                    wallet.getDriver().getId(), wallet.getBalance());
        }

        log.info("Debited {} DH from driver {} wallet ({})",
                amount, wallet.getDriver().getId(), type);

        return createTransaction(wallet, amount, type);
    }

    /**
     * Process ride payment.
     * Passenger pays cash to driver → System credits driver wallet → Deducts
     * commission.
     */
    @Transactional
    public void processRidePayment(Driver driver, double ridePrice, double commission) {
        if (driver == null) {
            log.warn("No driver provided for ride payment processing");
            return;
        }

        Wallet driverWallet = getWallet(driver);

        // Credit driver with full ride amount
        credit(driverWallet, ridePrice, TransactionType.RIDE_PAYMENT);
        log.info("Credited {} DH to driver {} for completed ride", ridePrice, driver.getId());

        // Deduct commission if applicable
        if (commission > 0) {
            ValidationResult validation = balanceValidator.validateSufficientBalance(
                    driverWallet, commission);
            validation.throwIfInvalid();

            debit(driverWallet, commission, TransactionType.COMMISSION);
            log.info("Debited {} DH commission from driver {}", commission, driver.getId());
        }
    }

    /**
     * Process subscription payment.
     */
    @Transactional
    public void processSubscriptionPayment(Driver driver, double amount) {
        Wallet driverWallet = getWallet(driver);
        debit(driverWallet, amount, TransactionType.SUBSCRIPTION);
    }

    /**
     * Check if wallet can afford a transaction.
     */
    public boolean canAfford(Wallet wallet, double amount) {
        ValidationResult validation = balanceValidator.validateSufficientBalance(wallet, amount);
        return validation.isValid();
    }

    /**
     * Get projected balance after a transaction.
     */
    public double getProjectedBalance(Wallet wallet, double amount, boolean isDebit) {
        if (wallet == null) {
            return 0.0;
        }
        return balanceValidator.calculateProjectedBalance(wallet.getBalance(), amount, isDebit);
    }

    /**
     * Create wallet for driver.
     */
    private Wallet createWallet(Driver driver) {
        Wallet wallet = Wallet.builder()
                .driver(driver)
                .balance(initialBalance) // Initial balance
                .build();

        wallet = walletRepository.save(wallet);

        // Create INIT transaction
        createTransaction(wallet, wallet.getBalance(), TransactionType.INIT);

        log.info("Created wallet for driver {} with initial balance {} DH",
                driver.getId(), wallet.getBalance());

        return wallet;
    }

    private WalletTransaction createTransaction(Wallet wallet, double amount, TransactionType type) {
        WalletTransaction transaction = WalletTransaction.builder()
                .wallet(wallet)
                .amount(amount)
                .type(type)
                .status(TransactionStatus.PAID)
                .build();

        return transactionRepository.save(transaction);
    }

    private WalletDTO mapToDTO(Wallet wallet) {
        return WalletDTO.builder()
                .wallet(wallet.getBalance())
                .driverId(wallet.getDriver().getId())
                .transactions(wallet.getTransactions().stream()
                        .map(this::mapTransactionToDTO)
                        .toList())
                .build();
    }

    private WalletTransactionDTO mapTransactionToDTO(WalletTransaction transaction) {
        return WalletTransactionDTO.builder()
                .id(transaction.getId())
                .transactionType(transaction.getType().name())
                .amount(transaction.getAmount())
                .createdAt(transaction.getCreatedAt())
                .build();
    }
}