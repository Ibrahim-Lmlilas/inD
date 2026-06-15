package com.srrfrr.api.exceptions.authentication;


public class InvalidPasswordException extends RuntimeException {
    public InvalidPasswordException(final String message) {
        super(message);
    }
}
