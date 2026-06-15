package com.srrfrr.api.exceptions.security;

public class SamePasswordException extends SecurityException {
    public SamePasswordException() {
        super("New password must be different from current password");
    }
}
