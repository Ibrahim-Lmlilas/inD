package com.srrfrr.api.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import com.srrfrr.api.enums.Ride.VehicleType;

import java.time.LocalDate;

@Getter
@Setter
public class CreateDriverRequest {

    @NotBlank(message = "Cin code is required")
    private String cinCode;

    @NotNull(message = "Expiration Date is required")
    private LocalDate expirationDate;

    @NotNull(message = "Vehicle type is required")
    private VehicleType vehicleType;

    @NotNull(message = "Cin recto is required")
    private MultipartFile cinRecto;

    @NotNull(message = "Cin verso is required")
    private MultipartFile cinVerso;

    @NotNull(message = "Vehicle picture is required")
    private MultipartFile vehiclePicture;

    @NotNull(message = "Vehicle registration recto is required")
    private MultipartFile vehicleRegistrationRecto;

    @NotNull(message = "Vehicle registration verso is required")
    private MultipartFile vehicleRegistrationVerso;

    @NotNull(message = "selfie is required")
    private MultipartFile selfie;

    @NotBlank(message = "Vehicle registration code is required")
    private String vehicleRegistrationCode;

    @NotBlank(message = "Vehicle brand is required")
    private String vehicleBrand;

    @NotBlank(message = "Vehicle model is required")
    private String vehicleModel;

    @NotBlank(message = "Vehicle color is required")
    private String vehicleColor;

    @NotBlank(message = "Production year is required")
    private String productionYear;

}
