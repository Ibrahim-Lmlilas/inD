package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.SuccessResponse;
import com.srrfrr.api.dto.driver.DriverProfileEditRequestCreateRequest;
import com.srrfrr.api.dto.driver.DriverProfileEditRequestResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.profile.DriverProfileEditRequestService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/driver/profile-edit-requests")
public class DriverProfileEditRequestController {

    private final DriverProfileEditRequestService service;

    public DriverProfileEditRequestController(final DriverProfileEditRequestService service) {
        this.service = service;
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<SuccessResponse> createRequest(
            @Valid @ModelAttribute final DriverProfileEditRequestCreateRequest request,
            @AuthenticationPrincipal final Passenger passenger) {

        service.createRequest(passenger, request);
        return ResponseEntity.ok(new SuccessResponse("Profile edit request submitted successfully.", 200));
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping
    public ResponseEntity<List<DriverProfileEditRequestResponse>> listOwnRequests(
            @AuthenticationPrincipal final Passenger passenger) {

        return ResponseEntity.ok(service.listForDriver(passenger.getId()));
    }
}
