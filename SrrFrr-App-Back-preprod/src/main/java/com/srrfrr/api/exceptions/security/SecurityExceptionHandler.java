package com.srrfrr.api.exceptions.security;

import com.srrfrr.api.dto.exception.ErrorResponse;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Exception handler for security-related exceptions.
 * Handles password, phone number, and OTP exceptions with appropriate HTTP status codes.
 */
@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(4)
public class SecurityExceptionHandler {

    // ==================== Password Exceptions (400) ====================

    @ExceptionHandler(PasswordMismatchException.class)
    public ResponseEntity<ErrorResponse> handlePasswordMismatch(final PasswordMismatchException ex) {
        log.warn("Password mismatch: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(IncorrectPasswordException.class)
    public ResponseEntity<ErrorResponse> handleIncorrectPassword(final IncorrectPasswordException ex) {
        log.warn("Incorrect password: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(SamePasswordException.class)
    public ResponseEntity<ErrorResponse> handleSamePassword(final SamePasswordException ex) {
        log.warn("Same password: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(PasswordUpdateException.class)
    public ResponseEntity<ErrorResponse> handlePasswordUpdate(final PasswordUpdateException ex) {
        log.warn("Password update failed: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(PasswordException.class)
    public ResponseEntity<ErrorResponse> handlePasswordException(final PasswordException ex) {
        log.warn("Password exception: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== Phone Number Exceptions (400) ====================

    @ExceptionHandler(InvalidPhoneNumberFormatException.class)
    public ResponseEntity<ErrorResponse> handleInvalidPhoneNumberFormat(final InvalidPhoneNumberFormatException ex) {
        log.warn("Invalid phone number format: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(SamePhoneNumberException.class)
    public ResponseEntity<ErrorResponse> handleSamePhoneNumber(final SamePhoneNumberException ex) {
        log.warn("Same phone number: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(PhoneNumberAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handlePhoneNumberAlreadyExists(final PhoneNumberAlreadyExistsException ex) {
        log.warn("Phone number already exists: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(PhoneNumberException.class)
    public ResponseEntity<ErrorResponse> handlePhoneNumberException(final PhoneNumberException ex) {
        log.warn("Phone number exception: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== OTP Exceptions ====================

    @ExceptionHandler(InvalidOtpException.class)
    public ResponseEntity<ErrorResponse> handleInvalidOtp(final InvalidOtpException ex) {
        log.warn("Invalid OTP: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.UNAUTHORIZED));
    }

    @ExceptionHandler(OtpSendFailedException.class)
    public ResponseEntity<ErrorResponse> handleOtpSendFailed(final OtpSendFailedException ex) {
        log.error("OTP send failed: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(new ErrorResponse("Failed to send OTP. Please try again later.", HttpStatus.SERVICE_UNAVAILABLE));
    }

    @ExceptionHandler(OtpVerificationException.class)
    public ResponseEntity<ErrorResponse> handleOtpVerification(final OtpVerificationException ex) {
        log.warn("OTP verification failed: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.UNAUTHORIZED));
    }

    // ==================== Generic Security Exception (500) ====================

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<ErrorResponse> handleSecurityException(final SecurityException ex) {
        log.error("Security exception: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("A security error occurred. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }
}
