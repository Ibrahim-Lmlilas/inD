package com.srrfrr.api.exceptions.chat;

/**
 * Base exception for all chat-related errors.
 */
public abstract class ChatException extends RuntimeException {
    protected ChatException(String message) {
        super(message);
    }

    protected ChatException(String message, Throwable cause) {
        super(message, cause);
    }
}
