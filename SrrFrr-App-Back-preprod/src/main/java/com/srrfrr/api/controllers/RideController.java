package com.srrfrr.api.controllers;

import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.ApiResponse;
import com.srrfrr.api.dto.ride.RideDTO;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.services.ride.RideService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Controller for ride operations.
 * Handles ride history retrieval with advanced filtering.
 */
@RestController
@RequestMapping("/rides")
public class RideController {
    private final RideService rideService;

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;

    public RideController(final RideService rideService) {
        this.rideService = rideService;
    }

    /**
     * Get paginated ride history for passenger with advanced filters.
     * 
     * @param passenger authenticated user
     * @param page page number (0-indexed, default: 0)
     * @param size page size (default: 20, max: 100)
     * @param status filter by ride status
     * @param paymentType filter by payment type
     * @param vehicleType filter by vehicle type
     * @param driverName search by driver name
     * @param startDate filter rides from this date
     * @param endDate filter rides until this date
     * @param minPrice filter rides with minimum price
     * @param maxPrice filter rides with maximum price
     * @return paginated ride history
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/history/passenger")
    public ResponseEntity<ApiResponse<Page<RideDTO>>> getPassengerRideHistory(
            @AuthenticationPrincipal final Passenger passenger,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size,
            @RequestParam(required = false) final RideStatus status,
            @RequestParam(required = false) final PaymentType paymentType,
            @RequestParam(required = false) final String vehicleType,
            @RequestParam(required = false) final String driverName,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) final LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) final LocalDateTime endDate,
            @RequestParam(required = false) final Double minPrice,
            @RequestParam(required = false) final Double maxPrice) {

        // Validate and limit page size
        final int validatedSize = Math.min(size, MAX_PAGE_SIZE);
        
        // Create pageable with descending order (newest first)
        final Pageable pageable = PageRequest.of(
            page, 
            validatedSize, 
            Sort.by(Sort.Direction.DESC, "createdAt")
        );

        final Page<RideDTO> rides = rideService.getRidesForPassengerWithFilters(
            passenger.getId(),
            pageable,
            status,
            paymentType,
            vehicleType,
            driverName,
            startDate,
            endDate,
            minPrice,
            maxPrice
        );
        
        return ResponseEntity.ok(ApiResponse.success(rides));
    }

    /**
     * Get paginated ride history for driver with advanced filters.
     * 
     * @param passenger authenticated user (must have driver profile)
     * @param page page number (0-indexed, default: 0)
     * @param size page size (default: 20, max: 100)
     * @param status filter by ride status
     * @param paymentType filter by payment type
     * @param vehicleType filter by vehicle type
     * @param passengerName search by passenger name
     * @param startDate filter rides from this date
     * @param endDate filter rides until this date
     * @param minPrice filter rides with minimum price
     * @param maxPrice filter rides with maximum price
     * @return paginated ride history
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/history/driver")
    public ResponseEntity<ApiResponse<Page<RideDTO>>> getDriverRideHistory(
            @AuthenticationPrincipal final Passenger passenger,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size,
            @RequestParam(required = false) final RideStatus status,
            @RequestParam(required = false) final PaymentType paymentType,
            @RequestParam(required = false) final String vehicleType,
            @RequestParam(required = false) final String passengerName,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) final LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) final LocalDateTime endDate,
            @RequestParam(required = false) final Double minPrice,
            @RequestParam(required = false) final Double maxPrice) {

        if (passenger.getDriverProfile() == null) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.errorWithType("Driver profile required to view driver ride history"));
        }

        // Validate and limit page size
        final int validatedSize = Math.min(size, MAX_PAGE_SIZE);
        
        // Create pageable with descending order (newest first)
        final Pageable pageable = PageRequest.of(
            page, 
            validatedSize, 
            Sort.by(Sort.Direction.DESC, "createdAt")
        );

        final Page<RideDTO> rides = rideService.getRidesForDriverWithFilters(
            passenger.getDriverProfile().getId(),
            pageable,
            status,
            paymentType,
            vehicleType,
            passengerName,
            startDate,
            endDate,
            minPrice,
            maxPrice
        );
        
        return ResponseEntity.ok(ApiResponse.success(rides));
    }

    /**
     * Get ride status for authenticated user.
     * User must be either the passenger or driver of the ride.
     * 
     * @param rideId the ride ID
     * @param passenger authenticated user
     * @return ride status
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/status/{rideId}")
    public ObjectNode getRideStatus(
            @PathVariable final UUID rideId,
            @AuthenticationPrincipal final Passenger passenger) {
        return rideService.getRideStatusForUser(rideId, passenger);
    }
}