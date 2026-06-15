package com.srrfrr.api.services.ride;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.driver.DriverLocation;
import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.mapper.RideMapper;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.services.location.DriverLocationService;
import com.srrfrr.api.services.location.GeoUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * Service for managing current active rides.
 * Consolidates logic for fetching and enriching current ride information.
 */
@Service
@Slf4j
public class CurrentRideService {
    private final RideRepository rideRepository;
    private final RideMapper rideMapper;
    private final DriverLocationService driverLocationService;
    private final ObjectMapper objectMapper;

    public CurrentRideService(
            final RideRepository rideRepository,
            final RideMapper rideMapper,
            final DriverLocationService driverLocationService,
            final ObjectMapper objectMapper) {
        this.rideRepository = rideRepository;
        this.rideMapper = rideMapper;
        this.driverLocationService = driverLocationService;
        this.objectMapper = objectMapper;
    }

    /**
     * Get current active ride for a passenger.
     * Returns STARTED ride first, then ACCEPTED if no STARTED ride exists.
     * 
     * @param passengerId the passenger ID
     * @return current ride response or null if no active ride
     */
    public ObjectNode getCurrentRideForPassenger(UUID passengerId) {
        Ride ride = findActiveRideForPassenger(passengerId);
        
        if (ride == null) {
            return null;
        }

        return rideMapper.buildRideResponse(ride, "passenger", passengerId);
    }

    /**
     * Get current active ride for a driver with location enrichment.
     * Includes driver location updates and distance calculations.
     * 
     * @param driverId the driver ID
     * @return current ride response with location data, or null if no active ride
     */
    public ObjectNode getCurrentRideForDriver(UUID driverId) {
        Ride ride = findActiveRideForDriver(driverId);
        
        if (ride == null) {
            return null;
        }

        ObjectNode rideResponse = rideMapper.buildRideResponse(ride, "driver", driverId);
        enrichWithDriverLocation(rideResponse, ride, driverId);
        
        return rideResponse;
    }

    /**
     * Find active ride for passenger.
     * Priority: STARTED > ACCEPTED
     * 
     * @param passengerId the passenger ID
     * @return active ride or null
     */
    private Ride findActiveRideForPassenger(UUID passengerId) {
        return rideRepository.findActiveRideForPassenger(passengerId).orElse(null);
    }

    /**
     * Find active ride for driver.
     * Priority: STARTED > ACCEPTED
     * 
     * @param driverId the driver ID
     * @return active ride or null
     */
    private Ride findActiveRideForDriver(UUID driverId) {
        return rideRepository.findActiveRideForDriver(driverId).orElse(null);
    }

    /**
     * Enrich ride response with driver location data.
     * Adds distance calculations based on ride status.
     * 
     * @param rideResponse the ride response to enrich
     * @param ride the ride entity
     * @param driverId the driver ID
     */
    private void enrichWithDriverLocation(ObjectNode rideResponse, Ride ride, UUID driverId) {
        DriverLocation lastLocation = driverLocationService.getLastDriverLocation(driverId);

        if (lastLocation == null) {
            log.debug("No last location found for driver {}", driverId);
            return;
        }

        ObjectNode locationData = objectMapper.createObjectNode();
        locationData.put("latitude", lastLocation.getLatitude());
        locationData.put("longitude", lastLocation.getLongitude());
        locationData.put("timestamp", lastLocation.getTimestamp());
        locationData.put("ageMinutes", lastLocation.getAgeInMinutes());

        // Calculate distance based on ride status
        if (ride.getStatus() == RideStatus.ACCEPTED) {
            // Distance to pickup point
            double distanceToPickup = GeoUtils.distance(
                    lastLocation.getLatitude(),
                    lastLocation.getLongitude(),
                    ride.getDepartureLat(),
                    ride.getDepartureLng()
            );
            locationData.put("distanceToPickup", distanceToPickup);
            
        } else if (ride.getStatus() == RideStatus.STARTED) {
            // Distance to destination
            double distanceToDestination = GeoUtils.distance(
                    lastLocation.getLatitude(),
                    lastLocation.getLongitude(),
                    ride.getDestinationLat(),
                    ride.getDestinationLng()
            );
            locationData.put("distanceToDestination", distanceToDestination);
        }

        rideResponse.set("driverLocationUpdate", locationData);
        log.debug("Added location data for driver {} in ride {}", driverId, ride.getId());
    }
}