package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Reclamation;
import com.srrfrr.api.enums.Reclamation.CategoryReclamation;
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
@Table(name = "reclamation", schema = "archive")
public class ArchiveReclamation {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "content")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "category")
    private CategoryReclamation category;

    @Column(name = "passenger_id")
    private UUID passengerId;

    @Column(name = "ride_id")
    private UUID rideId;

    public static ArchiveReclamation fromMain(Reclamation reclamation) {
        return ArchiveReclamation.builder()
                .id(reclamation.getId())
                .createdAt(reclamation.getCreatedAt())
                .content(reclamation.getContent())
                .category(reclamation.getCategory())
                .passengerId(reclamation.getPassenger() != null ? 
                    reclamation.getPassenger().getId() : null)
                .rideId(reclamation.getRide() != null ? 
                    reclamation.getRide().getId() : null)
                .build();
    }
}