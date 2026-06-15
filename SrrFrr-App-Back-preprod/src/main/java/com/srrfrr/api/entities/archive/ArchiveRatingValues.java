package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.RatingValues;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "rating_values", schema = "archive")
public class ArchiveRatingValues {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "rating_level")
    private int ratingLevel;

    @Column(name = "label_ar")
    private String labelAR;

    @Column(name = "label_fr")
    private String labelFR;

    @Column(name = "label_en")
    private String labelEN;

    @Column(name = "order_value")
    private String order;

    public static ArchiveRatingValues fromMain(RatingValues values) {
        return ArchiveRatingValues.builder()
                .id(values.getId())
                .ratingLevel(values.getRatingLevel())
                .labelAR(values.getLabelAR())
                .labelFR(values.getLabelFR())
                .labelEN(values.getLabelEN())
                .order(values.getOrder())
                .build();
    }
}