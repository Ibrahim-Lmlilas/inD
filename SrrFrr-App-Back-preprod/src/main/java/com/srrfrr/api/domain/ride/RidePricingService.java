package com.srrfrr.api.domain.ride;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Domain service for ride pricing calculations.
 * Pure business logic with no external dependencies.
 */
@Component
@Slf4j
public class RidePricingService {

    private static final double BASE_RATE = 3.5;
    private static final double MINIMUM_PRICE = 10.0;

    private static final Map<Integer, Double> DISTANCE_COEFFICIENTS = Map.ofEntries(
            Map.entry(1, 1.7),
            Map.entry(2, 1.6),
            Map.entry(3, 1.5),
            Map.entry(4, 1.4),
            Map.entry(5, 1.3),
            Map.entry(6, 1.2),
            Map.entry(7, 1.1),
            Map.entry(8, 1.0),
            Map.entry(9, 0.9),
            Map.entry(10, 0.8),
            Map.entry(11, 0.7),
            Map.entry(12, 0.6)
    );

    /**
     * Calculate ride price based on distance using tiered coefficient system.
     * 
     * Formula: price = distance * (BASE_RATE + coefficient)
     * Minimum price is enforced.
     * 
     * @param distanceKm the distance in kilometers
     * @return calculated price in DH
     */
    public double calculateRidePrice(double distanceKm) {
        if (distanceKm < 0) {
            throw new IllegalArgumentException("Distance cannot be negative");
        }

        int distanceInt = (int) Math.ceil(distanceKm);
        double coefficient = getDistanceCoefficient(distanceInt);
        double price = distanceKm * (BASE_RATE + coefficient);
        
        return Math.max(price, MINIMUM_PRICE);
    }

    /**
     * Calculate the final price considering base price and offered price.
     * Takes the maximum of system-calculated price and driver's offered price.
     * 
     * @param systemPrice calculated system price
     * @param offeredPrice price offered by driver
     * @return final base price before any discounts
     */
    public double calculateBasePrice(double systemPrice, double offeredPrice) {
        return Math.max(systemPrice, offeredPrice);
    }

    /**
     * Get distance coefficient based on distance tier.
     * Longer distances get lower coefficients (discounts).
     * 
     * @param distanceKm distance in kilometers (rounded up)
     * @return coefficient multiplier
     */
    private double getDistanceCoefficient(int distanceKm) {
        return DISTANCE_COEFFICIENTS.getOrDefault(distanceKm, 0.5);
    }

    /**
     * Calculate price breakdown for transparency.
     * 
     * @param distanceKm the distance in kilometers
     * @return pricing breakdown details
     */
    public PriceBreakdown getPriceBreakdown(double distanceKm) {
        int distanceInt = (int) Math.ceil(distanceKm);
        double coefficient = getDistanceCoefficient(distanceInt);
        double calculatedPrice = distanceKm * (BASE_RATE + coefficient);
        double finalPrice = Math.max(calculatedPrice, MINIMUM_PRICE);
        
        boolean minimumApplied = calculatedPrice < MINIMUM_PRICE;

        return new PriceBreakdown(
            distanceKm,
            BASE_RATE,
            coefficient,
            calculatedPrice,
            finalPrice,
            minimumApplied
        );
    }

    /**
     * Value object for price breakdown.
     */
    public record PriceBreakdown(
        double distance,
        double baseRate,
        double coefficient,
        double calculatedPrice,
        double finalPrice,
        boolean minimumPriceApplied
    ) {}
}