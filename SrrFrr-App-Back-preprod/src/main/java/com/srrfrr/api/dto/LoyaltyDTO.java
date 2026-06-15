package com.srrfrr.api.dto;
import lombok.*;

import java.util.List;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoyaltyDTO {
    private int points;
    private List<LoyaltyTransactionDTO> transactions;
}

