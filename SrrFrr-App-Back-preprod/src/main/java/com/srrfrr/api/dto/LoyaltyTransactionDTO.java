package com.srrfrr.api.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LoyaltyTransactionDTO {
    private UUID id;
    private String type;
    private int points;
    private LocalDateTime createdAt;
}
