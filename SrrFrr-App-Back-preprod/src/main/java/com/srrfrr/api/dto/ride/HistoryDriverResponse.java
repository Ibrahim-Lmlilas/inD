package com.srrfrr.api.dto.ride;

import lombok.*;

import java.util.UUID;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HistoryDriverResponse {
    // Identification
    private UUID id;

    // Personal info (from Passenger)
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String profilePicture;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehicleColor;
    private String vehicleRegistrationCode;

    // Rating and statistics
    private double rating;
    private int totalRides;

}