package com.srrfrr.api.entities.main;

import java.time.LocalDateTime;
import java.util.UUID;

import com.srrfrr.api.annotations.ValidPhoneNumber;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "invite", schema = "app_mobile")
public class Invite {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(unique = true, nullable = false)
    private UUID id;

    @ValidPhoneNumber
    @Column(name = "invite_phone_number")
    private String inviteePhoneNumber;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "passenger_id")
    private Passenger inviter;

    @Column(name = "invited_at", nullable = false)
    private LocalDateTime invitedAt = LocalDateTime.now();

    public Invite(final String invitePhoneNumber, final Passenger inviter) {
        this.inviteePhoneNumber = invitePhoneNumber;
        this.inviter = inviter;
    }

}