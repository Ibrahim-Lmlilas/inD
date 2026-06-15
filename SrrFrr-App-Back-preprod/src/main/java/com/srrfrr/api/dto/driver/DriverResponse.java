package com.srrfrr.api.dto.driver;

import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.subscription.*;
import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.user.Approval;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverResponse {
    // Identification
    private UUID id;

    // Personal info (from Passenger)
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String profilePicture;

    // Rating and statistics
    private double rating;
    private int totalRides;
    private boolean isVerified;
    private boolean online;

    // Vehicle information
    private VehicleType vehicleType;
    private String vehiclePicture;
    private String vehicleRegistrationCode;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehicleColor;
    private String productionYear;
    private double wallet;

    // Status and timestamps
    private Approval approval;
    // private LocalDateTime createdAt;
    // private LocalDateTime updatedAt;
    // private LocalDateTime validatedAt;
    // private LocalDateTime rejectedAt;
    private ObjectNode currentRide;
    private SubscriptionResponse subscription;

}