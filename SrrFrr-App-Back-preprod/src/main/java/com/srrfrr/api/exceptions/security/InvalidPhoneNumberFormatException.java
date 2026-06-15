package com.srrfrr.api.exceptions.security;

public class InvalidPhoneNumberFormatException extends SecurityException {
    public InvalidPhoneNumberFormatException(String phoneNumber) {
        super(String.format("Invalid phone number format: %s", phoneNumber));
    }
}
