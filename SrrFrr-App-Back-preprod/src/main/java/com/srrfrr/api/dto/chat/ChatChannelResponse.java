package com.srrfrr.api.dto.chat;

import com.srrfrr.api.entities.main.ChatChannel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatChannelResponse {
	private UUID id;
	private UUID rideId;
	private UUID driverId;
	private UUID passengerId;
	private boolean isActive;
	private LocalDateTime createdAt;
	private LocalDateTime lastMessageAt;
	private ChatMessageResponse lastMessage;
	private int unreadCount;

	public static ChatChannelResponse fromEntity(final ChatChannel channel) {
		return ChatChannelResponse.builder()
				.id(channel.getId())
				.rideId(channel.getRide().getId())
				.driverId(channel.getDriverId())
				.passengerId(channel.getPassengerId())
				.isActive(channel.isActive())
				.createdAt(channel.getCreatedAt())
				.lastMessageAt(channel.getLastMessageAt())
				.build();
	}
}