package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Setter
@Getter
@Table(name = "authentication", schema = "app_mobile")
public class Authentication {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, unique = true)
    private UUID id;

    @NotBlank(message = "Refresh Token cannot be null")
    @Column(name = "refresh_token", nullable = false)
    private String refreshToken;

    @NotNull(message = "Etat cannot be null")
    @Column(name = "is_valid", nullable = false)
    private boolean isvalid = true;

    @NotBlank(message = "Firebase Token cannot be null")
    @Column(name = "fcm_token", nullable = false)
    private String fcmToken;

    @NotBlank(message = "Device ID cannot be null")
    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "passenger_id", referencedColumnName = "id", nullable = false)
    private Passenger passenger;
}
