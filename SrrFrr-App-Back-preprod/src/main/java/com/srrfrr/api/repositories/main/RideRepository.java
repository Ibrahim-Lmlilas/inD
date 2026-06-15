package com.srrfrr.api.repositories.main;

import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Ride.RideStatus;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for Ride entity operations.
 * Extends JpaSpecificationExecutor for dynamic filtering.
 */
@Repository
public interface RideRepository extends JpaRepository<Ride, UUID>, JpaSpecificationExecutor<Ride> {

    /**
     * Find all rides for a passenger (non-paginated).
     */
    List<Ride> findByPassengerIdOrderByCreatedAtDesc(UUID passengerId);

    /**
     * Find all rides for a driver (non-paginated).
     */
    List<Ride> findByDriverIdOrderByCreatedAtDesc(UUID driverId);

    /**
     * Find ride with passenger eagerly loaded.
     */
    @Query("SELECT r FROM Ride r LEFT JOIN FETCH r.passenger WHERE r.id = :rideId")
    Optional<Ride> findByIdWithPassenger(@Param("rideId") UUID rideId);

    /**
     * Find rides by status.
     */
    List<Ride> findByStatus(RideStatus status);

    /**
     * Find active ride for passenger (ACCEPTED or STARTED).
     * Excludes rides for deleted passengers using EXISTS subquery.
     */
    @Query("SELECT r FROM Ride r " +
	    "WHERE r.passengerId = :passengerId " +
	    "AND r.status IN ('ACCEPTED', 'STARTED') " +
	    "AND EXISTS (SELECT 1 FROM Passenger p WHERE p.id = r.passengerId AND p.status != 'DELETED') " +
	    "ORDER BY r.createdAt DESC LIMIT 1")
    Optional<Ride> findActiveRideForPassenger(@Param("passengerId") UUID passengerId);

    /**
     * Find active ride for driver (ACCEPTED or STARTED).
     * Excludes rides for deleted drivers using EXISTS subquery.
     */
    @Query("SELECT r FROM Ride r " +
	    "WHERE r.driverId = :driverId " +
	    "AND r.status IN ('ACCEPTED', 'STARTED') " +
	    "AND EXISTS (SELECT 1 FROM Driver d JOIN d.passenger p " +
	    "            WHERE d.id = r.driverId AND p.status != 'DELETED') " +
	    "ORDER BY r.createdAt DESC LIMIT 1")
    Optional<Ride> findActiveRideForDriver(@Param("driverId") UUID driverId);

    /**
     * Count total rides for passenger.
     */
    long countByPassengerId(UUID passengerId);

    /**
     * Count total rides for driver.
     */
    long countByDriverId(UUID driverId);

    /**
     * Count completed rides for passenger.
     */
    @Query("SELECT COUNT(r) FROM Ride r WHERE r.passengerId = :passengerId AND r.status = 'COMPLETED'")
    long countCompletedRidesByPassenger(@Param("passengerId") UUID passengerId);

    /**
     * Count completed rides for driver.
     */
    @Query("SELECT COUNT(r) FROM Ride r WHERE r.driverId = :driverId AND r.status = 'COMPLETED'")
    long countCompletedRidesByDriver(@Param("driverId") UUID driverId);
}