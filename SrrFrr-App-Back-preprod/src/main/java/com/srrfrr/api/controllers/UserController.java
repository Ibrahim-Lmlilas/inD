package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.ApiResponse;
import com.srrfrr.api.dto.PassengerResponse;
import com.srrfrr.api.dto.driver.DriverResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.enums.user.Language;
import com.srrfrr.api.exceptions.user.DeleteAccountException;
import com.srrfrr.api.exceptions.user.DriverProfileNotFoundException;
import com.srrfrr.api.services.user.DriverService;
import com.srrfrr.api.services.user.PassengerService;
import com.srrfrr.api.services.user.UserProfileService;

import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.dto.user.DeleteAccountRequest;
import com.srrfrr.api.dto.user.DeleteAccountResponse;
import com.srrfrr.api.dto.user.UpdatePasswordRequest;
import com.srrfrr.api.dto.user.UpdatePhoneNumberRequest;
import com.srrfrr.api.dto.user.UpdatePhoneNumberResponse;

@RestController
@RequestMapping("/user")
@Slf4j
public class UserController {
    private final UserProfileService userProfileService;
    private final PassengerService passengerService;
    private final DriverService driverService;

    public UserController(final UserProfileService userProfileService,
            final PassengerService passengerService,
            final DriverService driverService) {
        this.userProfileService = userProfileService;
        this.passengerService = passengerService;
        this.driverService = driverService;
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/profile/passenger")
    public ResponseEntity<ApiResponse<PassengerResponse>> getPassengerProfile(
            @AuthenticationPrincipal Passenger passenger) {

        PassengerResponse response = passengerService.getPassenger(passenger.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/profile/driver")
    public ResponseEntity<ApiResponse<DriverResponse>> getDriverProfile(
            @AuthenticationPrincipal Passenger passenger) {

        // Let the service handle the null check
        DriverResponse response = driverService.getDriver(passenger.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PreAuthorize("isAuthenticated()")
    @PutMapping("/update/picture")
    public ResponseEntity<ApiResponse<Map<String, String>>> updateProfilePicture(
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal Passenger passenger) {

        String url = userProfileService.updateProfilePicture(passenger.getId(), file);
        return ResponseEntity.ok(ApiResponse.success(Map.of("profilePictureUrl", url)));
    }

    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/delete/picture")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteProfilePicture(
            @AuthenticationPrincipal Passenger passenger) {

        userProfileService.deleteProfilePicture(passenger.getId());
        return ResponseEntity.ok(ApiResponse.success(Map.of("message", "Profile picture deleted successfully")));
    }

    @PreAuthorize("isAuthenticated()")
    @PutMapping("/update/password")
    public ResponseEntity<ApiResponse<Void>> updatePassword(
            @AuthenticationPrincipal Passenger passenger,
            @Valid @RequestBody UpdatePasswordRequest request) {

        passengerService.updatePassword(
                passenger,
                request.getCurrentPassword(),
                request.getNewPassword(),
                request.getConfirmNewPassword());

        return ResponseEntity.ok(ApiResponse.success("Password updated successfully", null));
    }

    @PreAuthorize("isAuthenticated()")
    @PatchMapping("/update/interface-type")
    public ResponseEntity<ApiResponse<Void>> updateInterfaceType(
            @RequestParam InterfaceType interfaceType,
            @AuthenticationPrincipal Passenger passenger) {

        userProfileService.updateInterfaceType(passenger, interfaceType);
        return ResponseEntity.ok(ApiResponse.success("Interface type updated", null));
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/update/phone")
    public ResponseEntity<ApiResponse<UpdatePhoneNumberResponse>> requestPhoneUpdate(
            @AuthenticationPrincipal Passenger passenger,
            @Valid @RequestBody UpdatePhoneNumberRequest request) {

        UpdatePhoneNumberResponse response = passengerService.sendOtpForPhoneNumberUpdate(
                passenger,
                request.getPhoneNumber(),
                request.getPassword());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/update/phone/confirm")
    public ResponseEntity<ApiResponse<UpdatePhoneNumberResponse>> confirmPhoneUpdate(
            @AuthenticationPrincipal Passenger passenger,
            @Valid @RequestBody OtpRequest request) {

        UpdatePhoneNumberResponse response = passengerService.confirmPhoneNumberUpdateWithOtp(
                passenger,
                request.getPhoneNumber(),
                request.getOtp());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PreAuthorize("isAuthenticated")
    @PostMapping("/delete")
    public ResponseEntity<ApiResponse<DeleteAccountResponse>> deleteUserProfile(
            @AuthenticationPrincipal Passenger passenger,
            @Valid @RequestBody DeleteAccountRequest request) {
        if (!request.isConfirmed()) {
            throw new DeleteAccountException(passenger.getId().toString(), request.isConfirmed());
        }

        log.info("request received : " + request);
        userProfileService.deleteUserAccount(
                passenger.getId(),
                request.getPassword());

        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PreAuthorize("isAuthenticated()")
    @PatchMapping("/update/language")
    public ResponseEntity<ApiResponse<Void>> updateLanguage(
            @RequestParam Language language,
            @AuthenticationPrincipal Passenger passenger) {

        userProfileService.updateLanguage(passenger, language);
        return ResponseEntity.ok(ApiResponse.success("Language updated successfully", null));
    }
}