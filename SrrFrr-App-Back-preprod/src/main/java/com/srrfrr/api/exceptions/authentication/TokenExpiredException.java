package com.srrfrr.api.exceptions.authentication;

public class TokenExpiredException extends RuntimeException {
    public TokenExpiredException(final String message) {
        super(message);
    }

    public TokenExpiredException(final String message,final Throwable cause) {
        super(message, cause);
    }
}