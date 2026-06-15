package com.srrfrr.api.exceptions.security;

public class OtpVerificationException extends SecurityException {
    public OtpVerificationException(String message) {
        super(message);
    }
}
