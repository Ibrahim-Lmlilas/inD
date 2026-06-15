package com.srrfrr.api.repositories.main;

import com.srrfrr.api.entities.main.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository for Notification entity operations.
 * Uses category-based filtering instead of string prefix matching.
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    /**
     * Find all notifications by receiver ID.
     * 
     * @param receiverId the receiver ID
     * @return list of notifications
     */
    List<Notification> findByReceiverId(UUID receiverId);

    /**
     * Find notifications by receiver, type prefix, and date filter (non-paginated).
     */
    @Query("SELECT n FROM Notification n WHERE n.receiver.id = :receiverId " +
           "AND n.type LIKE CONCAT(:typePrefix, '%') " +
           "AND n.createdAt > :createdAfter " +
           "ORDER BY n.createdAt DESC")
    List<Notification> findByReceiverAndTypeAndDate(
            @Param("receiverId") UUID receiverId,
            @Param("typePrefix") String typePrefix,
            @Param("createdAfter") LocalDateTime createdAfter);

    /**
     * Find paginated notifications by receiver, type prefix, and date filter.
     */
    @Query("SELECT n FROM Notification n WHERE n.receiver.id = :receiverId " +
           "AND n.type LIKE CONCAT(:typePrefix, '%') " +
           "AND n.createdAt > :createdAfter " +
           "ORDER BY n.createdAt DESC")
    Page<Notification> findByReceiverAndTypeAndDate(
            @Param("receiverId") UUID receiverId,
            @Param("typePrefix") String typePrefix,
            @Param("createdAfter") LocalDateTime createdAfter,
            Pageable pageable);

    /**
     * Mark all notifications as read for a specific receiver.
     */
    @Modifying
    @Query("UPDATE Notification n SET n.status = 'READ' WHERE n.receiver.id = :receiverId")
    void markAllAsRead(@Param("receiverId") UUID receiverId);

    /**
     * Delete notifications created before a specific date.
     */
    void deleteByCreatedAtBefore(LocalDateTime cutoffDate);

    /**
     * Count unread notifications for a receiver.
     */
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.receiver.id = :receiverId AND n.status = 'UNREAD'")
    long countUnreadByReceiverId(@Param("receiverId") UUID receiverId);

    /**
     * Find all unread notifications for a receiver.
     */
    @Query("SELECT n FROM Notification n WHERE n.receiver.id = :receiverId AND n.status = 'UNREAD' ORDER BY n.createdAt DESC")
    List<Notification> findUnreadByReceiverId(@Param("receiverId") UUID receiverId);

    /**
     * Count notifications by receiver and type prefix.
     */
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.receiver.id = :receiverId AND n.type LIKE CONCAT(:typePrefix, '%')")
    long countByReceiverAndTypePrefix(
        @Param("receiverId") UUID receiverId, 
        @Param("typePrefix") String typePrefix
    );

    @Query("SELECT n FROM Notification n WHERE n.receiver.id = :receiverId " +
        "AND n.createdAt > :createdAfter " +
        "ORDER BY n.createdAt DESC")
    List<Notification> findByReceiverAndDate(
            @Param("receiverId") UUID receiverId,
            @Param("createdAfter") LocalDateTime createdAfter);
}