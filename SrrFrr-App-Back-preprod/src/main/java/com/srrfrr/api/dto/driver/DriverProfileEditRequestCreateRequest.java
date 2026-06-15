package com.srrfrr.api.dto.driver;

import com.srrfrr.api.enums.Ride.VehicleType;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class DriverProfileEditRequestCreateRequest {
    private String firstName;
    private String lastName;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehicleColor;
    private String vehicleRegistrationCode;
    private String productionYear;
    private VehicleType vehicleType;

    private MultipartFile cinRecto;
    private MultipartFile cinVerso;
    private MultipartFile selfie;
    private MultipartFile vehiclePicture;
    private MultipartFile vehicleRegistrationRecto;
    private MultipartFile vehicleRegistrationVerso;
}
