package com.srrfrr.api.repositories.main.user;

import com.srrfrr.api.entities.main.Passenger;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PassengerRepository extends JpaRepository<Passenger, UUID> {
    @Query("SELECT p FROM Passenger p WHERE p.phoneNumber = :phoneNumber AND p.status != 'DELETED'")
    Optional<Passenger> findByPhoneNumber(@Param("phoneNumber") String phoneNumber);

    @Query("SELECT p FROM Passenger p WHERE p.id = :id AND p.status != 'DELETED'")
    Optional<Passenger> findActiveById(@Param("id") UUID id);

    @Query("SELECT CASE WHEN COUNT(p) > 0 THEN true ELSE false END " +
        "FROM Passenger p WHERE p.phoneNumber = :phoneNumber AND p.status != 'DELETED'")
    boolean existsByPhoneNumber(@Param("phoneNumber") String phoneNumber);

    @Query("SELECT p FROM Passenger p LEFT JOIN FETCH p.driverProfile WHERE p.id = :id")
    Optional<Passenger> findWithDriver(UUID id);

    
}