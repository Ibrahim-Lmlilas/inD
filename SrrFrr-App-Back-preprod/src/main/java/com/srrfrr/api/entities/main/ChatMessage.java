package com.srrfrr.api.entities.main;

import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.enums.Chat.MessageType;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chat_messages", schema = "app_mobile")

public class ChatMessage {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "channel_id", nullable = false)
    private ChatChannel channel;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Enumerated(EnumType.STRING)
    @Column(name = "message_type", nullable = false)
    private MessageType messageType;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @OneToOne(mappedBy = "message", cascade = CascadeType.ALL)
    private MessageFile file;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private MessageStatus status = MessageStatus.SENT;

    @Column(name = "sent_at", nullable = false, updatable = false)
    private LocalDateTime sentAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    public static ChatMessage createSystemMessage(final ChatChannel channel, final String content) {
        return ChatMessage.builder()
                .channel(channel)
                .senderId(channel.getDriverId())
                .status(MessageStatus.SENT)
                .messageType(MessageType.SYSTEM)
                .status(MessageStatus.SENT)
                .content(content)
                .sentAt(LocalDateTime.now())
                .build();
    }

    public boolean isSystemMessage() {
        return this.messageType == MessageType.SYSTEM;
    }

}