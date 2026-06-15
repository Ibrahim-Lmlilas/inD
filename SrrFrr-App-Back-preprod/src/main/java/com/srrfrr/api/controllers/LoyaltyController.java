package com.srrfrr.api.controllers;

import com.srrfrr.api.entities.main.LoyaltyReward;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.loyalty.LoyaltyService;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/loyalty")
public class LoyaltyController {
    private final LoyaltyService loyaltyService;
    
    public LoyaltyController(final LoyaltyService loyaltyService) {
        this.loyaltyService = loyaltyService;
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping
    public ResponseEntity<Map<String, Object>> getLoyaltyInfo(
            @AuthenticationPrincipal Passenger passenger,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Map<String, Object> response = loyaltyService.getLoyaltyInfo(passenger.getId(), pageable);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/rewards")
    public ResponseEntity<List<LoyaltyReward>> getAllRewards() {
        return ResponseEntity.ok(loyaltyService.getAllRewards());
    }
}