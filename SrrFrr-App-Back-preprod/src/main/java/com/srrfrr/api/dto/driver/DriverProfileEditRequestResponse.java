package com.srrfrr.api.dto.driver;

import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.user.Approval;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class DriverProfileEditRequestResponse {
    private UUID id;
    private UUID driverId;
    private UUID passengerId;
    private Approval status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String driverFirstName;
    private String driverLastName;

    private String requestedFirstName;
    private String requestedLastName;
    private String requestedVehicleBrand;
    private String requestedVehicleModel;
    private String requestedVehicleColor;
    private String requestedVehicleRegistrationCode;
    private String requestedProductionYear;
    private VehicleType requestedVehicleType;

    private String requestedCinRectoUrl;
    private String requestedCinVersoUrl;
    private String requestedSelfieUrl;
    private String requestedVehiclePictureUrl;
    private String requestedVehicleRegistrationRectoUrl;
    private String requestedVehicleRegistrationVersoUrl;
}
