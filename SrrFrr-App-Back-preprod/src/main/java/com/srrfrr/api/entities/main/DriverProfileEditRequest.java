package com.srrfrr.api.entities.main;

import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.user.Approval;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "driver_profile_edit_request", schema = "app_mobile")
public class DriverProfileEditRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false)
    private Driver driver;

    @Column(name = "requested_first_name")
    private String requestedFirstName;

    @Column(name = "requested_last_name")
    private String requestedLastName;

    @Column(name = "requested_vehicle_brand")
    private String requestedVehicleBrand;

    @Column(name = "requested_vehicle_model")
    private String requestedVehicleModel;

    @Column(name = "requested_vehicle_color")
    private String requestedVehicleColor;

    @Column(name = "requested_vehicle_registration_code")
    private String requestedVehicleRegistrationCode;

    @Column(name = "requested_production_year")
    private String requestedProductionYear;

    @Enumerated(EnumType.STRING)
    @Column(name = "requested_vehicle_type")
    private VehicleType requestedVehicleType;

    @Column(name = "requested_cin_recto")
    private String requestedCinRecto;

    @Column(name = "requested_cin_verso")
    private String requestedCinVerso;

    @Column(name = "requested_selfie")
    private String requestedSelfie;

    @Column(name = "requested_vehicle_picture")
    private String requestedVehiclePicture;

    @Column(name = "requested_vehicle_registration_recto")
    private String requestedVehicleRegistrationRecto;

    @Column(name = "requested_vehicle_registration_verso")
    private String requestedVehicleRegistrationVerso;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Approval status = Approval.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
