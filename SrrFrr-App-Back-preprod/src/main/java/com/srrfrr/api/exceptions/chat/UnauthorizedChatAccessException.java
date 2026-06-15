package com.srrfrr.api.exceptions.chat;

import java.util.UUID;

/**
 * Thrown when user tries to access a chat they're not authorized for.
 */
public class UnauthorizedChatAccessException extends ChatException {
    public UnauthorizedChatAccessException(String message) {
        super(message);
    }

    public UnauthorizedChatAccessException(UUID userId, UUID channelId) {
        super(String.format("User %s is not authorized to access chat channel %s", userId, channelId));
    }
}
