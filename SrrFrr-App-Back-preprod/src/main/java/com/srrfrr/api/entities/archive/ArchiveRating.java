package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.*;
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
@Table(name = "rating", schema = "archive")
public class ArchiveRating {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "created_at", nullable = true)
    private LocalDateTime createdAt;

    @Column(name = "ride_id", nullable = true)
    private UUID rideId;

    @Column(name = "sender_id", nullable = true)
    private UUID senderId;

    @Column(name = "receiver_id", nullable = true)
    private UUID receiverId;

    @Column(name = "rating_values_id", nullable = true)
    private UUID ratingValuesId;

    @Enumerated(EnumType.STRING)
    @Column(name = "rating_type", nullable = true)
    private RatingType ratingType;



    public static ArchiveRating fromMain(Rating rating) {
        return ArchiveRating.builder()
                .id(rating.getId())
                .createdAt(rating.getCreatedAt())
                .rideId(rating.getRide().getId())
                .senderId(rating.getSender().getId())
                .receiverId(rating.getReceiver().getId())
                .ratingValuesId(rating.getRatingValues().getId())
                .ratingType(rating.getRatingType())
                
                .build();
    }
}