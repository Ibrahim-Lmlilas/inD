package com.srrfrr.api.dto;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WalletTransactionDTO {
    private UUID id;
    private String transactionType;
    private double amount;
    private LocalDateTime createdAt;
}
