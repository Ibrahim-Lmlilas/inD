package com.srrfrr.api.repositories.main.user;

import com.srrfrr.api.entities.main.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository for Driver entity operations.
 */
@Repository
public interface DriverRepository extends JpaRepository<Driver, UUID> {

	/**
	 * Find active driver by ID (excluding deleted passengers)
	 * 
	 * @param passengerId the passenger ID
	 * @return optional driver
	 */
	@Query("SELECT d FROM Driver d JOIN d.passenger p " +
			"WHERE d.id = :id AND p.status != 'DELETED'")
	Optional<Driver> findActiveDriverById(@Param("id") UUID id);

	@Query("""
        SELECT d FROM Driver d
        LEFT JOIN FETCH d.passenger p
        LEFT JOIN FETCH d.activeSubscription sub
        LEFT JOIN FETCH sub.subscriptionPlan plan
        LEFT JOIN FETCH plan.descriptions
        WHERE d.id = :driverId
    """)
    Optional<Driver> findDriverWithSubscriptionDetails(@Param("driverId") UUID driverId);

	/**
	 * Find driver by passenger ID (excluding deleted passengers)
	 */
	@Query("SELECT d FROM Driver d JOIN d.passenger p " +
			"WHERE p.id = :passengerId AND p.status != 'DELETED'")
	Optional<Driver> findByPassengerId(@Param("passengerId") UUID passengerId);

	/**
	 * Check if driver exists by passenger ID (excluding deleted)
	 * 
	 * @param passengerId the passenger ID
	 * @return true if driver exists
	 */
	@Query("SELECT CASE WHEN COUNT(d) > 0 THEN true ELSE false END " +
			"FROM Driver d JOIN d.passenger p " +
			"WHERE p.id = :passengerId AND p.status != 'DELETED'")
	boolean existsByPassengerId(@Param("passengerId") UUID passengerId);
}