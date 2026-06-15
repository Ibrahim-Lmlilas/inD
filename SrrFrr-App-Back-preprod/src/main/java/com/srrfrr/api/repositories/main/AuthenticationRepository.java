package com.srrfrr.api.repositories.main;

import com.srrfrr.api.entities.main.Authentication;
import com.srrfrr.api.entities.main.Passenger;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AuthenticationRepository extends JpaRepository<Authentication, UUID> {
    Optional<Authentication> findByPassenger(Passenger passenger);

    Optional<Authentication> findByRefreshToken(String refreshToken);

    Optional<Authentication> findByPassengerId(UUID passengerId);
}