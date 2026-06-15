package com.srrfrr.api.services.chat;

import com.srrfrr.api.entities.main.ChatChannel;
import com.srrfrr.api.entities.main.ChatMessage;
import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.repositories.main.chat.ChatChannelRepository;
import com.srrfrr.api.websocket.managers.ChatSessionManager;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Handles real-time WebSocket communication for chat features.
 * Uses ChatSessionManager for dedicated chat sessions.
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class ChatWebSocketService {

    private final ChatSessionManager sessionManager;
    private final ObjectMapper objectMapper;
    private final ChatChannelRepository channelRepository;

    /**
     * Broadcasts new message to both participants.
     *
     * @param message The new chat message
     */
    public void broadcastNewMessage(ChatMessage message) {
        UUID channelId = message.getChannel().getId();
        UUID senderId = message.getSenderId();
        UUID passengerId = message.getChannel().getPassengerId();
        UUID driverId = message.getChannel().getDriverId();

        // Send to passenger (if not the sender)
        if (!passengerId.equals(senderId)) {
            sendToUser(passengerId.toString(), createNewMessageEvent(message));
        }

        // Send to driver (if not the sender)
        if (!driverId.equals(senderId)) {
            sendToUser(driverId.toString(), createNewMessageEvent(message));
        }

        // Send delivery receipt to sender
        sendToUser(senderId.toString(), createMessageSentEvent(message));
    }

    /**
     * Sends message to a specific user via WebSocket.
     */
    private void sendToUser(String userId, ObjectNode message) {
        WebSocketSession session = sessionManager.getSessionByUserId(userId);

        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(message.toString()));
            } catch (IOException e) {
                log.warn("Failed to send WebSocket message to user {}: {}", userId, e.getMessage());
            }
        }
    }

    /**
     * Creates new message event for WebSocket.
     */
    private ObjectNode createNewMessageEvent(ChatMessage message) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "newMessage");
        event.put("id", message.getId().toString());
        event.put("channelId", message.getChannel().getId().toString());
        event.put("senderId", message.getSenderId().toString());
        event.put("messageType", message.getMessageType().toString());
        event.put("content", message.getContent());

        // Vérifie si le message a un fichier
        if (message.getFile() != null) {
            event.put("fileUrl", message.getFile().getFileUrl());
            if (message.getFile().getFileSize() != null) {
                event.put("fileSize", message.getFile().getFileSize());
            }
        }

        event.put("status", message.getStatus().toString());
        event.put("sentAt", message.getSentAt().toString());
        event.put("isSystemMessage", message.isSystemMessage());

        return event;
    }

    /**
     * Creates message sent confirmation event.
     */
    private ObjectNode createMessageSentEvent(ChatMessage message) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "messageSent");
        event.put("id", message.getId().toString());
        event.put("channelId", message.getChannel().getId().toString());
        event.put("sentAt", message.getSentAt().toString());

        return event;
    }

    /**
     * Notifies about message status updates (delivered/read).
     *
     * @param channelId  The chat channel ID
     * @param messageIds List of message IDs with updated status
     * @param status     New message status
     * @param userId     User who triggered the status update
     */
    public void notifyMessageStatusUpdate(UUID channelId, List<UUID> messageIds,
            MessageStatus status, UUID userId) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "messageStatusUpdate");
        event.put("channelId", channelId.toString());
        event.put("status", status.toString());
        event.put("updatedBy", userId.toString());

        var messageArray = objectMapper.createArrayNode();
        messageIds.forEach(id -> messageArray.add(id.toString()));
        event.set("messageIds", messageArray);

        // Notify both participants about status update
        broadcastToChannelParticipants(channelId, event);
    }

    /**
     * Notifies when messages are read by a user.
     *
     * @param channelId    The chat channel ID
     * @param readerId     User who read the messages
     * @param messageCount Number of messages read
     */
    public void notifyMessagesRead(UUID channelId, UUID readerId, int messageCount) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "messagesRead");
        event.put("channelId", channelId.toString());
        event.put("readerId", readerId.toString());
        event.put("messageCount", messageCount);
        event.put("timestamp", System.currentTimeMillis());

        broadcastToChannelParticipants(channelId, event);
    }

    /**
     * Sends typing indicator to the other participant.
     *
     * @param channelId The chat channel ID
     * @param userId    User who is typing
     * @param isTyping  Whether typing started or stopped
     */
    public void sendTypingIndicator(UUID channelId, UUID userId, boolean isTyping) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "typingIndicator");
        event.put("channelId", channelId.toString());
        event.put("userId", userId.toString());
        event.put("isTyping", isTyping);

        // Send to the other participant only
        ChatChannel channel = getChannelForBroadcast(channelId);
        UUID recipientId = channel.getDriverId().equals(userId) ? channel.getPassengerId() : channel.getDriverId();

        sendToUser(recipientId.toString(), event);
    }

    /**
     * Sends online/offline status update.
     *
     * @param channelId The chat channel ID
     * @param userId    User whose status changed
     * @param isOnline  Whether user is online
     */
    public void sendUserStatusUpdate(UUID channelId, UUID userId, boolean isOnline) {
        ObjectNode event = objectMapper.createObjectNode();
        event.put("type", "userStatus");
        event.put("channelId", channelId.toString());
        event.put("userId", userId.toString());
        event.put("isOnline", isOnline);
        event.put("timestamp", System.currentTimeMillis());

        // Send to the other participant
        ChatChannel channel = getChannelForBroadcast(channelId);
        UUID recipientId = channel.getDriverId().equals(userId) ? channel.getPassengerId() : channel.getDriverId();

        sendToUser(recipientId.toString(), event);
    }

    /**
     * Broadcasts event to both channel participants.
     */
    private void broadcastToChannelParticipants(UUID channelId, ObjectNode event) {
        ChatChannel channel = getChannelForBroadcast(channelId);

        sendToUser(channel.getDriverId().toString(), event);
        sendToUser(channel.getPassengerId().toString(), event);
    }

    /**
     * Gets channel for broadcast.
     */
    private ChatChannel getChannelForBroadcast(UUID channelId) {
        return channelRepository.findById(channelId)
                .orElseThrow(() -> new IllegalArgumentException("Chat channel not found: " + channelId));
    }
}
