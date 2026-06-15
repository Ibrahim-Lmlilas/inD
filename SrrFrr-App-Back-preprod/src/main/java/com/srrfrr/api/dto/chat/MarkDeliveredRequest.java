package com.srrfrr.api.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * DTO for marking messages as delivered.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MarkDeliveredRequest {
	private UUID userId;
	private java.util.List<UUID> messageIds;
}