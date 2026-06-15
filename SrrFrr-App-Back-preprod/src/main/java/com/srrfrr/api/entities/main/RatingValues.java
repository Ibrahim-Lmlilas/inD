package com.srrfrr.api.entities.main;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Column;
import jakarta.persistence.Table;
import jakarta.persistence.GenerationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Entity
@Data
@Table(name = "rating_values", schema = "app_mobile")
public class RatingValues {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, unique = true)
    private UUID id;

    @Column(nullable = false, name = "rating_level")
    @NotNull(message = "Rating level is required.")
    private int ratingLevel;

    @Column(nullable = false, name = "label_ar")
    @NotBlank(message = "Label (Arabic) must not be blank.")
    private String labelAR;

    @Column(nullable = false, name = "label_fr")
    @NotBlank(message = "Label (French) must not be blank.")
    private String labelFR;

    @Column(nullable = false, name = "label_en")
    @NotBlank(message = "Label (English) must not be blank.")
    private String labelEN;

    @Column(nullable = false, name = "order_value")
    @NotBlank(message = "Order must not be blank.")
    private String order;
}