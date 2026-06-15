package com.srrfrr.api.dto.ride;

import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RideDTO {
    private UUID id;
    private UUID passengerId;
    private UUID driverId;

    private String departureAddress;
    private double departureLat;
    private double departureLng;
    private String departureCity;

    private String destinationAddress;
    private double destinationLat;
    private double destinationLng;
    private String destinationCity;

    private double price;
    private String rideType;
    private String vehicleType;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehicleColor;
    private int seats;
    private double distanceKm;
    private String estimatedTime;

    private RideStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private PaymentType paymentType;

    private Boolean isRated;
    private boolean isVerified;

    private HistoryPassengerResponse passenger;
    private HistoryDriverResponse driver;
}
