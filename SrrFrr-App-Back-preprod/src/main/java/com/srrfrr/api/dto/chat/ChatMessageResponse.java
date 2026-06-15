package com.srrfrr.api.dto.chat;

import com.srrfrr.api.entities.main.ChatMessage;
import com.srrfrr.api.enums.Chat.MessageStatus;
import com.srrfrr.api.enums.Chat.MessageType;

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
public class ChatMessageResponse {
	private UUID id;
	private UUID channelId;
	private UUID senderId;
	private MessageType messageType;
	private String content;
	private String fileUrl;
	private Long fileSize;
	private MessageStatus status;
	private LocalDateTime sentAt;
	private LocalDateTime deliveredAt;
	private LocalDateTime readAt;
	private boolean isSystemMessage;

	public static ChatMessageResponse fromEntity(final ChatMessage message) {
		return ChatMessageResponse.builder()
				.id(message.getId())
				.channelId(message.getChannel().getId())
				.senderId(message.getSenderId())
				.messageType(message.getMessageType())
				.content(message.getContent())
                .fileUrl(message.getFile() != null ? message.getFile().getFileUrl() : null)
                .fileSize(message.getFile() != null ? message.getFile().getFileSize() : null)
				.status(message.getStatus())
				.sentAt(message.getSentAt())
				.deliveredAt(message.getDeliveredAt())
				.readAt(message.getReadAt())
				.isSystemMessage(message.isSystemMessage())
				.build();
	}
}