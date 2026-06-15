package com.srrfrr.api.exceptions.chat;

import java.util.UUID;

/**
 * Thrown when a chat channel is not found.
 */
public class ChatChannelNotFoundException extends ChatException {
    public ChatChannelNotFoundException(String message) {
        super(message);
    }

    public ChatChannelNotFoundException(UUID channelId) {
        super(String.format("Chat channel not found with ID: %s", channelId));
    }

    public ChatChannelNotFoundException(UUID rideId, boolean byRideId) {
        super(String.format("Chat channel not found for ride ID: %s", rideId));
    }
}
