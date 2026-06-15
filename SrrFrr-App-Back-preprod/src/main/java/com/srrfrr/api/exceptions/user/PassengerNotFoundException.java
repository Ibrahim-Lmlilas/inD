package com.srrfrr.api.exceptions.user;

/**
 * Thrown when a passenger is not found by ID.
 */
public class PassengerNotFoundException extends UserException {
    public PassengerNotFoundException(String passengerId) {
        super(String.format("Passenger not found with ID: %s", passengerId));
    }
}
