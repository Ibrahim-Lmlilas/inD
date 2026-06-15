package com.srrfrr.api.exceptions.chat;

import java.util.UUID;

/**
 * Thrown when attempting to create a duplicate chat channel.
 */
public class ChatChannelAlreadyExistsException extends ChatException {
    public ChatChannelAlreadyExistsException(String message) {
        super(message);
    }

    public ChatChannelAlreadyExistsException(UUID rideId) {
        super(String.format("Chat channel already exists for ride: %s", rideId));
    }
}
