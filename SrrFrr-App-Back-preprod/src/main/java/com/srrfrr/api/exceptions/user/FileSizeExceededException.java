package com.srrfrr.api.exceptions.user;

/**
 * Thrown when file size exceeds the maximum allowed limit.
 */
public class FileSizeExceededException extends UserException {
    public FileSizeExceededException(long fileSize, long maxSize) {
        super(String.format("File size %d bytes exceeds maximum limit of %d bytes", fileSize, maxSize));
    }
}
