package com.srrfrr.api.repositories.main;

import com.srrfrr.api.entities.main.Reclamation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReclamationRepository extends JpaRepository<Reclamation, UUID> {
	/**
     * Find all reclamations by passenger ID ordered by creation date descending.
     * Used by archive service to collect all reclamations for a passenger.
     * 
     * @param passengerId the passenger ID
     * @return list of reclamations ordered by creation date desc
     */
    List<Reclamation> findByPassengerIdOrderByCreatedAtDesc(UUID passengerId);
}
