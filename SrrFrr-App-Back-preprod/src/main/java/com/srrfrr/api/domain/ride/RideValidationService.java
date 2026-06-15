package com.srrfrr.api.domain.ride;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.Wallet;
import com.srrfrr.api.websocket.model.RideOffer;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Domain service for ride validation business rules.
 * Validates ride creation prerequisites and business constraints.
 */
@Component
@Slf4j
public class RideValidationService {

    /**
     * Validate if passenger can use free ride payment.
     * 
     * Business rule: Passenger must have enough loyalty points to cover the ride
     * cost (1pt = 1DH).
     * 
     * @param passenger    the passenger
     * @param pointsNeeded points required for this ride
     * @return validation result
     */
    public ValidationResult validateFreeRide(Passenger passenger, int pointsNeeded) {
        if (passenger == null) {
            return ValidationResult.failure("Passenger not found");
        }

        int availablePoints = passenger.getPoints();

        if (availablePoints < pointsNeeded) {
            return ValidationResult.failure(
                    String.format("Insufficient loyalty points: %d points required, %d points available",
                            pointsNeeded, availablePoints));
        }

        log.debug("Free ride validation passed: passenger {} has {} points (needs {})",
                passenger.getId(), availablePoints, pointsNeeded);

        return ValidationResult.success("Sufficient loyalty points for free ride");
    }

    /**
     * Validate if driver has sufficient wallet balance for commission.
     * 
     * @param wallet           the driver's wallet
     * @param commissionAmount the commission to be deducted
     * @return validation result
     */
    public ValidationResult validateDriverCommissionBalance(Wallet wallet, double commissionAmount) {
        if (wallet == null) {
            return ValidationResult.failure("Driver wallet not found");
        }

        if (commissionAmount <= 0) {
            return ValidationResult.success("No commission to validate");
        }

        if (wallet.getBalance() < commissionAmount) {
            return ValidationResult.failure(
                    String.format(
                            "Insufficient driver wallet balance for commission: %.2f DH required, %.2f DH available",
                            commissionAmount, wallet.getBalance()));
        }

        return ValidationResult.success("Driver wallet balance sufficient for commission");
    }

    /**
     * Validate ride offer basic requirements.
     * 
     * @param offer the ride offer
     * @return validation result
     */
    public ValidationResult validateRideOffer(RideOffer offer) {
        if (offer == null) {
            return ValidationResult.failure("Ride offer is null");
        }

        if (offer.getPassengerId() == null || offer.getPassengerId().isBlank()) {
            return ValidationResult.failure("Passenger ID is required");
        }

        if (offer.getDistanceKm() < 0) {
            log.warn("Distance validation failed for offer {}: distance = {} km",
                    offer.getRideId(), offer.getDistanceKm());

            return ValidationResult.failure(
                    String.format("Distance must be positive (got: %.2f km)",
                            offer.getDistanceKm()));
        }

        if (offer.getPrice() < 0) {
            return ValidationResult.failure("Price cannot be negative");
        }

        if (offer.getDepartureAddress() == null || offer.getDepartureAddress().isBlank()) {
            return ValidationResult.failure("Departure address is required");
        }

        if (offer.getDestinationAddress() == null || offer.getDestinationAddress().isBlank()) {
            return ValidationResult.failure("Destination address is required");
        }

        return ValidationResult.success("Ride offer validation passed");
    }

    /**
     * Value object for validation results.
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
}