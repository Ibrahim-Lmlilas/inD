package com.srrfrr.api.repositories.main.loyalty;

import com.srrfrr.api.entities.main.LoyaltyTransaction;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface LoyaltyTransactionRepository extends JpaRepository<LoyaltyTransaction, UUID> {
    Page<LoyaltyTransaction> findByPassengerIdOrderByCreatedAtDesc(UUID passengerId, Pageable pageable);
}