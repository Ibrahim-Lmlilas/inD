package com.srrfrr.api.dto.auth;

import com.srrfrr.api.annotations.ValidPhoneNumber;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LoginRequest {

    @ValidPhoneNumber
    private String phoneNumber;

    @NotBlank(message = "Password cannot be null")
    private String password;

    @NotNull(message = "Firebase Token cannot be null")
    private String fcmToken;

    @NotNull(message = "Device ID is required")
    private String deviceId;
}
