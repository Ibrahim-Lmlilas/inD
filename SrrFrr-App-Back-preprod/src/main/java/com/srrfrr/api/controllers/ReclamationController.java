package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.ReclamationRequest;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.reclamation.ReclamationService;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/reclamations")
public class ReclamationController {

    private final ReclamationService reclamationService;

    public ReclamationController(final ReclamationService reclamationService) {
        this.reclamationService = reclamationService;
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping
    public ResponseEntity<Map<String, String>> createReclamation(
            @Valid @RequestBody final ReclamationRequest request,
            @AuthenticationPrincipal final Passenger passenger
    ) {
        reclamationService.createReclamation(request, passenger);

        final Map<String, String> response = new HashMap<>();
        response.put("message", "Reclamation created successfully.");
        return ResponseEntity.ok(response);
    }
}