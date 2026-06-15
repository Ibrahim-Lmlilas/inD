package com.srrfrr.api.exceptions.subscription;

import com.srrfrr.api.dto.exception.ErrorResponse;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Exception handler for subscription-related exceptions.
 * Handles exceptions from the subscription package with appropriate HTTP status codes.
 */
@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(6)
public class SubscriptionExceptionHandler {

    // ==================== Not Found Exceptions (404) ====================

    @ExceptionHandler(SubscriptionNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleSubscriptionNotFound(final SubscriptionNotFoundException ex) {
        log.warn("Subscription not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(ActiveSubscriptionNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleActiveSubscriptionNotFound(final ActiveSubscriptionNotFoundException ex) {
        log.warn("Active subscription not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(SubscriptionPlanNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleSubscriptionPlanNotFound(final SubscriptionPlanNotFoundException ex) {
        log.warn("Subscription plan not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    // ==================== Conflict Exceptions (409) ====================

    @ExceptionHandler(ActiveSubscriptionAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleActiveSubscriptionAlreadyExists(final ActiveSubscriptionAlreadyExistsException ex) {
        log.warn("Active subscription already exists: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.CONFLICT));
    }

    @ExceptionHandler(SameSubscriptionPlanException.class)
    public ResponseEntity<ErrorResponse> handleSameSubscriptionPlan(final SameSubscriptionPlanException ex) {
        log.warn("Same subscription plan: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.CONFLICT));
    }

    // ==================== Bad Request Exceptions (400) ====================

    @ExceptionHandler(InsufficientWalletBalanceException.class)
    public ResponseEntity<ErrorResponse> handleInsufficientWalletBalance(final InsufficientWalletBalanceException ex) {
        log.warn("Insufficient wallet balance: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(DriverProfileRequiredException.class)
    public ResponseEntity<ErrorResponse> handleDriverProfileRequired(final DriverProfileRequiredException ex) {
        log.warn("Driver profile required: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== Payment Processing Exception (500) ====================

    @ExceptionHandler(SubscriptionPaymentException.class)
    public ResponseEntity<ErrorResponse> handleSubscriptionPayment(final SubscriptionPaymentException ex) {
        log.error("Subscription payment failed: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("Payment processing failed. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }

    // ==================== Generic Subscription Exception (500) ====================

    @ExceptionHandler(SubscriptionException.class)
    public ResponseEntity<ErrorResponse> handleSubscriptionException(final SubscriptionException ex) {
        log.error("Subscription exception: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("A subscription error occurred. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }
}