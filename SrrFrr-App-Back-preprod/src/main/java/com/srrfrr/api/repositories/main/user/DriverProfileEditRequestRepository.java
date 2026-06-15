package com.srrfrr.api.repositories.main.user;

import com.srrfrr.api.entities.main.DriverProfileEditRequest;
import com.srrfrr.api.enums.user.Approval;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DriverProfileEditRequestRepository extends JpaRepository<DriverProfileEditRequest, UUID> {
    boolean existsByDriver_IdAndStatus(UUID driverId, Approval status);

    List<DriverProfileEditRequest> findByStatusOrderByCreatedAtDesc(Approval status);

    List<DriverProfileEditRequest> findAllByDriver_IdOrderByCreatedAtDesc(UUID driverId);
}
