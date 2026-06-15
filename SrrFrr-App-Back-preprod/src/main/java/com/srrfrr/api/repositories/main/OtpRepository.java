package com.srrfrr.api.repositories.main;

import com.srrfrr.api.entities.main.Otp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;
@Repository
public interface OtpRepository extends JpaRepository<Otp, UUID> {
    Optional<Otp> findByPhoneNumber(String phoneNumber);

    void deleteByPhoneNumber(String phoneNumber);


}
