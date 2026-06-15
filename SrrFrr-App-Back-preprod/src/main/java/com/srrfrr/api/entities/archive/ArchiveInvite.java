package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.*;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "invite", schema = "archive")
public class ArchiveInvite {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "invite_phone_number")
    private String inviteePhoneNumber;

    @Column(name = "passenger_id", nullable = true)
    private UUID passengerId;

    @Column(name = "invited_at", nullable = true)
    private LocalDateTime invitedAt;

    public static ArchiveInvite fromMain(Invite invite) {
        return ArchiveInvite.builder()
                .id(invite.getId())
                .inviteePhoneNumber(invite.getInviteePhoneNumber())
                .passengerId(invite.getInviter().getId())
                .invitedAt(invite.getInvitedAt())

                .build();
    }
}
