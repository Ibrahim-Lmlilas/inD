package com.srrfrr.api.repositories.main.subscription;

import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.DriverSubscription;
import com.srrfrr.api.enums.SubscriptionStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for DriverSubscription entity operations.
 */
@Repository
public interface DriverSubscriptionRepository extends JpaRepository<DriverSubscription, UUID> {

    /**
     * Find active subscription for a driver.
     * 
     * @param driver the driver entity
     * @return optional active subscription
     */
    @Query("SELECT ds FROM DriverSubscription ds WHERE ds.driver = :driver " +
           "AND ds.status = 'ACTIVE' " +
           "AND ds.endDate > CURRENT_TIMESTAMP")
    Optional<DriverSubscription> findActiveSubscription(@Param("driver") Driver driver);

    /**
     * Find all subscriptions for a driver ordered by creation date (newest first).
     * Non-paginated version.
     * 
     * @param driver the driver entity
     * @return list of subscriptions
     */
    List<DriverSubscription> findByDriverOrderByCreatedAtDesc(Driver driver);

    /**
     * Find paginated subscriptions for a driver.
     * 
     * @param driver the driver entity
     * @param pageable pagination parameters
     * @return paginated subscriptions
     */
    Page<DriverSubscription> findByDriverOrderByCreatedAtDesc(Driver driver, Pageable pageable);

    /**
     * Find all expired subscriptions that are still marked as ACTIVE.
     * Used by scheduled task to update subscription statuses.
     * 
     * @return list of expired subscriptions
     */
    @Query("SELECT ds FROM DriverSubscription ds WHERE ds.status = 'ACTIVE' " +
           "AND ds.endDate <= CURRENT_TIMESTAMP")
    List<DriverSubscription> findExpiredSubscriptions();

    /**
     * Find subscriptions by status.
     * 
     * @param status subscription status
     * @return list of subscriptions
     */
    List<DriverSubscription> findByStatus(SubscriptionStatus status);

    /**
     * Find subscriptions expiring within a specific timeframe.
     * Useful for sending expiration reminders.
     * 
     * @param startDate start of the timeframe
     * @param endDate end of the timeframe
     * @return list of subscriptions expiring in timeframe
     */
    @Query("SELECT ds FROM DriverSubscription ds WHERE ds.status = 'ACTIVE' " +
           "AND ds.endDate BETWEEN :startDate AND :endDate")
    List<DriverSubscription> findSubscriptionsExpiringBetween(
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );

    /**
     * Count active subscriptions for a driver.
     * 
     * @param driver the driver entity
     * @return count of active subscriptions
     */
    @Query("SELECT COUNT(ds) FROM DriverSubscription ds WHERE ds.driver = :driver " +
           "AND ds.status = 'ACTIVE'")
    long countActiveSubscriptions(@Param("driver") Driver driver);

    /**
     * Get total subscription revenue for a driver.
     * 
     * @param driver the driver entity
     * @return total amount spent on subscriptions
     */
    @Query("SELECT COALESCE(SUM(ds.subscriptionPlan.price), 0) FROM DriverSubscription ds " +
           "WHERE ds.driver = :driver")
    double getTotalSubscriptionRevenue(@Param("driver") Driver driver);

    /**
     * Find the most recent subscription for a driver.
     * 
     * @param driver the driver entity
     * @return optional most recent subscription
     */
    @Query("SELECT ds FROM DriverSubscription ds WHERE ds.driver = :driver " +
           "ORDER BY ds.createdAt DESC LIMIT 1")
    Optional<DriverSubscription> findMostRecentSubscription(@Param("driver") Driver driver);

    /**
     * Check if driver has ever subscribed.
     * 
     * @param driver the driver entity
     * @return true if driver has at least one subscription
     */
    boolean existsByDriver(Driver driver);

    /**
     * Count total subscriptions for a driver.
     * 
     * @param driver the driver entity
     * @return total subscription count
     */
    long countByDriver(Driver driver);
}