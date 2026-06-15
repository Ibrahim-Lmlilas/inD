package com.srrfrr.api.exceptions.user;

/**
 * Thrown when file upload operations fail.
 */
public class FileUploadException extends UserException {
    public FileUploadException(String message) {
        super(message);
    }
    
    public FileUploadException(String message, Throwable cause) {
        super(message, cause);
    }
}
