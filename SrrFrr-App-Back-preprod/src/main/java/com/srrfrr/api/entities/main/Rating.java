package com.srrfrr.api.entities.main;

import com.srrfrr.api.enums.RatingType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "rating", schema = "app_mobile")
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, unique = true)
    private UUID id;

    @CreationTimestamp
    @Column(nullable = false, updatable = false, name = "created_at")
    private LocalDateTime createdAt;

    @NotNull(message = "Ride cannot be null.")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", referencedColumnName = "id", nullable = false)
    private Ride ride;

    @NotNull(message = "Sender cannot be null.")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", referencedColumnName = "id", nullable = false)
    private Passenger sender;

    @NotNull(message = "Receiver cannot be null.")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id", referencedColumnName = "id", nullable = false)
    private Passenger receiver;

    @NotNull(message = "Rating value cannot be null.")
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "rating_values_id", referencedColumnName = "id", nullable = false)
    private RatingValues ratingValues;

    // Indique le sens de la note : PASSENGER_TO_DRIVER ou DRIVER_TO_PASSENGER
    @Enumerated(EnumType.STRING)
    @Column(name = "rating_type", nullable = false)
    private RatingType ratingType;

}
