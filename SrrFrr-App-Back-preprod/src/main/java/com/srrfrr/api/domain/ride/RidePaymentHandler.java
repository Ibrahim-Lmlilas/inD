package com.srrfrr.api.domain.ride;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.loyalty.LoyaltyService;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Domain service for handling ride payments with loyalty points.
 * 
 * Business Model:
 * - 1 loyalty point = 1 DH
 * - Free ride requires full ride cost in points
 * - Passenger earns 5% of ride cost as points upon completion
 * - Driver always receives full ride price
 */
@Component
@Slf4j
public class RidePaymentHandler {

    private final RideValidationService validationService;
    private final PassengerRepository passengerRepository;
    private final LoyaltyService loyaltyService;

    public RidePaymentHandler(
            RideValidationService validationService,
            PassengerRepository passengerRepository,
            LoyaltyService loyaltyService) {
        this.validationService = validationService;
        this.passengerRepository = passengerRepository;
        this.loyaltyService = loyaltyService;
    }

    /**
     * Result of payment processing.
     * 
     * @param ridePrice  The actual ride price
     * @param pointsUsed Points deducted for free ride (0 for regular payment)
     * @param isFreeRide Whether this was paid with loyalty points
     */
    @Getter
    @AllArgsConstructor
    public static class PaymentResult {
        private final double ridePrice;
        private final int pointsUsed;
        private final boolean isFreeRide;
    }

    /**
     * Process payment based on payment type.
     * Returns payment details including any free ride info.
     * 
     * @param passenger   the passenger
     * @param paymentType payment method chosen
     * @param ridePrice   calculated ride price
     * @return payment result
     */
    public PaymentResult processPayment(
            Passenger passenger,
            PaymentType paymentType,
            double ridePrice) {

        return switch (paymentType) {
            case WALLET -> throw new UnsupportedOperationException("Wallet payment is not supported yet");
            case CASH -> processCashPayment(ridePrice);
            case CARD -> throw new UnsupportedOperationException("Card payment is not supported yet");
            case FREERIDE -> processFreeRide(passenger, ridePrice);
        };
    }

    /**
     * Validate free ride eligibility WITHOUT deducting points.
     * Points are only deducted when ride is actually accepted by driver.
     * 
     * @param passenger the passenger
     * @param ridePrice ride price
     * @return validation result
     */
    public PaymentResult validateFreeRide(Passenger passenger, double ridePrice) {
        int pointsNeeded = (int) Math.ceil(ridePrice);

        // Only validate, don't deduct yet
        validationService.validateFreeRide(passenger, pointsNeeded).throwIfInvalid();

        log.info("Free ride validation passed for passenger {}: {} points available for {} DH ride",
                passenger.getId(), passenger.getPoints(), ridePrice);

        // Return result without deducting points
        return new PaymentResult(ridePrice, pointsNeeded, true);
    }

    /**
     * Cash payment - straightforward transaction.
     * Passenger pays full price in cash to driver.
     * 
     * @param originalPrice ride price
     * @return payment result with no points used
     */
    private PaymentResult processCashPayment(double originalPrice) {
        log.info("Cash payment selected - passenger pays {} DH in cash", originalPrice);
        return new PaymentResult(originalPrice, 0, false);
    }

    /**
     * Free ride using loyalty points.
     * 
     * Business rules:
     * - Passenger must have points >= ride cost (1pt = 1DH)
     * - Points are deducted from passenger's balance
     * - Driver still receives full ride price
     * - Passenger pays 0 DH
     * 
     * @param passenger     the passenger
     * @param originalPrice ride price
     * @return payment result with points deducted
     */
    private PaymentResult processFreeRide(Passenger passenger, double originalPrice) {
        // Calculate points needed (1pt = 1DH, rounded up)
        int pointsNeeded = (int) Math.ceil(originalPrice);

        // Validate passenger has enough points
        validationService.validateFreeRide(passenger, pointsNeeded).throwIfInvalid();

        // Deduct points from passenger
        loyaltyService.deductPoints(passenger, pointsNeeded, LoyaltyTransactionType.DEBIT);
        passengerRepository.save(passenger);

        log.info("Free ride processed: passenger {} used {} points for {} DH ride (balance: {} → {})",
                passenger.getId(), pointsNeeded, originalPrice, passenger.getPoints() + pointsNeeded, passenger.getPoints());
        // Passenger pays nothing, but driver receives full price
        return new PaymentResult(originalPrice, pointsNeeded, true);
    }

    /**
     * Calculate loyalty points earned from completed ride.
     * Passenger earns 5% of ride cost as points.
     * 
     * @param ridePrice the ride price
     * @return points to award (rounded down)
     */
    public int calculatePointsEarned(double ridePrice) {
        return (int) Math.floor(ridePrice * 0.05);
    }
}