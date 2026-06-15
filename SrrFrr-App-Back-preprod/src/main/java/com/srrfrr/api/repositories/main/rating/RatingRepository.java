package com.srrfrr.api.repositories.main.rating;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.Rating;
import com.srrfrr.api.entities.main.Ride;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RatingRepository extends JpaRepository<Rating, UUID> {
    
    boolean existsByRideAndSender(Ride ride, Passenger sender);
    
    long countByReceiverId(UUID receiverId);

    /**
     * Find all ratings sent by a user.
     * 
     * @param senderId the sender ID
     * @return list of ratings
     */
    List<Rating> findBySenderId(UUID senderId);

    /**
     * Find all ratings received by a user.
     * 
     * @param receiverId the receiver ID
     * @return list of ratings
     */
    List<Rating> findByReceiverId(UUID receiverId);

    /**
     * Check if a user has rated a specific ride.
     * 
     * @param rideId   the ride ID
     * @param senderId the sender (rater) ID
     * @return true if rating exists
     */
    boolean existsByRideIdAndSenderId(UUID rideId, UUID senderId);
}