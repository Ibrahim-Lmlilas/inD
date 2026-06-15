package com.srrfrr.api.exceptions.security;

public class PhoneNumberAlreadyExistsException extends SecurityException {
    public PhoneNumberAlreadyExistsException(String phoneNumber) {
        super(String.format("Phone number %s is already registered to another user", phoneNumber));
    }
}
