package com.srrfrr.api.entities.main;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.srrfrr.api.annotations.ValidFirstName;
import com.srrfrr.api.annotations.ValidLastName;
import com.srrfrr.api.annotations.ValidPassword;
import com.srrfrr.api.annotations.ValidPhoneNumber;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.enums.user.Language;
import com.srrfrr.api.enums.user.Status;

import jakarta.persistence.*;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "passenger", schema = "app_mobile")
public class Passenger implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", unique = true, nullable = false)
    protected UUID id;

    @ValidFirstName
    @Column(name = "first_name", nullable = false)
    protected String firstName;

    @ValidLastName
    @Column(name = "last_name", nullable = false)
    protected String lastName;

    @ValidPhoneNumber
    @Column(name = "phone_number", nullable = false, unique = true)
    protected String phoneNumber;

    @ValidPassword
    @Column(name = "password", nullable = false)
    @JsonIgnore
    protected String password;

    @Column(name = "profile_picture")
    protected String profilePicture;

    @Column(name = "loyalty_points")
    protected int points;

    @NotNull(message = "Interface type is required")
    @Column(name = "interface_type", nullable = false)
    @Enumerated(EnumType.STRING)
    @JsonIgnore
    protected InterfaceType interfaceType;

    @NotNull(message = "Language is required")
    @Column(name = "language", nullable = false)
    @Enumerated(EnumType.STRING)
    protected Language language = Language.EN;

    @NotNull(message = "Terms Accepted is required")
    @Column(name = "terms_accepted", nullable = false)
    @AssertTrue(message = "You must accept the terms and conditions")
    @JsonIgnore
    protected boolean termsAccepted;

    @NotNull(message = "Gender is required")
    @Column(name = "gender", nullable = false)
    @Enumerated(EnumType.STRING)
    @JsonIgnore
    protected GenderLabel gender;

    @NotNull(message = "Status is required")
    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    @JsonIgnore
    protected Status status = Status.ACTIVE;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    @JsonIgnore
    protected LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    @JsonIgnore
    protected LocalDateTime updatedAt;

    @OneToOne(mappedBy = "passenger")
    @JsonIgnore // Prevent circular reference
    protected Driver driverProfile;

    @Column(name = "total_rides", nullable = false)
    @JsonIgnore
    protected int totalRides = 0;

    @Column(name = "rating", nullable = false)
    protected double rating = 0.0;

    @OneToMany(mappedBy = "sender", fetch = FetchType.LAZY)
    @JsonIgnore
    protected List<Rating> givenRatings;

    @OneToMany(mappedBy = "receiver", fetch = FetchType.LAZY)
    @JsonIgnore
    protected List<Rating> receivedRatings;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getUsername() {
        return phoneNumber;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    public int getPassengerOnlyRides() {
        return totalRides;
    }

    public int getDriverOnlyRides() {
        return driverProfile != null ? driverProfile.getTotalRides() : 0;
    }

    public int getTotalRides() {
        return getPassengerOnlyRides() + getDriverOnlyRides();
    }

    public void addLoyaltyPoints(final int earned) {
        this.points += earned;
    }

}