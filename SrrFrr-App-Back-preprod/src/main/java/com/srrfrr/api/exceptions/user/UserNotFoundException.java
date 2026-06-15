package com.srrfrr.api.exceptions.user;

/**
 * Thrown when a requested user (passenger or driver) is not found.
 */
public class UserNotFoundException extends UserException {
    public UserNotFoundException(String message) {
        super(message);
    }
}