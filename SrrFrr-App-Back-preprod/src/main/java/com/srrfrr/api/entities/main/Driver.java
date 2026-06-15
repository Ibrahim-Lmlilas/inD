package com.srrfrr.api.entities.main;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.srrfrr.api.enums.Ride.VehicleType;
import com.srrfrr.api.enums.user.Approval;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "driver", schema = "app_mobile")
public class Driver {

    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.EAGER)
    @MapsId
    @JoinColumn(name = "id")
    @JsonIgnore
    private Passenger passenger;

    @NotBlank(message = "CIN recto image is required")
    @Column(name = "cin_recto", nullable = false)
    private String cinRecto;

    @NotBlank(message = "CIN verso image is required")
    @Column(name = "cin_verso", nullable = false)
    private String cinVerso;

    @NotBlank(message = "CIN code is required")
    @Column(name = "cin_code", nullable = false)
    private String cinCode;

    @NotBlank(message = "selfie is required")
    @Column(name = "selfie", nullable = false)
    private String selfie;

    @NotNull(message = "Expiration Date is required")
    @Column(name = "expiration_Date", nullable = false)
    private LocalDate expirationDate;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "validated_at")
    private LocalDateTime validatedAt;

    @Column(name = "rejected_at")
    private LocalDateTime rejectedAt;

    @NotNull(message = "Vehicle type is required")
    @Column(name = "vehicle_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private VehicleType vehicleType;

    @NotBlank(message = "Vehicle picture is required")
    @Column(name = "vehicle_picture", nullable = false)
    private String vehiclePicture;

    @NotBlank(message = "Vehicle registration recto is required")
    @Column(name = "vehicle_registration_recto", nullable = false)
    private String vehicleRegistrationRecto;

    @NotBlank(message = "Vehicle registration verso is required")
    @Column(name = "vehicle_registration_verso", nullable = false)
    private String vehicleRegistrationVerso;

    @NotBlank(message = "Vehicle registration code is required")
    @Column(name = "vehicle_registration_code", nullable = false)
    private String vehicleRegistrationCode;

    @NotBlank(message = "Vehicle brand is required")
    @Column(name = "vehicle_brand", nullable = false)
    private String vehicleBrand;

    @NotBlank(message = "Vehicle model is required")
    @Column(name = "vehicle_model", nullable = false)
    private String vehicleModel;

    @NotBlank(message = "Vehicle color is required")
    @Column(name = "vehicle_color", nullable = false)
    private String vehicleColor;

    @NotBlank(message = "Production year is required")
    @Column(name = "production_year", nullable = false)
    private String productionYear;

    @Enumerated(EnumType.STRING)
    @Column(name = "approval", nullable = false)
    private Approval approval = Approval.PENDING;

    @NotNull(message = "Online is required")
    @Column(name = "online", nullable = false)
    private boolean online = false;

    @Column(name = "total_rides", nullable = false)
    private int totalRides = 0;

    @Column(name = "rating", nullable = false)
    private double rating = 0.0;

    @Column(name = "is_verified", nullable = false)
    private boolean isVerified = false;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "active_subscription_id")
    private DriverSubscription activeSubscription;

    @OneToOne(mappedBy = "driver", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private Wallet wallet;

    public double getWalletBalance() {
        return wallet != null ? wallet.getBalance() : 0.0;
    }

    public void validate() {
        this.approval = Approval.VALIDATED;
        this.validatedAt = LocalDateTime.now();
        this.rejectedAt = null;
    }

    public void reject() {
        this.approval = Approval.REJECTED;
        this.rejectedAt = LocalDateTime.now();
        this.validatedAt = null;
    }

    public void toggleVerified() {
        this.isVerified = !this.isVerified;
    }
}