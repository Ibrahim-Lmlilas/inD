package com.srrfrr.api.exceptions.chat;

import java.util.UUID;

/**
 * Thrown when a chat message is not found.
 */
public class ChatMessageNotFoundException extends ChatException {
    public ChatMessageNotFoundException(String message) {
        super(message);
    }

    public ChatMessageNotFoundException(UUID messageId) {
        super(String.format("Chat message not found with ID: %s", messageId));
    }
}
