package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import com.srrfrr.api.enums.Reclamation.CategoryReclamation;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "reclamation", schema = "app_mobile")
public class Reclamation {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, updatable = false, name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @NotBlank(message = "Content cannot be null")
    @Size(min = 10, max = 500, message = "Content must be between 10 and 500 characters")
    @Column(nullable = false, name = "content")
    private String content;

    @NotNull(message = "Category cannot be null")
    @Column(nullable = false, name = "category")
    @Enumerated(EnumType.STRING)
    private CategoryReclamation category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id", referencedColumnName = "id", nullable = false)
    private Passenger passenger;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", referencedColumnName = "id")
    private Ride ride;
}