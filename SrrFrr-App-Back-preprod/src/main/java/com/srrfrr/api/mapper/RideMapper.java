package com.srrfrr.api.mapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.driver.DriverLocation;
import com.srrfrr.api.dto.ride.RideDTO;
import com.srrfrr.api.entities.main.ChatChannel;
import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.repositories.main.rating.RatingRepository;
import com.srrfrr.api.services.auth.TokenService;
import com.srrfrr.api.services.chat.ChatService;
import com.srrfrr.api.services.location.DriverLocationService;
import com.srrfrr.api.services.location.GeoUtils;

import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Getter
@Setter
@Slf4j
@Component
public class RideMapper {
    private final TokenService tokenService;
    private final DriverLocationService driverLocationService;
    private final ObjectMapper objectMapper;
    private final ChatService chatService;
    private final RatingRepository ratingRepository;

    public RideMapper(
            TokenService tokenService,
            DriverLocationService driverLocationService,
            ObjectMapper objectMapper,
            ChatService chatService,
            RatingRepository ratingRepository) {
        this.tokenService = tokenService;
        this.driverLocationService = driverLocationService;
        this.objectMapper = objectMapper;
        this.chatService = chatService;
        this.ratingRepository = ratingRepository;
    }

    /**
     * Convert Ride entity to DTO with accurate rating check.
     * 
     * @param ride          the ride entity
     * @param currentUserId the current user viewing the ride
     * @return DTO with accurate isRated status
     */
    public RideDTO toDTO(Ride ride, UUID currentUserId) {
        if (ride == null)
            return null;

        // Check if current user has rated this ride
        boolean isRated = currentUserId != null &&
                ratingRepository.existsByRideIdAndSenderId(ride.getId(), currentUserId);

        return RideDTO.builder()
                .id(ride.getId())
                .passengerId(ride.getPassengerId())
                .driverId(ride.getDriverId())
                .departureAddress(ride.getDepartureAddress())
                .departureLat(ride.getDepartureLat())
                .departureLng(ride.getDepartureLng())
                .departureCity(ride.getDepartureCity())
                .destinationAddress(ride.getDestinationAddress())
                .destinationLat(ride.getDestinationLat())
                .destinationLng(ride.getDestinationLng())
                .destinationCity(ride.getDestinationCity())
                .price(ride.getPrice())
                .rideType(ride.getRideType())
                .vehicleType(ride.getVehicleType().toString())
                .vehicleBrand(ride.getDriver() != null ? ride.getDriver().getVehicleBrand() : null)
                .vehicleModel(ride.getDriver() != null ? ride.getDriver().getVehicleModel() : null)
                .vehicleColor(ride.getDriver() != null ? ride.getDriver().getVehicleColor() : null)
                .seats(ride.getSeats())
                .distanceKm(ride.getDistanceKm())
                .estimatedTime(ride.getEstimatedTime())
                .status(ride.getStatus())
                .createdAt(ride.getCreatedAt())
                .updatedAt(ride.getUpdatedAt())
                .paymentType(ride.getPaymentType())
                .isRated(isRated)
                .isVerified(ride.getDriver() != null && ride.getDriver().isVerified())
                .passenger(PassengerMapper.toPassengerDTO(ride.getPassenger()))
                .driver(ride.getDriver() != null ? DriverMapper.toDriverDTO(ride.getDriver()) : null)
                .build();
    }

    /**
     * Build complete ride response with chat channel and WebSocket token.
     * Used for active ride tracking.
     * 
     * @param ride   the ride entity
     * @param role   "passenger" or "driver"
     * @param userId the current user ID
     * @return complete ride response with all metadata
     */
    public ObjectNode buildRideResponse(Ride ride, String role, UUID userId) {
        // Convert to DTO with rating check
        RideDTO rideDTO = toDTO(ride, userId);

        // Get or create chat channel
        ChatChannel channel = chatService.getOrCreateChannelForRide(
                ride,
                ride.getDriverId(),
                ride.getPassengerId());
        String channelId = channel.getId().toString();

        // Generate WebSocket token
        String wsToken = tokenService.generateWebSocketToken(
                userId.toString(),
                channelId);

        // Convert DTO to JSON
        ObjectNode msg = objectMapper.valueToTree(rideDTO);

        // Add dynamic fields
        msg.put("type", "CurrentRide");
        msg.put("channelId", channelId);
        msg.put("wsToken", wsToken);
        msg.put("message", role.equals("passenger")
                ? "Ride confirmed! Your driver is on the way."
                : "The passenger accepted your offer!");

        // Add driver location
        addLastKnownLocation(msg, ride);

        return msg;
    }

    /**
     * Add driver's last known location to ride response.
     * Calculates distance to pickup or destination based on ride status.
     */
    private void addLastKnownLocation(ObjectNode rideResponse, Ride ride) {
        try {
            DriverLocation lastLocation = driverLocationService.getLastDriverLocation(
                    ride.getDriverId());

            if (lastLocation != null) {
                ObjectNode locationData = objectMapper.createObjectNode();
                locationData.put("latitude", lastLocation.getLatitude());
                locationData.put("longitude", lastLocation.getLongitude());
                locationData.put("timestamp", lastLocation.getTimestamp());
                locationData.put("ageMinutes", lastLocation.getAgeInMinutes());

                if (ride.getStatus() == RideStatus.ACCEPTED) {
                    // Driver heading to pickup
                    double distanceToPickup = GeoUtils.distance(
                            lastLocation.getLatitude(),
                            lastLocation.getLongitude(),
                            ride.getDepartureLat(),
                            ride.getDepartureLng());
                    locationData.put("distanceToPickup", distanceToPickup);
                    locationData.put("distanceToPickupKm",
                            String.format("%.2f km", distanceToPickup));

                } else if (ride.getStatus() == RideStatus.STARTED) {
                    // Driver heading to destination
                    double distanceToDestination = GeoUtils.distance(
                            lastLocation.getLatitude(),
                            lastLocation.getLongitude(),
                            ride.getDestinationLat(),
                            ride.getDestinationLng());
                    locationData.put("distanceToDestination", distanceToDestination);
                    locationData.put("distanceToDestinationKm",
                            String.format("%.2f km", distanceToDestination));
                }

                locationData.put("isRecent", lastLocation.isRecent(5));
                rideResponse.set("driverLocationUpdate", locationData);

                log.debug("Added last known location for driver {} in ride {}: lat={}, lng={}",
                        ride.getDriverId(), ride.getId(),
                        lastLocation.getLatitude(), lastLocation.getLongitude());
            } else {
                log.debug("No last location found for driver {} in ride {}",
                        ride.getDriverId(), ride.getId());
            }
        } catch (Exception e) {
            log.error("Failed to add last known location for driver {} in ride {}: {}",
                    ride.getDriverId(), ride.getId(), e.getMessage());
        }
    }
}