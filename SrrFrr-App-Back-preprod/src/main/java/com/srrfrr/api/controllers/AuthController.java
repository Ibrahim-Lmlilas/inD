package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.*;
import com.srrfrr.api.dto.auth.AuthResponse;
import com.srrfrr.api.dto.auth.CreateDriverRequest;
import com.srrfrr.api.dto.auth.CreatePassengerRequest;
import com.srrfrr.api.dto.auth.LoginRequest;
import com.srrfrr.api.dto.auth.ResetPasswordRequest;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.auth.AuthService;

import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;


@Slf4j
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(final AuthService authService) {
        this.authService = authService;}

    @PreAuthorize("permitAll()")
    @PostMapping(value = "/passenger/create", consumes = {"multipart/form-data"})
    public ResponseEntity<AuthResponse> createPassenger(@Valid @ModelAttribute final CreatePassengerRequest request) throws IOException {
        log.info("Creating passenger with request: {}", request);
        final AuthResponse response = authService.createPassenger(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping(value = "/driver/create", consumes = {"multipart/form-data"})
    public ResponseEntity<AuthResponse> createDriver(@AuthenticationPrincipal final Passenger passenger,
                                                    @Valid @ModelAttribute final CreateDriverRequest request) throws IOException {
        log.info("Creating driver with request: {}", request);
        final AuthResponse response = authService.createDriver(passenger,request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PreAuthorize("permitAll()")
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> loginPassenger(@Valid @RequestBody final LoginRequest request) {
        final AuthResponse response = authService.loginPassenger(request);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("permitAll()")
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody final Map<String, String> body) {
        final String refreshToken = body.get("refreshToken");
        final AuthResponse response = authService.refresh(refreshToken);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/logout")
    public ResponseEntity<SuccessResponse> logout(@AuthenticationPrincipal final Passenger passenger,
                                         @Valid @RequestBody final Map<String, String> body) {
        final String password = body.get("password");
        authService.logout(passenger, password);
        SuccessResponse response = new SuccessResponse(
                "Successfully logged out",
                HttpStatus.OK.value()
        );
        return ResponseEntity.ok(response);
    }


    @PreAuthorize("permitAll()")
    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> verifyOtpAndResetPassword(
            @Valid @RequestBody final ResetPasswordRequest request) {

        final Map<String, Object> response = new HashMap<>();

        try {
            authService.verifyOtpAndResetPassword(request);
            response.put("message", "Password reset successfully");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }


}