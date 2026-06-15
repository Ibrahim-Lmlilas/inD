package com.srrfrr.api.dto.auth;

import com.srrfrr.api.annotations.ValidFirstName;
import com.srrfrr.api.annotations.ValidLastName;
import com.srrfrr.api.annotations.ValidPassword;
import com.srrfrr.api.annotations.ValidPhoneNumber;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.enums.user.Language;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

@Getter
@Setter
public class CreatePassengerRequest {

    @ValidFirstName
    private String firstName;

    @ValidLastName
    private String lastName;

    @ValidPhoneNumber
    private String phoneNumber;

    @ValidPassword
    private String password;

    @NotBlank(message = "Otp Code is required")
    private String otpCode;

    @NotNull(message = "Gender is required")
    private String gender;

    @NotNull(message = "Interface type is required")
    private InterfaceType interfaceType;

    @NotNull(message = "Language is required")
    private Language language;

    private MultipartFile profilePicture;

    @NotBlank(message = "Firebase Token cannot be null")
    private String fcmToken;

    @NotBlank(message = "Device ID cannot be null")
    private String deviceId;

    @AssertTrue(message = "You must accept the terms and conditions")
    @NotNull(message = "Terms Accepted is required")
    private boolean termsAccepted;
}