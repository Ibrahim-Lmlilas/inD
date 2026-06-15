package com.srrfrr.api.entities.main;

import com.srrfrr.api.annotations.ValidPhoneNumber;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "otp", schema = "app_mobile")
@Setter
@Getter
public class Otp {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotBlank(message = "OTP cannot be null")
    @Column(nullable = false, name = "otp")
    private String otp;

    @NotNull(message = "Expiration time cannot be null")
    @Column(nullable = false, name = "expiration_time")
    private Long expirationTime;

    @ValidPhoneNumber
    @Column(name = "phone_number", nullable = false, unique = true)
    private String phoneNumber;

    @Column(name = "failed_attempts", nullable = false)
    private int failedAttempts = 0;

    @Column(name = "resend_count", nullable = false)
    private int resendCount = 0;

    @Column(name = "locked_until")
    private Long lockedUntil;
}