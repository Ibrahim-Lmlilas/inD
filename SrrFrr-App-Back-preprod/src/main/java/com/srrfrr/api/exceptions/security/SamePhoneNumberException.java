package com.srrfrr.api.exceptions.security;

public class SamePhoneNumberException extends SecurityException {
    public SamePhoneNumberException() {
        super("New phone number is the same as current phone number");
    }
}
