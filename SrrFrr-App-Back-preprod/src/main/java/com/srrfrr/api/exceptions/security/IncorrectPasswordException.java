package com.srrfrr.api.exceptions.security;

public class IncorrectPasswordException extends SecurityException {
    public IncorrectPasswordException() {
        super("Current password is incorrect");
    }
}
