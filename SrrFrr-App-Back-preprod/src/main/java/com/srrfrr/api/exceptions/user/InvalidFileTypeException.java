package com.srrfrr.api.exceptions.user;

/**
 * Thrown when file type is not allowed.
 */
public class InvalidFileTypeException extends UserException {
    public InvalidFileTypeException(String fileType, String allowedTypes) {
        super(String.format("File type '%s' is not allowed. Allowed types: %s", fileType, allowedTypes));
    }
}
