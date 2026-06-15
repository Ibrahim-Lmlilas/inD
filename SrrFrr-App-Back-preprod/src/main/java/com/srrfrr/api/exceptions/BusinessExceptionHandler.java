package com.srrfrr.api.exceptions;

import com.srrfrr.api.dto.exception.ErrorResponse;
import com.srrfrr.api.exceptions.user.PassengerCreationException;

import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(4)
public class BusinessExceptionHandler {

    @ExceptionHandler(PassengerCreationException.class)
    public ResponseEntity<ErrorResponse> handlePassengerCreationException(final PassengerCreationException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(final IllegalArgumentException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }
}
