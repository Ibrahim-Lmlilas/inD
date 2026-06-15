package com.srrfrr.api.websocket.model;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.utils.DebugConsole;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Collections;
import java.util.Set;

/**
 * Represents a ride offer from a passenger to nearby drivers.
 * Tracks ride details, pricing, and driver responses.
 */
@Getter
@Setter
public class RideOffer {
    private final String rideId;
    private final String passengerId;
    private final double fromLat;
    private final double fromLng;
    private final double toLat;
    private final double toLng;
    private final Set<Long> h3Neighbors;
    private final LocalDateTime createdAt;

    // Passenger details
    private final Passenger passengerEntity;

    // Location details
    private final String departureAddress;
    private final String departureCity;
    private final String destinationAddress;
    private final String destinationCity;

    // Ride details
    private final String rideType;
    private final String vehicleType;
    private final int seats;
    private final double distanceKm;
    private final String estimatedTime;
    private final PaymentType paymentType;

    // Pricing
    /**
     * Current ride price (updated when counter-offers are made)
     * - For free ride: 0 DH (passenger pays nothing)
     * - For regular payment: full price passenger pays
     */
    private double price;

    /** Last price explicitly set by the passenger — restored when a driver's offer is rejected. */
    private double lastPassengerPrice;

    /**
     * Indicates if this is a free ride paid with loyalty points
     * True when passenger used points, false for cash/card payment
     */
    private boolean isFreeRide;

    // State management
    private boolean accepted;
    private String acceptedDriverId;

    /**
     * Driver who made the most recent offer (waiting for passenger response)
     * Null if no pending driver offer
     */
    private String pendingDriverId;

    // WebSocket session
    private WebSocketSession passengerSession;

    /**
     * Drivers who rejected this ride (prevents re-showing)
     */
    private final Set<String> rejectedDriverIds = new HashSet<>();

    public RideOffer(String rideId, String passengerId, double fromLat, double fromLng,
            double toLat, double toLng, double price, Set<Long> h3Neighbors,
            Passenger passengerEntity, String departureAddress, String departureCity,
            String destinationAddress, String destinationCity, String rideType,
            String vehicleType, int seats, double distanceKm, String estimatedTime,
            PaymentType paymentType) {
        this.rideId = rideId;
        this.passengerId = passengerId;
        this.fromLat = fromLat;
        this.fromLng = fromLng;
        this.toLat = toLat;
        this.toLng = toLng;
        this.price = price;
        this.lastPassengerPrice = price;
        this.isFreeRide = false; // Default to regular payment
        this.h3Neighbors = h3Neighbors;
        this.passengerEntity = passengerEntity;
        this.departureAddress = departureAddress;
        this.departureCity = departureCity;
        this.destinationAddress = destinationAddress;
        this.destinationCity = destinationCity;
        this.rideType = rideType;
        this.vehicleType = vehicleType;
        this.paymentType = paymentType;
        this.seats = seats;
        this.distanceKm = distanceKm;
        this.estimatedTime = estimatedTime;
        this.createdAt = LocalDateTime.now();
        this.accepted = false;
    }

    /**
     * Check if offer has expired based on timeout.
     * 
     * @param timeoutMinutes timeout in minutes
     * @return true if expired
     */
    public boolean isExpired(int timeoutMinutes) {
        return createdAt.plusMinutes(timeoutMinutes).isBefore(LocalDateTime.now());
    }

    /**
     * Add driver to rejected list (prevents ride from reappearing to this driver).
     * 
     * @param driverId the driver ID to add
     */
    public void addRejectedDriver(String driverId) {
        rejectedDriverIds.add(driverId);
        DebugConsole.info(
                "RideManagement",
                String.format("Added driver %s to rejected list for ride %s", driverId, this.rideId));
    }

    /**
     * Check if driver has rejected this ride.
     * 
     * @param driverId the driver ID to check
     * @return true if driver rejected this ride
     */
    public boolean isRejectedByDriver(String driverId) {
        return rejectedDriverIds.contains(driverId);
    }

    /**
     * Get all rejected driver IDs (immutable view).
     * 
     * @return unmodifiable set of rejected driver IDs
     */
    public Set<String> getRejectedDriverIds() {
        return Collections.unmodifiableSet(rejectedDriverIds);
    }

    /**
     * Get count of drivers who rejected this ride.
     * 
     * @return number of rejected drivers
     */
    public int getRejectedDriverCount() {
        return rejectedDriverIds.size();
    }
}