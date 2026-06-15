package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.enums.user.Status;
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
@Table(name = "passenger", schema = "archive")
public class ArchivePassenger {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "password")
    private String password;

    @Column(name = "profile_picture")
    private String profilePicture;

    @Column(name = "loyalty_points")
    private Integer points;

    @Enumerated(EnumType.STRING)
    @Column(name = "interface_type")
    private InterfaceType interfaceType;

    @Column(name = "terms_accepted")
    private Boolean termsAccepted;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private GenderLabel gender;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private Status status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "total_rides")
    private Integer totalRides;

    @Column(name = "rating")
    private Double rating;

    public static ArchivePassenger fromMain(Passenger passenger) {
        return ArchivePassenger.builder()
                .id(passenger.getId())
                .firstName(passenger.getFirstName())
                .lastName(passenger.getLastName())
                .phoneNumber(passenger.getPhoneNumber())
                .password(passenger.getPassword())
                .profilePicture(passenger.getProfilePicture())
                .points(passenger.getPoints())
                .interfaceType(passenger.getInterfaceType())
                .termsAccepted(passenger.isTermsAccepted())
                .gender(passenger.getGender())
                .status(passenger.getStatus())
                .createdAt(passenger.getCreatedAt())
                .updatedAt(passenger.getUpdatedAt())
                .totalRides(passenger.getTotalRides())
                .rating(passenger.getRating())
                .build();
    }
}