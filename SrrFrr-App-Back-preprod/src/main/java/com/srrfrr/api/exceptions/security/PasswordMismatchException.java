package com.srrfrr.api.exceptions.security;

public class PasswordMismatchException extends SecurityException {
    public PasswordMismatchException() {
        super("New password and confirmation password do not match");
    }
}
