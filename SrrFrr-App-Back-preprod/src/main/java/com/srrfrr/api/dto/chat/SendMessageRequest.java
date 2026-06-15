package com.srrfrr.api.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

import com.srrfrr.api.enums.Chat.MessageType;

/**
 * DTO for sending messages via REST API.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SendMessageRequest {
	private UUID senderId;
	private String content;
	private MessageType messageType;
	private String fileUrl;
	private Long fileSize;
}