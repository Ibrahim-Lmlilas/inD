package com.srrfrr.api.exceptions.security;

public class InvalidOtpException extends SecurityException {
    public InvalidOtpException() {
        super("Invalid or expired OTP code");
    }
}
