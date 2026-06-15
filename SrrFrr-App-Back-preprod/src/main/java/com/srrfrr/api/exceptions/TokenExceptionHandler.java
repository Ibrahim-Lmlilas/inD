package com.srrfrr.api.exceptions;

import com.srrfrr.api.exceptions.authentication.AlreadyAuthenticatedException;
import com.srrfrr.api.exceptions.authentication.InvalidTokenException;
import com.srrfrr.api.exceptions.authentication.TokenExpiredException;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(3)
public class TokenExceptionHandler {

    @ExceptionHandler(TokenExpiredException.class)
    public ResponseEntity<ErrorDetails> handleTokenExpired(final TokenExpiredException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                new ErrorDetails("TOKEN_EXPIRED", "Access token has expired", null)
        );
    }

    @ExceptionHandler(InvalidTokenException.class)
    public ResponseEntity<ErrorDetails> handleInvalidToken(final InvalidTokenException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                new ErrorDetails("INVALID_TOKEN", "Invalid or malformed token", null)
        );
    }

    @ExceptionHandler(AlreadyAuthenticatedException.class)
    public ResponseEntity<ErrorDetails> handleAlreadyAuthenticated(final AlreadyAuthenticatedException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(
                new ErrorDetails("ALREADY_AUTHENTICATED", ex.getMessage(), null)
        );
    }

    @ExceptionHandler(AuthenticationCredentialsNotFoundException.class)
    public ResponseEntity<ErrorDetails> handleAuthenticationCredentialsNotFound(
            final AuthenticationCredentialsNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                new ErrorDetails(
                        "AUTHENTICATION_REQUIRED",
                        "Authentication is required: credentials are missing or session has expired.",
                        null
                )
        );
    }

}
