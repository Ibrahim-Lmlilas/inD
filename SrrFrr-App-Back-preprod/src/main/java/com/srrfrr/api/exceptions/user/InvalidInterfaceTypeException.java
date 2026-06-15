package com.srrfrr.api.exceptions.user;

/**
 * Thrown when interface type change is invalid.
 */
public class InvalidInterfaceTypeException extends UserException {
    public InvalidInterfaceTypeException(String message) {
        super(message);
    }
}

