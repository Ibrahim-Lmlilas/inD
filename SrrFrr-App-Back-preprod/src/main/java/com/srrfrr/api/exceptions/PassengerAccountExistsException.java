package com.srrfrr.api.exceptions;


public class PassengerAccountExistsException extends RuntimeException {

    @Override
    public String getMessage() {
        return "This Passenger already have account.";
    }
}