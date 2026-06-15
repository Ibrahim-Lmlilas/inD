package com.srrfrr.api.dto;

import lombok.*;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WalletDTO {
    private double wallet;
    private UUID driverId;
    private List<WalletTransactionDTO> transactions;
}
