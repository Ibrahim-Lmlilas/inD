package com.srrfrr.api.services.loyalty;

import com.srrfrr.api.dto.LoyaltyTransactionDTO;
import com.srrfrr.api.entities.main.LoyaltyReward;
import com.srrfrr.api.entities.main.LoyaltyTransaction;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.exceptions.loyalty_points.InsufficientPointsException;
import com.srrfrr.api.repositories.main.loyalty.LoyaltyRewardRepository;
import com.srrfrr.api.repositories.main.loyalty.LoyaltyTransactionRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Application service for loyalty program management.
 * Orchestrates domain logic and handles persistence.
 */
@Service
@Slf4j
public class LoyaltyService {

    private final PassengerRepository passengerRepository;
    private final LoyaltyTransactionRepository transactionRepository;
    private final LoyaltyRewardRepository rewardRepository;

    public LoyaltyService(
            final PassengerRepository passengerRepository,
            final LoyaltyTransactionRepository transactionRepository,
            final LoyaltyRewardRepository rewardRepository) {
        this.passengerRepository = passengerRepository;
        this.transactionRepository = transactionRepository;
        this.rewardRepository = rewardRepository;
    }
    /**
     * Award points for specific action.
     */
    @Transactional
    public void awardPoints(Passenger passenger, int points, LoyaltyTransactionType type) {
        if (points <= 0) {
            throw new IllegalArgumentException("Points must be positive");
        }

        passenger.addLoyaltyPoints(points);
        passengerRepository.save(passenger);

        LoyaltyTransaction tx = LoyaltyTransaction.builder()
                .passenger(passenger)
                .type(type)
                .points(points)
                .build();

        transactionRepository.save(tx);
        log.info("Awarded {} points to passenger {} for {}", points, passenger.getId(), type);
    }

    /**
     * Deduct points (for ride discounts, redemptions).
     */
    @Transactional
    public void deductPoints(Passenger passenger, int points, LoyaltyTransactionType type) {
        if (points <= 0) {
            throw new IllegalArgumentException("Points must be positive");
        }

        if (passenger.getPoints() < points) {
            throw new InsufficientPointsException("Not enough loyalty points");
        }

        passenger.setPoints(passenger.getPoints() - points);
        passengerRepository.save(passenger);

        LoyaltyTransaction tx = LoyaltyTransaction.builder()
                .passenger(passenger)
                .type(type)
                .points(points)
                .build();

        transactionRepository.save(tx);
        log.info("Deducted {} points from passenger {} for {}", points, passenger.getId(), type);
    }

    /**
     * Get all loyalty rewards catalog.
     */
    public List<LoyaltyReward> getAllRewards() {
        return rewardRepository.findAll();
    }

    /**
     * Get loyalty summary with paginated transactions
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getLoyaltyInfo(UUID passengerId, Pageable pageable) {
        Passenger passenger = passengerRepository.findById(passengerId)
                .orElseThrow(() -> new EntityNotFoundException("Passenger not found"));

        Page<LoyaltyTransaction> transactionPage = transactionRepository
                .findByPassengerIdOrderByCreatedAtDesc(passengerId, pageable);

        List<LoyaltyTransactionDTO> transactions = transactionPage.getContent()
                .stream()
                .map(this::mapTransactionToDTO)
                .toList();

        Map<String, Object> response = new HashMap<>();
        response.put("points", passenger.getPoints());
        response.put("transactions", transactions);
        response.put("totalElements", transactionPage.getTotalElements());
        response.put("totalPages", transactionPage.getTotalPages());
        response.put("currentPage", transactionPage.getNumber());
        response.put("pageSize", transactionPage.getSize());
        response.put("hasNext", transactionPage.hasNext());
        response.put("hasPrevious", transactionPage.hasPrevious());

        return response;
    }

    private LoyaltyTransactionDTO mapTransactionToDTO(LoyaltyTransaction tx) {
        return LoyaltyTransactionDTO.builder()
                .id(tx.getId())
                .type(tx.getType().name())
                .points(tx.getPoints())
                .createdAt(tx.getCreatedAt())
                .build();
    }
}