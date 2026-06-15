package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.ChatMessage;
import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.enums.Chat.MessageType;
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
@Table(name = "chat_messages", schema = "archive")
public class ArchiveChatMessage {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "channel_id")
    private UUID channelId;

    @Column(name = "sender_id")
    private UUID senderId;

    @Enumerated(EnumType.STRING)
    @Column(name = "message_type")
    private MessageType messageType;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING) 
    @Column(name = "status")
    private MessageStatus status;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    public static ArchiveChatMessage fromMain(ChatMessage message) {
        return ArchiveChatMessage.builder()
                .id(message.getId())
                .channelId(message.getChannel().getId())
                .senderId(message.getSenderId())
                .messageType(message.getMessageType())
                .content(message.getContent())
                .status(message.getStatus())
                .sentAt(message.getSentAt())
                .deliveredAt(message.getDeliveredAt())
                .readAt(message.getReadAt())
                .build();
    }
}