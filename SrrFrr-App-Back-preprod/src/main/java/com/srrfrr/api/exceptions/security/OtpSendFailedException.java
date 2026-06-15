package com.srrfrr.api.exceptions.security;

public class OtpSendFailedException extends SecurityException {
    public OtpSendFailedException(String phoneNumber) {
        super(String.format("Failed to send OTP to phone number: %s", phoneNumber));
    }
}
