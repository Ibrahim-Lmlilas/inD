package com.srrfrr.api.exceptions.user;

/**
 * Thrown when uploaded file validation fails.
 */
public class InvalidFileException extends UserException {
    public InvalidFileException(String message) {
        super(message);
    }
}