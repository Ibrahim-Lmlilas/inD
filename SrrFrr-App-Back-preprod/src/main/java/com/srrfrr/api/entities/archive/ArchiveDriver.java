package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.user.Approval;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "driver", schema = "archive")
public class ArchiveDriver {

    @Id
    private UUID id;

    @Column(name = "cin_recto")
    private String cinRecto;

    @Column(name = "cin_verso")
    private String cinVerso;

    @Column(name = "cin_code")
    private String cinCode;

    @Column(name = "selfie")
    private String selfie;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "validated_at")
    private LocalDateTime validatedAt;

    @Column(name = "rejected_at")
    private LocalDateTime rejectedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "vehicle_type")
    private VehicleType vehicleType;

    @Column(name = "vehicle_picture")
    private String vehiclePicture;

    @Column(name = "vehicle_registration_recto")
    private String vehicleRegistrationRecto;

    @Column(name = "vehicle_registration_verso")
    private String vehicleRegistrationVerso;

    @Column(name = "vehicle_registration_code")
    private String vehicleRegistrationCode;

    @Column(name = "vehicle_brand")
    private String vehicleBrand;

    @Column(name = "vehicle_model")
    private String vehicleModel;

    @Column(name = "vehicle_color")
    private String vehicleColor;

    @Column(name = "production_year")
    private String productionYear;

    @Enumerated(EnumType.STRING)
    @Column(name = "approval")
    private Approval approval;

    @Column(name = "online")
    private Boolean online;

    @Column(name = "total_rides")
    private Integer totalRides;

    @Column(name = "rating")
    private Double rating;

    @Column(name = "is_verified")
    private Boolean isVerified;

    @Column(name = "active_subscription_id")
    private UUID activeSubscriptionId;

    public static ArchiveDriver fromMain(Driver driver) {
        return ArchiveDriver.builder()
                .id(driver.getId())
                .cinRecto(driver.getCinRecto())
                .cinVerso(driver.getCinVerso())
                .cinCode(driver.getCinCode())
                .selfie(driver.getSelfie())
                .expirationDate(driver.getExpirationDate())
                .createdAt(driver.getCreatedAt())
                .updatedAt(driver.getUpdatedAt())
                .validatedAt(driver.getValidatedAt())
                .rejectedAt(driver.getRejectedAt())
                .vehicleType(driver.getVehicleType())
                .vehiclePicture(driver.getVehiclePicture())
                .vehicleRegistrationRecto(driver.getVehicleRegistrationRecto())
                .vehicleRegistrationVerso(driver.getVehicleRegistrationVerso())
                .vehicleRegistrationCode(driver.getVehicleRegistrationCode())
                .vehicleBrand(driver.getVehicleBrand())
                .vehicleModel(driver.getVehicleModel())
                .vehicleColor(driver.getVehicleColor())
                .productionYear(driver.getProductionYear())
                .approval(driver.getApproval())
                .online(driver.isOnline())
                .totalRides(driver.getTotalRides())
                .rating(driver.getRating())
                .isVerified(driver.isVerified())
                .activeSubscriptionId(
                        driver.getActiveSubscription() != null ? driver.getActiveSubscription().getId() : null)
                .build();
    }
}