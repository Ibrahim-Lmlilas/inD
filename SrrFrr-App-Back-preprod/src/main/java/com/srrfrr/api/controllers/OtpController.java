package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.services.otp.OtpService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/otp")
public class OtpController {

    @Value("${whatsapp.webhook.verify-token:verification_token_here}")
    private String verifyToken;

    private final OtpService otpService;

    public OtpController(OtpService otpService) {
        this.otpService = otpService;
    }

    @PreAuthorize("permitAll()")
    @PostMapping("/send")
    public ResponseEntity<Map<String, String>> sendOtp(
            @Valid @RequestBody OtpRequest request,
            @RequestParam(value = "requireExisting", required = false, defaultValue = "false") boolean requireExisting) {

        otpService.sendOtp(request, requireExisting);

        Map<String, String> response = new HashMap<>();
        response.put("message", "OTP sent successfully");
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("permitAll()")
    @PostMapping("/validate")
    public ResponseEntity<Map<String, String>> validateOtp(@Valid @RequestBody OtpRequest request) {
        boolean valid = otpService.isOtpValid(request.getPhoneNumber(), request.getOtp());

        Map<String, String> response = new HashMap<>();

        if (valid) {
            response.put("message", "OTP is valid");
            return ResponseEntity.ok(response);
        } else {
            response.put("message", "OTP is invalid or expired");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PreAuthorize("permitAll()")
    @GetMapping("/webhook")
    public ResponseEntity<?> verifyWebhook(
            @RequestParam("hub.mode") String mode,
            @RequestParam("hub.verify_token") String token,
            @RequestParam("hub.challenge") String challenge) {

        if ("subscribe".equals(mode) && verifyToken.equals(token)) {
            log.info("Webhook verified successfully");
            return ResponseEntity.ok(challenge);
        } else {
            log.warn("Webhook verification failed - invalid token");
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }
}