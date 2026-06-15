package com.srrfrr.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RatingResponse {
    private UUID id;
    private LocalDateTime createdAt;
    private UUID rideId;
    private UUID senderId;
    private String senderName;
    private UUID receiverId;
    private String receiverName;
    private String ratingType;
}
