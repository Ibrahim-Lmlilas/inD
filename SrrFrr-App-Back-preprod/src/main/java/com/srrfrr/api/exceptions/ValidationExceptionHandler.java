package com.srrfrr.api.exceptions;


import com.fasterxml.jackson.databind.exc.MismatchedInputException;
import com.srrfrr.api.exceptions.authentication.InvalidRequestException;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;
@Slf4j
@RestControllerAdvice
@Order(1)
@NoArgsConstructor
public class ValidationExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationErrors(final MethodArgumentNotValidException ex) {
        final Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, String>> handleHttpMessageNotReadable(final HttpMessageNotReadableException ex) {
        final Throwable cause = ex.getCause();

        if (cause instanceof MismatchedInputException) {
            return handleMismatchedInputException((MismatchedInputException) cause);
        }

        final Map<String, String> errors = new HashMap<>();
        errors.put("error", "Malformed JSON request or unreadable message content.");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }

    private ResponseEntity<Map<String, String>> handleMismatchedInputException(final MismatchedInputException ex) {
        final Map<String, String> error = new HashMap<>();
        error.put("code", "INVALID_INPUT");
        error.put("message", "Invalid input: some required fields cannot be null or have wrong format.");
        error.put("developerMessage", ex.getOriginalMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(InvalidRequestException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(final InvalidRequestException ex) {
        final Map<String, String> error = new HashMap<>();
        error.put("code", "BAD_REQUEST");
        error.put("message", ex.getMessage());
        error.put("developerMessage", ex.toString());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
}