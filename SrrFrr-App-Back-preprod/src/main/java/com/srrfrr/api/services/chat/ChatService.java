package com.srrfrr.api.services.chat;

import com.google.firebase.messaging.FirebaseMessagingException;
import com.srrfrr.api.configurations.FirebaseMessagingConf;
import com.srrfrr.api.dto.chat.ChatMessageResponse;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.enums.Chat.MessageType;
import com.srrfrr.api.exceptions.chat.*;
import com.srrfrr.api.repositories.main.chat.ChatChannelRepository;
import com.srrfrr.api.repositories.main.chat.ChatMessageRepository;
import com.srrfrr.api.repositories.main.AuthenticationRepository;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.utils.DebugConsole;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Service for chat operations.
 * Handles chat channels, messages, notifications, and WebSocket communication.
 */
@Service
@Slf4j
public class ChatService {

    private final ChatChannelRepository channelRepository;
    private final ChatMessageRepository messageRepository;
    private final RideRepository rideRepository;
    private final ChatWebSocketService webSocketService;
    private final FirebaseMessagingConf firebaseMessagingConf;
    private final AuthenticationRepository authenticationRepository;
    private final PassengerRepository passengerRepository;

    public ChatService(
            final ChatChannelRepository channelRepository,
            final ChatMessageRepository messageRepository,
            final RideRepository rideRepository,
            final FirebaseMessagingConf firebaseMessagingConf,
            final AuthenticationRepository authenticationRepository,
            final PassengerRepository passengerRepository,
            final ChatWebSocketService webSocketService) {
        this.channelRepository = channelRepository;
        this.messageRepository = messageRepository;
        this.rideRepository = rideRepository;
        this.webSocketService = webSocketService;
        this.firebaseMessagingConf = firebaseMessagingConf;
        this.authenticationRepository = authenticationRepository;
        this.passengerRepository = passengerRepository;
    }

    /**
     * Get paginated messages for a ride with access validation.
     * 
     * @param rideId the ride ID
     * @param userId the requesting user ID
     * @param pageable pagination parameters
     * @return paginated chat messages
     */
    @Transactional(readOnly = true)
    public Page<ChatMessageResponse> getMessagesByRide(UUID rideId, UUID userId, Pageable pageable) {
        ChatChannel channel = channelRepository.findByRideId(rideId)
                .orElseThrow(() -> new ChatChannelNotFoundException(rideId, true));
        DebugConsole.info("Found chat channel " + channel.getId() + " for ride " + rideId);
        validateParticipant(channel, userId);

        Page<ChatMessage> messages = messageRepository.findByChannelIdOrderBySentAtDesc(
            channel.getId(), 
            pageable
        );
        DebugConsole.info("Fetched " + messages.getNumberOfElements() + 
                        " messages for channel " + channel.getId());

        return messages.map(ChatMessageResponse::fromEntity);
    }

    /**
     * Get or create chat channel for a ride.
     * 
     * @param rideId the ride ID
     * @return existing or newly created chat channel
     */
    @Transactional
    public ChatChannel getOrCreateChannel(UUID rideId) {
        return channelRepository.findByRideId(rideId)
                .orElseGet(() -> {
                    Ride ride = rideRepository.findById(rideId)
                            .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

                    ChatChannel channel = ChatChannel.createForRide(ride);
                    channel = channelRepository.save(channel);

                    sendSystemMessage(channel, "Your ride has been confirmed! You can now message each other.");

                    DebugConsole.methodSuccess("ChatService", "createChannel",
                            String.format("Chat channel %s created for ride %s", channel.getId(), rideId));

                    return channel;
                });
    }

    /**
     * Create chat channel for a ride.
     * Throws exception if channel already exists.
     * 
     * @param ride the ride entity
     * @return newly created chat channel
     */
    @Transactional
    public ChatChannel createChannelForRide(Ride ride) {
        if (channelRepository.existsByRideId(ride.getId())) {
            throw new ChatChannelAlreadyExistsException(ride.getId());
        }

        ChatChannel channel = ChatChannel.createForRide(ride);
        channel = channelRepository.save(channel);

        sendSystemMessage(channel, "Your ride has been accepted! You can message your driver here.");

        DebugConsole.methodSuccess("ChatService", "createChannelForRide",
                String.format("Chat channel created for ride %s", ride.getId()));

        return channel;
    }

    /**
     * Get or create channel for a ride with specific participants.
     * 
     * @param ride the ride entity
     * @param driverId the driver ID
     * @param passengerId the passenger ID
     * @return existing or newly created chat channel
     */
    @Transactional
    public ChatChannel getOrCreateChannelForRide(Ride ride, UUID driverId, UUID passengerId) {
        return channelRepository.findByRideId(ride.getId())
                .orElseGet(() -> {
                    ChatChannel newChannel = new ChatChannel();
                    newChannel.setRide(ride);
                    newChannel.setDriverId(driverId);
                    newChannel.setPassengerId(passengerId);
                    newChannel.setActive(true);
                    newChannel.setCreatedAt(LocalDateTime.now());
                    return channelRepository.save(newChannel);
                });
    }

    /**
     * Get channel by ID.
     * 
     * @param channelId the channel ID
     * @return chat channel
     */
    public ChatChannel getChannelById(UUID channelId) {
        return channelRepository.findById(channelId)
                .orElseThrow(() -> new ChatChannelNotFoundException(channelId));
    }

    /**
     * Validate user is participant in channel.
     * 
     * @param channel the chat channel
     * @param userId the user ID to validate
     * @throws UnauthorizedChatAccessException if user is not a participant
     */
    public void validateParticipant(ChatChannel channel, UUID userId) {
        if (!channel.getDriverId().equals(userId) && !channel.getPassengerId().equals(userId)) {
            throw new UnauthorizedChatAccessException(userId, channel.getId());
        }
    }

    /**
     * Send text message.
     * 
     * @param channelId the channel ID
     * @param senderId the sender ID
     * @param content message content
     * @return saved chat message
     */
    @Transactional
    public ChatMessage sendTextMessage(UUID channelId, UUID senderId, String content) {
        ChatChannel channel = getChannelById(channelId);
        validateParticipant(channel, senderId);

        if (content == null || content.trim().isEmpty()) {
            throw new InvalidMessageException("Message content cannot be empty");
        }

        ChatMessage message = ChatMessage.builder()
                .channel(channel)
                .senderId(senderId)
                .messageType(MessageType.TEXT)
                .content(content.trim())
                .status(MessageStatus.SENT)
                .sentAt(LocalDateTime.now())
                .build();

        message = messageRepository.save(message);

        updateChannelLastActivity(channel);

        // Send Firebase notification to receiver (non-blocking)
        UUID receiverId = getReceiverId(channel, senderId);
        sendChatNotificationAsync(receiverId, senderId, content, channelId);

        // Broadcast via WebSocket
        webSocketService.broadcastNewMessage(message);

        return message;
    }

    /**
     * Send media message with Firebase notification.
     * 
     * @param channelId the channel ID
     * @param senderId the sender ID
     * @param type message type (IMAGE, AUDIO, etc.)
     * @param fileUrl URL of the uploaded file
     * @param fileSize size of the file in bytes
     * @param caption optional caption for the media
     * @return saved chat message
     */
    @Transactional
    public ChatMessage sendMediaMessage(UUID channelId, UUID senderId, MessageType type,
                                        String fileUrl, Long fileSize, String caption) {
        ChatChannel channel = getChannelById(channelId);
        validateParticipant(channel, senderId);

        if (fileUrl == null || fileUrl.trim().isEmpty()) {
            throw new InvalidMessageException("File URL cannot be empty");
        }

        ChatMessage message = ChatMessage.builder()
                .channel(channel)
                .senderId(senderId)
                .messageType(type)
                .content(caption)
                .status(MessageStatus.SENT)
                .sentAt(LocalDateTime.now())
                .build();

        MessageFile file = MessageFile.builder()
                .message(message)
                .fileUrl(fileUrl)
                .fileSize(fileSize)
                .build();

        message.setFile(file);
        message = messageRepository.save(message);

        updateChannelLastActivity(channel);

        // Send Firebase notification to receiver (non-blocking)
        UUID receiverId = getReceiverId(channel, senderId);
        String notificationContent = getMediaNotificationContent(type, caption);
        sendChatNotificationAsync(receiverId, senderId, notificationContent, channelId);

        // Broadcast via WebSocket
        webSocketService.broadcastNewMessage(message);

        return message;
    }

    /**
     * Mark all unread messages as read for a user.
     * 
     * @param channelId the channel ID
     * @param userId the user ID
     * @return number of messages marked as read
     */
    @Transactional
    public int markMessagesAsRead(UUID channelId, UUID userId) {
        ChatChannel channel = getChannelById(channelId);
        validateParticipant(channel, userId);

        return messageRepository.markAllAsReadForUser(channelId, userId, LocalDateTime.now());
    }

    /**
     * Mark specific message as read.
     * 
     * @param messageId the message ID
     * @param userId the user ID
     * @return updated chat message
     */
    @Transactional
    public ChatMessage markMessageAsRead(UUID messageId, UUID userId) {
        ChatMessage message = messageRepository.findById(messageId)
                .orElseThrow(() -> new ChatMessageNotFoundException(messageId));

        validateParticipant(message.getChannel(), userId);

        // Only mark as read if user is not the sender
        if (!message.getSenderId().equals(userId) && message.getStatus() != MessageStatus.READ) {
            message.setStatus(MessageStatus.READ);
            message.setReadAt(LocalDateTime.now());
            return messageRepository.save(message);
        }

        return message;
    }

    /**
     * Deactivate channel when ride is completed.
     * 
     * @param channelId the channel ID
     */
    @Transactional
    public void deactivateChannel(UUID channelId) {
        ChatChannel channel = getChannelById(channelId);
        channel.setActive(false);
        channelRepository.save(channel);

        log.info("Deactivated chat channel {}", channelId);
    }

    /**
     * Send system-generated message.
     * 
     * @param channel the chat channel
     * @param content message content
     * @return saved chat message
     */
    private ChatMessage sendSystemMessage(ChatChannel channel, String content) {
        ChatMessage message = ChatMessage.createSystemMessage(channel, content);
        message = messageRepository.save(message);

        updateChannelLastActivity(channel);
        webSocketService.broadcastNewMessage(message);

        return message;
    }

    /**
     * Update channel's last activity timestamp.
     * 
     * @param channel the chat channel
     */
    private void updateChannelLastActivity(ChatChannel channel) {
        channel.setLastMessageAt(LocalDateTime.now());
        channelRepository.save(channel);
    }

    /**
     * Get receiver ID based on sender.
     * 
     * @param channel the chat channel
     * @param senderId the sender ID
     * @return receiver ID
     */
    private UUID getReceiverId(ChatChannel channel, UUID senderId) {
        if (channel.getDriverId().equals(senderId)) {
            return channel.getPassengerId();
        } else {
            return channel.getDriverId();
        }
    }

    /**
     * Get notification content for media messages.
     * 
     * @param type message type
     * @param caption optional caption
     * @return formatted notification content
     */
    private String getMediaNotificationContent(MessageType type, String caption) {
        String baseContent = switch (type) {
            case IMAGE -> "Sent an image";
            case AUDIO -> "Sent an audio message";
            default -> "Sent a file";
        };

        if (caption != null && !caption.trim().isEmpty()) {
            return baseContent + ": " + caption;
        }
        return baseContent;
    }

    /**
     * Send Firebase notification asynchronously (non-blocking).
     * Handles UNREGISTERED tokens gracefully by clearing invalid tokens.
     * 
     * @param receiverId the receiver user ID
     * @param senderId the sender user ID
     * @param messageContent message content
     * @param channelId the channel ID
     */
    private void sendChatNotificationAsync(UUID receiverId, UUID senderId,
                                          String messageContent, UUID channelId) {
        // Run asynchronously to not block message sending
        new Thread(() -> {
            try {
                log.info("[FCM] Preparing notification for receiver={}, sender={}, channel={}", 
                    receiverId, senderId, channelId);

                Passenger receiver = passengerRepository.findById(receiverId).orElse(null);
                if (receiver == null) {
                    log.warn("[FCM] Receiver not found: {}", receiverId);
                    return;
                }

                Passenger sender = passengerRepository.findById(senderId).orElse(null);
                String senderName = sender != null ? sender.getFirstName() : "Someone";

                Authentication auth = authenticationRepository.findByPassenger(receiver).orElse(null);
                if (auth == null) {
                    log.warn("[FCM] Authentication not found for receiver {}", receiverId);
                    return;
                }

                if (auth.getFcmToken() == null || auth.getFcmToken().isBlank()) {
                    log.warn("[FCM] No FCM token for receiver {}", receiverId);
                    return;
                }

                String displayContent = messageContent.length() > 100
                        ? messageContent.substring(0, 97) + "..."
                        : messageContent;

                String title = "New message from " + senderName;
                String body = displayContent;

                log.info("[FCM] Sending notification: title={}, body={}", title, body);
                
                try {
                    firebaseMessagingConf.sendMessage(auth.getFcmToken(), title, body);
                    log.info("[FCM] Notification sent successfully to user {} for channel {}", 
                        receiverId, channelId);
                } catch (FirebaseMessagingException e) {
                    String errorCode = e.getMessagingErrorCode() != null 
                        ? e.getMessagingErrorCode().name() 
                        : "UNKNOWN";
                    
                    if ("UNREGISTERED".equals(errorCode)) {
                        log.warn("[FCM] Token unregistered for user {}, clearing token", receiverId);
                        // Clear invalid token
                        // auth.setFcmToken(null);
                        // authenticationRepository.save(auth);
                    } else {
                        log.error("[FCM] Failed to send notification to {}: {} - {}", 
                            receiverId, errorCode, e.getMessage());
                    }
                }

            } catch (Exception e) {
                log.error("[FCM] Unexpected error sending notification to {}: {}", 
                    receiverId, e.getMessage(), e);
            }
        }).start();
    }
}