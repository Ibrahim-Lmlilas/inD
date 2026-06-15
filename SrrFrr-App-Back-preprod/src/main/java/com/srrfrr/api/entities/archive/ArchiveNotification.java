package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Notification;
import com.srrfrr.api.enums.NotificationType;
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
@Table(name = "notification", schema = "archive")
public class ArchiveNotification {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "content")
    private String content;

    @Column(name = "title")
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "type")
    private NotificationType type;

    @Column(name = "status")
    private String status;

    @Column(name = "receiver_id")
    private UUID receiverId;

    public static ArchiveNotification fromMain(Notification notification) {
        return ArchiveNotification.builder()
                .id(notification.getId())
                .createdAt(notification.getCreatedAt())
                .content(notification.getContentEN()) // Assuming we want to archive the English content
                .title(notification.getTitleEN()) // Assuming we want to archive the English title
                .type(notification.getType())
                .status(notification.getStatus())
                .receiverId(notification.getReceiver().getId())
                .build();
    }
}