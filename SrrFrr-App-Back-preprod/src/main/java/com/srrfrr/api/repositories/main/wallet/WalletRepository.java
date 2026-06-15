package com.srrfrr.api.repositories.main.wallet;

import com.srrfrr.api.entities.main.Wallet;

import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, UUID> {
        // Direct driver queries
        Optional<Wallet> findByDriverId(UUID driverId);

        @Query("SELECT w FROM Wallet w LEFT JOIN FETCH w.transactions " +
                        "WHERE w.driver.id = :driverId")
        Optional<Wallet> findWalletWithTransactionsByDriverId(@Param("driverId") UUID driverId);

        // Check if wallet exists for driver
        boolean existsByDriverId(UUID driverId);

        // Find all wallets with low balance (for admin monitoring)
        // @Query("SELECT w FROM Wallet w WHERE w.balance < :threshold")
        // List<Wallet> findLowBalanceWallets(@Param("threshold") double threshold);
}