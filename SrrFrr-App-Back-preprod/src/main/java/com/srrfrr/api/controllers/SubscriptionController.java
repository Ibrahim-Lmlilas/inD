package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.ApiResponse;
import com.srrfrr.api.dto.subscription.*;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.SubscriptionPlan;
import com.srrfrr.api.services.subscription.SubscriptionService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * Controller for subscription operations.
 * Handles driver subscriptions, plan management, and subscription history.
 */
@Slf4j
@RestController
@RequestMapping("/subscriptions")
public class SubscriptionController {
    private final SubscriptionService subscriptionService;

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;

    public SubscriptionController(final SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /**
     * Subscribe or resubscribe driver to a plan.
     * Handles both new subscriptions and resubscriptions after cancellation.
     * Validates driver profile and processes wallet payment.
     * 
     * @param passenger authenticated user
     * @param request subscription request with plan type
     * @return subscription response
     */
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/subscribe")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> subscribeDriver(
            @AuthenticationPrincipal final Passenger passenger,
            @Valid @RequestBody final SubscribeDriverRequest request) {

        final SubscriptionResponse response = subscriptionService.subscribeDriver(passenger, request);
        
        log.info("Driver {} subscribed to {} plan", 
            passenger.getDriverProfile().getId(), request.getPlanType());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Get driver's active subscription.
     * 
     * @param passenger authenticated user
     * @return active subscription details or null if no active subscription
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> getActiveSubscription(
            @AuthenticationPrincipal final Passenger passenger) {

        final SubscriptionResponse response = subscriptionService.getActiveSubscription(
            passenger.getDriverProfile().getId()
        );

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Get paginated subscription history for driver.
     * Returns subscriptions in reverse chronological order (newest first).
     * 
     * @param passenger authenticated user
     * @param page page number (0-indexed, default: 0)
     * @param size page size (default: 20, max: 100)
     * @return paginated subscription history
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<Page<SubscriptionResponse>>> getSubscriptionHistory(
            @AuthenticationPrincipal final Passenger passenger,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size) {

        // Validate and limit page size
        final int validatedSize = Math.min(size, MAX_PAGE_SIZE);
        
        // Create pageable with descending order (newest first)
        final Pageable pageable = PageRequest.of(
            page, 
            validatedSize, 
            Sort.by(Sort.Direction.DESC, "createdAt")
        );

        final Page<SubscriptionResponse> history = subscriptionService.getSubscriptionHistory(
            passenger.getId(), 
            pageable
        );

        log.info("Retrieved page {} of subscription history for driver {} (size: {})", 
            page, passenger.getDriverProfile().getId(), validatedSize);

        return ResponseEntity.ok(ApiResponse.success(history));
    }

    /**
     * Change driver's subscription plan.
     * Cancels current subscription and creates new one with immediate effect.
     * 
     * @param passenger authenticated user
     * @param request new subscription plan request
     * @return new subscription response
     */
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/change")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> changeSubscription(
            @AuthenticationPrincipal final Passenger passenger,
            @Valid @RequestBody final SubscribeDriverRequest request) {

        final SubscriptionResponse response = subscriptionService.changeSubscription(
            passenger, 
            request
        );
        
        log.info("Driver {} changed subscription to {} plan", 
            passenger.getDriverProfile().getId(), request.getPlanType());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Stop/cancel driver's active subscription.
     * Subscription is stopped immediately and set to CANCELLED status.
     * 
     * @param passenger authenticated user
     * @return cancellation confirmation
     */
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/stop")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> stopSubscription(
            @AuthenticationPrincipal final Passenger passenger) {

        final SubscriptionResponse response = subscriptionService.stopSubscription(passenger);
        
        log.info("Driver {} stopped subscription", passenger.getDriverProfile().getId());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Get all available subscription plans with promotional eligibility.
     * Includes multi-language promo messages for first-time subscribers.
     * 
     * @param passenger authenticated user
     * @return list of plans with promo eligibility info
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/plans")
    public ResponseEntity<ApiResponse<PlansWithPromoResponse>> getPlans(
            @AuthenticationPrincipal final Passenger passenger) {
        
        final PlansWithPromoResponse response = subscriptionService.getPlansWithPromo(passenger);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}