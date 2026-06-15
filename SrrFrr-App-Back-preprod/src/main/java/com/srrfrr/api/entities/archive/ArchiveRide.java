package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.Ride.VehicleType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "rides", schema = "archive")
public class ArchiveRide {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "passenger_id")
    private UUID passengerId;

    @Column(name = "driver_id")
    private UUID driverId;

    @Column(name = "departure_address")
    private String departureAddress;

    @Column(name = "departure_lat")
    private Double departureLat;

    @Column(name = "departure_lng")
    private Double departureLng;

    @Column(name = "departure_city")
    private String departureCity;

    @Column(name = "destination_address")
    private String destinationAddress;

    @Column(name = "destination_lat")
    private Double destinationLat;

    @Column(name = "destination_lng")
    private Double destinationLng;

    @Column(name = "destination_city")
    private String destinationCity;

    @Column(name = "price")
    private Double price;

    @Enumerated(EnumType.STRING)
    @Column(name = "vehicle_type")
    private VehicleType vehicleType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private RideStatus status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "ride_type")
    private String rideType;

    @Column(name = "seats")
    private Integer seats;

    @Column(name = "distance_km")
    private Double distanceKm;

    @Column(name = "estimated_time")
    private String estimatedTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_type")
    private PaymentType paymentType;

    public static ArchiveRide fromMain(Ride ride) {
        return ArchiveRide.builder()
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
                .vehicleType(ride.getVehicleType())
                .status(ride.getStatus())
                .createdAt(ride.getCreatedAt())
                .updatedAt(ride.getUpdatedAt())
                .rideType(ride.getRideType())
                .seats(ride.getSeats())
                .distanceKm(ride.getDistanceKm())
                .estimatedTime(ride.getEstimatedTime())
                .paymentType(ride.getPaymentType())
                .build();
    }
}