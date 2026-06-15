package com.srrfrr.api.exceptions.user;

/**
 * Thrown when user profile operations fail.
 */
public class ProfileOperationException extends UserException {
    public ProfileOperationException(String message) {
        super(message);
    }
    
    public ProfileOperationException(String message, Throwable cause) {
        super(message, cause);
    }
}
