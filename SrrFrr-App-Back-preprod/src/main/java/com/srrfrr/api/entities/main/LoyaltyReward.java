package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "loyalty_rewards", schema = "app_mobile")
public class LoyaltyReward {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "label_ar")
    @NotBlank(message = "Label (Arabic) must not be blank.")
    private String labelAR;

    @Column(nullable = false, name = "label_fr")
    @NotBlank(message = "Label (French) must not be blank.")
    private String labelFR;

    @Column(nullable = false, name = "label_en")
    @NotBlank(message = "Label (English) must not be blank.")
    private String labelEN;
}
