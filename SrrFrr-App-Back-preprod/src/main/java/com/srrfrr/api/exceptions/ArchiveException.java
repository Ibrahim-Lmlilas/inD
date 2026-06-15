package com.srrfrr.api.exceptions;

/**
 * Custom exception for archive-related errors.
 * Thrown when archiving operations fail.
 */
public class ArchiveException extends RuntimeException {
    
    public ArchiveException(String message) {
        super(message);
    }
    
    public ArchiveException(String message, Throwable cause) {
        super(message, cause);
    }
}