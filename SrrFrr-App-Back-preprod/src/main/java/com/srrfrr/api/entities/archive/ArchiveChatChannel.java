package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.ChatChannel;
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
@Table(name = "chat_channels", schema = "archive")
public class ArchiveChatChannel {

    @Id
    @Column(name = "id", unique = true)
    private UUID id;

    @Column(name = "ride_id")
    private UUID rideId;

    @Column(name = "driver_id")
    private UUID driverId;

    @Column(name = "passenger_id")
    private UUID passengerId;

    @Column(name = "is_active")
    private Boolean isActive;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "last_message_at")
    private LocalDateTime lastMessageAt;

    public static ArchiveChatChannel fromMain(ChatChannel channel) {
        return ArchiveChatChannel.builder()
                .id(channel.getId())
                .rideId(channel.getRide().getId())
                .driverId(channel.getDriverId())
                .passengerId(channel.getPassengerId())
                .isActive(channel.isActive())
                .createdAt(channel.getCreatedAt())
                .updatedAt(channel.getUpdatedAt())
                .lastMessageAt(channel.getLastMessageAt())
                .build();
    }
}