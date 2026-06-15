package com.srrfrr.api.entities.main;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.Ride.VehicleType;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "rides", schema = "app_mobile")
public class Ride {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    private UUID id;

    @Column(name = "passenger_id")
    private UUID passengerId;

    @Column(name = "driver_id")
    private UUID driverId;

    // Add relationships to fetch passenger and driver details
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id", insertable = false, updatable = false)
    @JsonProperty("passenger")
    private Passenger passenger;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", insertable = false, updatable = false)
    @JsonProperty("driver")
    private Driver driver;

    @Column(nullable = false)
    private String departureAddress;

    @Column(nullable = false)
    private double departureLat;

    @Column(nullable = false)
    private double departureLng;

    @Column(nullable = false)
    private String departureCity;

    @Column(nullable = false)
    private String destinationAddress;

    @Column(nullable = false)
    private double destinationLat;

    @Column(nullable = false)
    private double destinationLng;

    @Column(nullable = false)
    private String destinationCity;

    @Column(nullable = false)
    private double price;

    @NotNull(message = "Vehicle type is required")
    @Column(name = "vehicle_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private VehicleType vehicleType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RideStatus status;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
    private String rideType;
    private int seats;
    private double distanceKm;
    private String estimatedTime;

    @Column(name = "payment_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private PaymentType paymentType;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}