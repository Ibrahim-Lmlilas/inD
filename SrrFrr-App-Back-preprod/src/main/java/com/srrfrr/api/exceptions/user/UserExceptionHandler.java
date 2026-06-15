package com.srrfrr.api.exceptions.user;

import com.srrfrr.api.dto.exception.ErrorResponse;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Exception handler for user-related exceptions.
 * Handles exceptions from the user package with appropriate HTTP status codes.
 */
@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(3)
public class UserExceptionHandler {

    // ==================== User Not Found Exceptions (404) ====================

    @ExceptionHandler(PassengerNotFoundException.class)
    public ResponseEntity<ErrorResponse> handlePassengerNotFound(final PassengerNotFoundException ex) {
        log.warn("Passenger not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(DriverProfileNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleDriverProfileNotFound(final DriverProfileNotFoundException ex) {
        log.warn("Driver profile not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(final UserNotFoundException ex) {
        log.warn("User not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    // ==================== File Upload Exceptions (400) ====================

    @ExceptionHandler(InvalidFileException.class)
    public ResponseEntity<ErrorResponse> handleInvalidFile(final InvalidFileException ex) {
        log.warn("Invalid file: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(FileSizeExceededException.class)
    public ResponseEntity<ErrorResponse> handleFileSizeExceeded(final FileSizeExceededException ex) {
        log.warn("File size exceeded: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(InvalidFileTypeException.class)
    public ResponseEntity<ErrorResponse> handleInvalidFileType(final InvalidFileTypeException ex) {
        log.warn("Invalid file type: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== File Upload Failures (500) ====================

    @ExceptionHandler(FileUploadException.class)
    public ResponseEntity<ErrorResponse> handleFileUploadException(final FileUploadException ex) {
        log.error("File upload failed: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("Failed to upload file. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }

    // ==================== Interface Type Exceptions (400) ====================

    @ExceptionHandler(LadiesInterfaceNotAllowedException.class)
    public ResponseEntity<ErrorResponse> handleLadiesInterfaceNotAllowed(final LadiesInterfaceNotAllowedException ex) {
        log.warn("Ladies interface not allowed: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(InvalidInterfaceTypeException.class)
    public ResponseEntity<ErrorResponse> handleInvalidInterfaceType(final InvalidInterfaceTypeException ex) {
        log.warn("Invalid interface type: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== Profile Operation Exceptions (500) ====================

    @ExceptionHandler(ProfileOperationException.class)
    public ResponseEntity<ErrorResponse> handleProfileOperationException(final ProfileOperationException ex) {
        log.error("Profile operation failed: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("Profile operation failed. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }

    // ==================== Delete Account Exceptions (500) ====================

    @ExceptionHandler(DeleteAccountException.class)
    public ResponseEntity<ErrorResponse> handleDeleteAccountException(final UserNotFoundException ex) {
        log.warn("Failed to delete account: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    // ==================== Passenger Creation Exception (400) ====================

    @ExceptionHandler(PassengerCreationException.class)
    public ResponseEntity<ErrorResponse> handlePassengerCreation(final PassengerCreationException ex) {
        log.error("Passenger creation failed: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    // ==================== Generic User Exception (500) ====================

    @ExceptionHandler(UserException.class)
    public ResponseEntity<ErrorResponse> handleUserException(final UserException ex) {
        log.error("User exception: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("An unexpected error occurred. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }
}