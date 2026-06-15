package com.srrfrr.api.repositories.archive;

import com.srrfrr.api.entities.archive.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ArchiveMessageFileRepository extends JpaRepository<ArchiveMessageFile, UUID> {
}