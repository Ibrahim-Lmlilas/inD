package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.ApiResponse;
import com.srrfrr.api.dto.notification.NotificationResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.notification.NotificationService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Controller for notification operations.
 * Handles notification retrieval and status updates.
 */
@RestController
@RequestMapping("/notifications")
public class NotificationController {
    private final NotificationService notificationService;

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;

    public NotificationController(final NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    /**
     * Get paginated notifications for passenger.
     * Returns notifications from the last 24 hours in reverse chronological order.
     * 
     * @param passenger authenticated user
     * @param page page number (0-indexed, default: 0)
     * @param size page size (default: 20, max: 100)
     * @return paginated notifications
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/passenger")
    public ResponseEntity<ApiResponse<Page<NotificationResponse>>> getPassengerNotifications(
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

        final Page<NotificationResponse> notifications = notificationService.getNotificationsForPassenger(
            passenger.getId(), 
            pageable
        );
        
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Get paginated notifications for driver.
     * Returns notifications from the last 24 hours in reverse chronological order.
     * 
     * @param passenger authenticated user (must have driver profile)
     * @param page page number (0-indexed, default: 0)
     * @param size page size (default: 20, max: 100)
     * @return paginated notifications
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/driver")
    public ResponseEntity<ApiResponse<Page<NotificationResponse>>> getDriverNotifications(
            @AuthenticationPrincipal final Passenger passenger,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size) {

        if (passenger.getDriverProfile() == null) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.errorWithType("Driver profile required to view driver notifications"));
        }

        // Validate and limit page size
        final int validatedSize = Math.min(size, MAX_PAGE_SIZE);
        
        // Create pageable with descending order (newest first)
        final Pageable pageable = PageRequest.of(
            page, 
            validatedSize, 
            Sort.by(Sort.Direction.DESC, "createdAt")
        );

        final UUID driverId = passenger.getDriverProfile().getId();
        final Page<NotificationResponse> notifications = notificationService.getNotificationsForDriver(
            driverId, 
            pageable
        );
        
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Mark a specific notification as read.
     * User must be the receiver of the notification.
     * 
     * @param id notification ID
     * @param passenger authenticated user
     * @return updated notification
     */
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/read/{id}")
    public ResponseEntity<ApiResponse<NotificationResponse>> markNotificationAsRead(
            @PathVariable final UUID id,
            @AuthenticationPrincipal final Passenger passenger) {

        final NotificationResponse response = notificationService.markAsRead(id, passenger.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Mark all notifications as read for the authenticated user.
     * 
     * @param passenger authenticated user
     * @return success response
     */
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
            @AuthenticationPrincipal final Passenger passenger) {
        
        notificationService.markAllAsRead(passenger.getId());
        return ResponseEntity.ok(ApiResponse.success("All notifications marked as read", null));
    }
}