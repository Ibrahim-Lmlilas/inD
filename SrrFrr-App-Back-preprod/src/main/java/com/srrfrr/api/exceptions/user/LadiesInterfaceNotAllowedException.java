package com.srrfrr.api.exceptions.user;

/**
 * Thrown when attempting to set LADIES interface for non-female users.
 */
public class LadiesInterfaceNotAllowedException extends UserException {
    public LadiesInterfaceNotAllowedException() {
        super("LADIES interface is only available for female users");
    }
}