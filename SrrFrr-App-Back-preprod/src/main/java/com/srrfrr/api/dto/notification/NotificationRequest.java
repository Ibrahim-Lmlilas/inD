package com.srrfrr.api.dto.notification;

import com.srrfrr.api.enums.NotificationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationRequest {

    @NotNull(message = "Receiver ID is required")
    private UUID receiverId;

    @NotBlank(message = "Title (Arabic) is required")
    private String titleAR;

    @NotBlank(message = "Title (French) is required")
    private String titleFR;

    @NotBlank(message = "Title (English) is required")
    private String titleEN;

    @NotBlank(message = "Content (Arabic) is required")
    private String contentAR;

    @NotBlank(message = "Content (French) is required")
    private String contentFR;

    @NotBlank(message = "Content (English) is required")
    private String contentEN;

    @NotNull(message = "Notification type is required")
    private NotificationType type;

    private String status = "UNREAD";

    /**
     * Factory method: Create notification with default titles/content from enum.
     */
    public static NotificationRequest withDefaults(NotificationType type, UUID receiverId) {
        NotificationRequest request = new NotificationRequest();
        request.setReceiverId(receiverId);
        request.setType(type);
        request.setStatus("UNREAD");

        // Set default translations (you'll need to add these to NotificationType enum)
        request.setTitleAR(type.getDefaultTitleAR());
        request.setTitleFR(type.getDefaultTitleFR());
        request.setTitleEN(type.getDefaultTitleEN());
        request.setContentAR(type.getDefaultContentAR());
        request.setContentFR(type.getDefaultContentFR());
        request.setContentEN(type.getDefaultContentEN());

        return request;
    }

    /**
     * Factory method: Create notification with custom content in all languages.
     */
    public static NotificationRequest withCustomContent(
            NotificationType type,
            UUID receiverId,
            String contentAR,
            String contentFR,
            String contentEN) {
        NotificationRequest request = new NotificationRequest();
        request.setReceiverId(receiverId);
        request.setType(type);
        request.setStatus("UNREAD");

        // Use default titles
        request.setTitleAR(type.getDefaultTitleAR());
        request.setTitleFR(type.getDefaultTitleFR());
        request.setTitleEN(type.getDefaultTitleEN());

        // Custom content
        request.setContentAR(contentAR);
        request.setContentFR(contentFR);
        request.setContentEN(contentEN);

        return request;
    }
}