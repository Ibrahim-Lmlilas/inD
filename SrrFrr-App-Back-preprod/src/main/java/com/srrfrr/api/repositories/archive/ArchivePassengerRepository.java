package com.srrfrr.api.repositories.archive;

import com.srrfrr.api.entities.archive.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Archive repositories - simple interfaces, no complex queries needed.
 * Archive schema has no FK constraints, so operations are straightforward.
 */

@Repository
public interface ArchivePassengerRepository extends JpaRepository<ArchivePassenger, UUID> {
    boolean existsById(UUID id);
}