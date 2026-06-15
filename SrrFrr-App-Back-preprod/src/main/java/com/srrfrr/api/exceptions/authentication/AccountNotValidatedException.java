package com.srrfrr.api.exceptions.authentication;

import org.springframework.security.access.AccessDeniedException;

public class AccountNotValidatedException extends AccessDeniedException {
    public AccountNotValidatedException() {
        super("Your account must be validated to access this resource.");
    }
}