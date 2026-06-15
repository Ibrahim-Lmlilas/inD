package com.srrfrr.api.exceptions.chat;

/**
 * Thrown when message validation fails.
 */
public class InvalidMessageException extends ChatException {
    public InvalidMessageException(String message) {
        super(message);
    }
}
