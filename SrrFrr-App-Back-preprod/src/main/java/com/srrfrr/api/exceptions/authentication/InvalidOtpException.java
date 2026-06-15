package com.srrfrr.api.exceptions.authentication;

public class InvalidOtpException extends RuntimeException {
    public InvalidOtpException(final String message) {
        super(message);
    }
}

