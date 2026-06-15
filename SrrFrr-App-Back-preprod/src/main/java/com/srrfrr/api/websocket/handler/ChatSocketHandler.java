package com.srrfrr.api.websocket.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.entities.main.ChatChannel;
import com.srrfrr.api.entities.main.ChatMessage;
import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.enums.Chat.MessageType;
import com.srrfrr.api.repositories.main.chat.ChatMessageRepository;
import com.srrfrr.api.services.auth.TokenService;
import com.srrfrr.api.services.chat.ChatService;
import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.managers.ChatSessionManager;

import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class ChatSocketHandler extends TextWebSocketHandler {

    private final ChatService chatService;
    private final ChatMessageRepository messageRepository;
    private final ObjectMapper objectMapper;
    private final ChatSessionManager sessionManager;
    private final TokenService tokenService;

    private final Map<String, Map<String, WebSocketSession>> channelSessions = new ConcurrentHashMap<>();
    private final Map<String, String> sessionToChannel = new ConcurrentHashMap<>();
    private final Map<String, String> sessionToUser = new ConcurrentHashMap<>();

    public ChatSocketHandler(ChatService chatService,
            ChatMessageRepository messageRepository,
            ObjectMapper objectMapper,
            ChatSessionManager sessionManager,
            TokenService tokenService) {
        this.chatService = chatService;
        this.messageRepository = messageRepository;
        this.objectMapper = objectMapper;
        this.sessionManager = sessionManager;
        this.tokenService = tokenService;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String query = session.getUri().getQuery();
        if (query == null || query.isEmpty()) {
            session.close(CloseStatus.BAD_DATA);
            return;
        }

        String token = extractParam(query, "token");

        if (token == null) {
            sendError(session, "Missing authentication token");
            session.close(CloseStatus.BAD_DATA);
            return;
        }

        try {
            Claims claims = tokenService.validateAndExtractClaims(token);
            String userId = claims.get("userId", String.class);
            String channelId = claims.get("channelId", String.class);
            DebugConsole.info("ChatSocket", "Token validated - userId: " + userId + ", channelId: " + channelId);

            if (userId == null || channelId == null) {
                sendError(session, "Invalid token payload");
                session.close(CloseStatus.BAD_DATA);
                return;
            }

            ChatChannel channel;
            try {
                channel = chatService.getChannelById(UUID.fromString(channelId));
                DebugConsole.info("ChatSocket", "Channel found: " + channel.getId());
            } catch (Exception e) {
                DebugConsole.methodError("ChatSocket", "afterConnectionEstablished",
                        "Channel " + channelId + " not found in database: " + e.getMessage(), e);
                sendError(session, "Chat channel not found");
                session.close(CloseStatus.NOT_ACCEPTABLE);
                return;
            }
            chatService.validateParticipant(channel, UUID.fromString(userId));

            String userType = channel.getDriverId().equals(UUID.fromString(userId))
                    ? "driver"
                    : "passenger";
            sessionManager.addSession(userId, session, userType);
            sessionManager.addUserChannel(userId, channelId);

            channelSessions.computeIfAbsent(channelId, k -> new ConcurrentHashMap<>())
                    .put(userId, session);
            sessionToChannel.put(session.getId(), channelId);
            sessionToUser.put(session.getId(), userId);

            int subscriberCount = channelSessions.get(channelId).size();
            DebugConsole.methodSuccess("ChatSocket", "afterConnectionEstablished",
                    "User " + userId + " connected to channel " + channelId + " (Total subscribers: " + subscriberCount
                            + ")");

            //LOG ALL SUBSCRIBERS
            DebugConsole.info("ChatSocket", "Current subscribers in channel " + channelId + ":");
            for (Map.Entry<String, WebSocketSession> entry : channelSessions.get(channelId).entrySet()) {
                DebugConsole.info("ChatSocket", "  - User: " + entry.getKey() + " | Session: " +
                        entry.getValue().getId() + " | Open: " + entry.getValue().isOpen());
            }

            // Send connection confirmation
            ObjectNode confirmationMsg = objectMapper.createObjectNode();
            confirmationMsg.put("type", "connected");
            confirmationMsg.put("channelId", channelId);
            confirmationMsg.put("userId", userId);
            confirmationMsg.put("subscriberCount", subscriberCount);
            confirmationMsg.put("timestamp", System.currentTimeMillis());

            session.sendMessage(new TextMessage(confirmationMsg.toString()));
            DebugConsole.methodSuccess("ChatSocket", "afterConnectionEstablished",
                    "Sent connection confirmation to user " + userId);

            notifyUserStatus(channelId, userId, true);
            markMessagesAsDelivered(UUID.fromString(channelId), UUID.fromString(userId));

        } catch (Exception e) {
            DebugConsole.methodError("ChatSocket", "afterConnectionEstablished",
                    "Connection failed: invalid token", e);
            sendError(session, "Invalid or expired authentication token");
            session.close(CloseStatus.SERVER_ERROR);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        try {
            JsonNode json = objectMapper.readTree(message.getPayload());

            if (!json.has("type")) {
                sendError(session, "Message type is required");
                return;
            }

            String type = json.get("type").asText();
            String userId = sessionToUser.get(session.getId());
            String channelId = sessionToChannel.get(session.getId());

            DebugConsole.info("ChatSocket", "Received message - Type: " + type +
                    " | User: " + userId + " | Channel: " + channelId);

            switch (type) {
                case "sendMessage" -> handleSendMessage(session, json);
                case "ping" -> handlePing(session);
                default -> DebugConsole.methodWarning("ChatSocket", "handleTextMessage",
                        "Unknown message type: " + type);
            }
        } catch (Exception e) {
            DebugConsole.methodError("ChatSocket", "handleTextMessage",
                    "Failed to process WebSocket message", e);
            sendError(session, "Failed to process message");
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String channelId = sessionToChannel.remove(session.getId());
        String userId = sessionToUser.remove(session.getId());

        DebugConsole.sectionHeader("CHAT WEBSOCKET DISCONNECTION");
        DebugConsole.info("ChatSocket", "User ID    : " + userId);
        DebugConsole.info("ChatSocket", "Channel ID : " + channelId);
        DebugConsole.info("ChatSocket", "Reason     : " + status.getReason());
        DebugConsole.info("ChatSocket", "Code       : " + status.getCode());

        if (channelId != null && userId != null) {
            Map<String, WebSocketSession> sessions = channelSessions.get(channelId);
            if (sessions != null) {
                sessions.remove(userId);
                DebugConsole.info("ChatSocket",
                        "Remaining subscribers in channel " + channelId + ": " + sessions.size());

                if (sessions.isEmpty()) {
                    channelSessions.remove(channelId);
                    DebugConsole.info("ChatSocket", "Channel " + channelId + " removed (no subscribers)");
                }
            }
            notifyUserStatus(channelId, userId, false);
        }
    }

    @Transactional
    private void handleSendMessage(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "content", "senderId", "receiverId")) {
            sendError(session, "Missing required fields");
            return;
        }

        String channelId = sessionToChannel.get(session.getId());
        if (channelId == null) {
            sendError(session, "Channel not found");
            return;
        }

        try {
            String content = json.get("content").asText();
            String senderId = json.get("senderId").asText();
            String receiverId = json.get("receiverId").asText();

            MessageType messageType = json.has("messageType")
                    ? MessageType.valueOf(json.get("messageType").asText())
                    : MessageType.TEXT;

            DebugConsole.info("ChatSocket", "Processing message:");
            DebugConsole.info("ChatSocket", "  Channel   : " + channelId);
            DebugConsole.info("ChatSocket", "  From      : " + senderId);
            DebugConsole.info("ChatSocket", "  To        : " + receiverId);
            DebugConsole.info("ChatSocket", "  Content   : " + content.substring(0, Math.min(50, content.length())));
            DebugConsole.info("ChatSocket", "  Type      : " + messageType);

            // Always create the message in the database
            ChatMessage chatMessage;
            if (messageType == MessageType.TEXT) {
                chatMessage = chatService.sendTextMessage(
                        UUID.fromString(channelId),
                        UUID.fromString(senderId),
                        content);
            } else {
                String fileUrl = json.has("fileUrl") ? json.get("fileUrl").asText() : null;
                Long fileSize = json.has("fileSize") ? json.get("fileSize").asLong() : null;
                chatMessage = chatService.sendMediaMessage(
                        UUID.fromString(channelId),
                        UUID.fromString(senderId),
                        messageType,
                        fileUrl,
                        fileSize,
                        content);
            }

            boolean receiverOnline = isUserOnline(channelId, receiverId);
            DebugConsole.info("ChatSocket", "Receiver " + receiverId + " is " +
                    (receiverOnline ? "ONLINE" : "OFFLINE"));

            // If receiver is online, mark as delivered
            if (receiverOnline) {
                chatMessage.setStatus(MessageStatus.DELIVERED);
                chatMessage.setDeliveredAt(LocalDateTime.now());
                messageRepository.save(chatMessage);
            }

            // ONLY send newMessage to the RECEIVER (not to sender)
            if (receiverOnline) {
                ObjectNode receiverMessage = objectMapper.createObjectNode();
                receiverMessage.put("type", "newMessage");
                receiverMessage.put("messageId", chatMessage.getId().toString());
                receiverMessage.put("channelId", channelId);
                receiverMessage.put("senderId", senderId);
                receiverMessage.put("receiverId", receiverId);
                receiverMessage.put("content", content);
                receiverMessage.put("sentAt", chatMessage.getSentAt().toString());
                receiverMessage.put("messageType", chatMessage.getMessageType().toString());
                receiverMessage.put("status", chatMessage.getStatus().toString());

                if (json.has("fileUrl")) {
                    receiverMessage.put("fileUrl", json.get("fileUrl").asText());
                }
                if (json.has("fileSize")) {
                    receiverMessage.put("fileSize", json.get("fileSize").asLong());
                }

                boolean sentToReceiver = sendToUserWithReturn(channelId, receiverId, receiverMessage);
                DebugConsole.info("ChatSocket", "Message sent to receiver: " +
                        (sentToReceiver ? "SUCCESS" : "FAILED"));
            } else {
                DebugConsole.info("ChatSocket", "Receiver offline - message saved, will be delivered later");
            }

            // Send confirmation to SENDER only (messageSent type)
            ObjectNode senderConfirmation = objectMapper.createObjectNode();
            senderConfirmation.put("type", "messageSent");
            senderConfirmation.put("messageId", chatMessage.getId().toString());
            senderConfirmation.put("channelId", channelId);
            senderConfirmation.put("content", content);  // Add content for Flutter
            senderConfirmation.put("sentAt", chatMessage.getSentAt().toString());
            senderConfirmation.put("status", chatMessage.getStatus().toString());
            senderConfirmation.put("messageType", chatMessage.getMessageType().toString());

            if (json.has("fileUrl")) {
                senderConfirmation.put("fileUrl", json.get("fileUrl").asText());
            }
            if (json.has("fileSize")) {
                senderConfirmation.put("fileSize", json.get("fileSize").asLong());
            }

            boolean sentToSender = sendToUserWithReturn(channelId, senderId, senderConfirmation);
            DebugConsole.info("ChatSocket", "Confirmation sent to sender: " +
                    (sentToSender ? "SUCCESS" : "FAILED"));

            DebugConsole.methodSuccess("ChatSocket", "handleSendMessage", "Message processing complete");

        } catch (Exception e) {
            DebugConsole.methodError("ChatSocket", "handleSendMessage", "Failed to send message", e);
            sendError(session, "Failed to send message: " + e.getMessage());
        }
    }

    private boolean sendToUserWithReturn(String channelId, String userId, ObjectNode message) {
        Map<String, WebSocketSession> sessions = channelSessions.get(channelId);
        if (sessions == null) {
            DebugConsole.methodWarning("ChatSocket", "sendToUser",
                    "No sessions found for channel " + channelId);
            return false;
        }

        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            sendToSession(session, message.toString());
            DebugConsole.methodSuccess("ChatSocket", "sendToUser",
                    "Sent to user " + userId + " (session " + session.getId() + ")");
            return true;
        } else {
            DebugConsole.methodWarning("ChatSocket", "sendToUser",
                    "User " + userId + " not found or session closed in channel " + channelId);
            return false;
        }
    }

    private void handlePing(WebSocketSession session) {
        try {
            ObjectNode pong = objectMapper.createObjectNode();
            pong.put("type", "pong");
            pong.put("timestamp", System.currentTimeMillis());
            session.sendMessage(new TextMessage(pong.toString()));
        } catch (IOException e) {
            log.error("Failed to send pong", e);
        }
    }

    private void markMessagesAsDelivered(UUID channelId, UUID userId) {
        try {
            List<ChatMessage> undeliveredMessages = messageRepository
                    .findByChannelIdAndStatusAndSenderIdNot(channelId, MessageStatus.SENT, userId);

            if (!undeliveredMessages.isEmpty()) {
                LocalDateTime now = LocalDateTime.now();
                undeliveredMessages.forEach(msg -> {
                    msg.setStatus(MessageStatus.DELIVERED);
                    msg.setDeliveredAt(now);
                });
                messageRepository.saveAll(undeliveredMessages);

                // Notify senders
                undeliveredMessages.forEach(msg -> {
                    ObjectNode deliveredNotification = objectMapper.createObjectNode();
                    deliveredNotification.put("type", "messageDelivered");
                    deliveredNotification.put("messageId", msg.getId().toString());
                    deliveredNotification.put("channelId", channelId.toString());
                    deliveredNotification.put("deliveredTo", userId.toString());
                    deliveredNotification.put("deliveredAt", now.toString());

                    sendToUser(channelId.toString(), msg.getSenderId().toString(), deliveredNotification);
                });
            }
        } catch (Exception e) {
            log.error("Failed to mark messages as delivered", e);
        }
    }

    private void notifyUserStatus(String channelId, String userId, boolean isOnline) {
        try {
            ObjectNode statusMsg = objectMapper.createObjectNode();
            statusMsg.put("type", "userStatus");
            statusMsg.put("channelId", channelId);
            statusMsg.put("userId", userId);
            statusMsg.put("isOnline", isOnline);
            statusMsg.put("timestamp", System.currentTimeMillis());

            broadcastToOthers(channelId, userId, statusMsg);
        } catch (Exception e) {
            log.error("Failed to send user status", e);
        }
    }

    private boolean isUserOnline(String channelId, String userId) {
        Map<String, WebSocketSession> sessions = channelSessions.get(channelId);
        if (sessions == null)
            return false;

        WebSocketSession session = sessions.get(userId);
        return session != null && session.isOpen();
    }

    private void sendToUser(String channelId, String userId, ObjectNode message) {
        Map<String, WebSocketSession> sessions = channelSessions.get(channelId);
        if (sessions == null)
            return;

        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            sendToSession(session, message.toString());
        }
    }

    private void broadcastToOthers(String channelId, String excludeUserId, ObjectNode message) {
        Map<String, WebSocketSession> sessions = channelSessions.get(channelId);
        if (sessions == null)
            return;

        String messageStr = message.toString();
        sessions.entrySet().stream()
                .filter(e -> !e.getKey().equals(excludeUserId))
                .forEach(e -> sendToSession(e.getValue(), messageStr));
    }

    private void sendToSession(WebSocketSession session, String message) {
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(message));
            } catch (IOException e) {
                log.error("Failed to send message to session", e);
            }
        }
    }

    private void sendError(WebSocketSession session, String error) {
        if (session != null && session.isOpen()) {
            try {
                ObjectNode msg = objectMapper.createObjectNode();
                msg.put("type", "error");
                msg.put("message", error);
                session.sendMessage(new TextMessage(msg.toString()));
            } catch (IOException e) {
                log.error("Failed to send error message", e);
            }
        }
    }

    private boolean validateRequiredFields(JsonNode json, String... fields) {
        for (String field : fields) {
            if (!json.has(field)) {
                return false;
            }
        }
        return true;
    }

    private String extractParam(String query, String paramName) {
        for (String param : query.split("&")) {
            String[] parts = param.split("=");
            if (parts.length == 2 && parts[0].equals(paramName)) {
                return parts[1];
            }
        }
        return null;
    }
}