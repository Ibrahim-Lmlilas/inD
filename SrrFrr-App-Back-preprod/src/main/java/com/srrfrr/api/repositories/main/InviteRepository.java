package com.srrfrr.api.repositories.main;

import java.util.List;
import java.util.UUID;

import com.srrfrr.api.entities.main.Invite;
import com.srrfrr.api.entities.main.Passenger;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InviteRepository extends JpaRepository<Invite, UUID> {

    List<Invite> findAllByInviteePhoneNumber(String phoneNumber);

    List<Invite> findAllByInviter(Passenger inviter);
}
