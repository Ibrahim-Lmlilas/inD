package com.srrfrr.api.repositories.main.chat;

import com.srrfrr.api.entities.main.ChatMessage;
import com.srrfrr.api.enums.Chat.MessageStatus;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ChatMessage entity operations.
 */
@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {
    @Query("""
        SELECT m
        FROM ChatMessage m
        WHERE m.channel.ride.id = :rideId
        ORDER BY m.sentAt ASC
    """)
    List<ChatMessage> findMessagesByRideId(@Param("rideId") UUID rideId);
    /**
     * Finds messages by channel ID with pagination.
     */
    Page<ChatMessage> findByChannelIdOrderBySentAtDesc(UUID channelId, Pageable pageable);

    /**
     * Finds unread messages for a user in a channel.
     */
    @Query("SELECT cm FROM ChatMessage cm WHERE cm.channel.id = :channelId " + "AND cm.senderId != :userId AND cm.status != 'READ'")
    List<ChatMessage> findUnreadMessages(@Param("channelId") UUID channelId, @Param("userId") UUID userId);

    /**
     * Updates message status for multiple messages.
     */
    @Modifying
    @Query("UPDATE ChatMessage cm SET cm.status = :status, cm.deliveredAt = :timestamp " + "WHERE cm.id IN :messageIds")
    void updateMessagesStatus(@Param("messageIds") List<UUID> messageIds, @Param("status") MessageStatus status, @Param("timestamp") LocalDateTime timestamp);

    /**
     * Marks messages as read.
     */
    @Modifying
    @Query("UPDATE ChatMessage cm SET cm.status = 'READ', cm.readAt = :readAt " + "WHERE cm.channel.id = :channelId AND cm.senderId != :userId AND cm.status != 'READ'")
    int markMessagesAsRead(@Param("channelId") UUID channelId, @Param("userId") UUID userId, @Param("readAt") LocalDateTime readAt);

    /**
     * Finds the last message in a channel.
     */
    Optional<ChatMessage> findTopByChannelIdOrderBySentAtDesc(UUID channelId);

    /**
     * Deletes messages older than specified date (for data retention).
     */
    @Modifying
    @Query("DELETE FROM ChatMessage cm WHERE cm.sentAt < :cutoffDate")
    int deleteMessagesOlderThan(@Param("cutoffDate") LocalDateTime cutoffDate);

    /**
     * Counts unread messages in a channel for a specific user.
     *
     * @param channelId Channel ID
     * @param userId    User ID (recipient)
     * @return Number of unread messages
     */
    @Query("SELECT COUNT(m) FROM ChatMessage m " + "WHERE m.channel.id = :channelId " + "AND m.senderId != :userId " + "AND m.status != 'READ'")
    int countUnreadMessages(@Param("channelId") UUID channelId, @Param("userId") UUID userId);

    /**
     * Finds the last message in a channel.
     *
     * @param channelId Channel ID
     * @return Last message or null
     */
    @Query("SELECT m FROM ChatMessage m WHERE m.channel.id = :channelId " + "ORDER BY m.sentAt DESC LIMIT 1")
    ChatMessage findLastMessageInChannel(@Param("channelId") UUID channelId);

    /**
     * Finds all undelivered messages for a user in a channel.
     *
     * @param channelId Channel ID
     * @param userId    User ID (recipient)
     * @return List of undelivered messages
     */
    @Query("SELECT m FROM ChatMessage m " + "WHERE m.channel.id = :channelId " + "AND m.senderId != :userId " + "AND m.status = 'SENT' " + "ORDER BY m.sentAt ASC")
    List<ChatMessage> findUndeliveredMessages(@Param("channelId") UUID channelId, @Param("userId") UUID userId);


    /**
     * Find undelivered messages for a specific channel (excluding sender)
     */
    List<ChatMessage> findByChannelIdAndStatusAndSenderIdNot(UUID channelId, MessageStatus status, UUID senderId);

    /**
     * Find unread messages for a user in a channel
     */
    @Query("SELECT m FROM ChatMessage m WHERE m.channel.id = :channelId " + "AND m.senderId != :userId " + "AND m.status != 'READ'")
    List<ChatMessage> findUnreadMessagesForUser(@Param("channelId") UUID channelId, @Param("userId") UUID userId);

    /**
     * Count unread messages for a user in a channel
     */
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.channel.id = :channelId " + "AND m.senderId != :userId " + "AND m.status != 'READ'")
    int countUnreadMessagesForUser(@Param("channelId") UUID channelId, @Param("userId") UUID userId);

    /**
     * Mark all messages as read for a user in a channel
     */
    @Modifying
    @Transactional
    @Query("UPDATE ChatMessage m SET m.status = 'READ', m.readAt = :readAt " + "WHERE m.channel.id = :channelId " + "AND m.senderId != :userId " + "AND m.status != 'READ'")
    int markAllAsReadForUser(@Param("channelId") UUID channelId, @Param("userId") UUID userId, @Param("readAt") LocalDateTime readAt);

    /**
     * Find last message in a channel
     */
    Optional<ChatMessage> findFirstByChannelIdOrderBySentAtDesc(UUID channelId);
}