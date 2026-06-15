package com.srrfrr.api.dto.notification;

import com.srrfrr.api.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private UUID id;
    private LocalDateTime createdAt;

    private String titleAR;
    private String titleFR;
    private String titleEN;

    private String contentAR;
    private String contentFR;
    private String contentEN;

    private NotificationType type;
    private String category;
    private String status;
    private UUID receiverId;
}