// ChatChannelRepository.java
package com.srrfrr.api.repositories.main.chat;

import com.srrfrr.api.entities.main.ChatChannel;
import com.srrfrr.api.entities.main.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ChatChannel entity operations.
 */
@Repository
public interface ChatChannelRepository extends JpaRepository<ChatChannel, UUID> {
	/**
	 * Finds chat channel by ride ID.
	 */
	Optional<ChatChannel> findByRideId(UUID rideId);

	/**
	 * Finds all active channels for a user (as driver or passenger).
	 *
	 * @param userId User ID
	 * @return List of active channels
	 */
	@Query("SELECT c FROM ChatChannel c " +
			"WHERE (c.driverId = :userId OR c.passengerId = :userId) " +
			"AND c.isActive = true " +
			"ORDER BY c.lastMessageAt DESC NULLS LAST")
	List<ChatChannel> findActiveChannelsByUserId(@Param("userId") UUID userId);

	/**
	 * Finds chat channel by participant IDs.
	 */
	@Query("SELECT cc FROM ChatChannel cc WHERE " +
			"(cc.driverId = :driverId AND cc.passengerId = :passengerId) OR " +
			"(cc.driverId = :passengerId AND cc.passengerId = :driverId)")
	Optional<ChatChannel> findByParticipants(@Param("driverId") UUID driverId,
			@Param("passengerId") UUID passengerId);

	/**
	 * Checks if a channel exists for the given ride.
	 */
	boolean existsByRideId(UUID rideId);

	/**
	 * Deactivates old channels (for data retention policy).
	 */
	@Modifying
	@Query("UPDATE ChatChannel cc SET cc.isActive = false WHERE cc.createdAt < :cutoffDate")
	int deactivateOldChannels(@Param("cutoffDate") java.time.LocalDateTime cutoffDate);
}