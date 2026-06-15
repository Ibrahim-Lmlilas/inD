package com.srrfrr.api.exceptions.security;

public abstract class SecurityException extends RuntimeException {
    protected SecurityException(String message) {
        super(message);
    }

    protected SecurityException(String message, Throwable cause) {
        super(message, cause);
    }
}