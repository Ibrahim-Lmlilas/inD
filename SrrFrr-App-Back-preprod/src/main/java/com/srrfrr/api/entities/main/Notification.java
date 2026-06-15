package com.srrfrr.api.entities.main;

import com.srrfrr.api.enums.NotificationType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Entity
@Table(name = "notification", schema = "app_mobile")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, unique = true)
    private UUID id;

    @Column(nullable = false, updatable = false, name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @NotBlank(message = "Content (Arabic) cannot be null")
    @Column(nullable = false, name = "content_ar")
    private String contentAR;

    @NotBlank(message = "Content (French) cannot be null")
    @Column(nullable = false, name = "content_fr")
    private String contentFR;

    @NotBlank(message = "Content (English) cannot be null")
    @Column(nullable = false, name = "content_en")
    private String contentEN;

    @NotBlank(message = "Title (Arabic) cannot be null")
    @Column(nullable = false, name = "title_ar")
    private String titleAR;

    @NotBlank(message = "Title (French) cannot be null")
    @Column(nullable = false, name = "title_fr")
    private String titleFR;

    @NotBlank(message = "Title (English) cannot be null")
    @Column(nullable = false, name = "title_en")
    private String titleEN;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "type")
    private NotificationType type;

    @NotBlank(message = "Status cannot be null")
    @Column(nullable = false, name = "status")
    private String status; // "UNREAD" or "READ"

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "receiver_id", referencedColumnName = "id", nullable = false)
    private Passenger receiver;

    /**
     * Get the category prefix for this notification (DRIVER, PASSENGER, ACCOUNT).
     */
    public String getCategory() {
        return type != null ? type.getCategory() : null;
    }
}