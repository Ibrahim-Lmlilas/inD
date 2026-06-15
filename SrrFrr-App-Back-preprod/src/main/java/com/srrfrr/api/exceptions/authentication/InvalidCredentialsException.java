package com.srrfrr.api.exceptions.authentication;

public class InvalidCredentialsException extends RuntimeException {
    public InvalidCredentialsException(final String message) {
        super(message);
    }
}