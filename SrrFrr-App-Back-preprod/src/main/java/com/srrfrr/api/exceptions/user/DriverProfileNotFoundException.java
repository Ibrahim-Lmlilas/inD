package com.srrfrr.api.exceptions.user;

/**
 * Thrown when a driver profile is not found.
 */
public class DriverProfileNotFoundException extends UserException {
    public DriverProfileNotFoundException(String message) {
        super(message);
    }
    
    public DriverProfileNotFoundException(String passengerId, boolean byPassengerId) {
        super(String.format("Driver profile not found for passenger ID: %s", passengerId));
    }
}