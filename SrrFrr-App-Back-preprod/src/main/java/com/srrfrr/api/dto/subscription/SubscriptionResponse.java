package com.srrfrr.api.dto.subscription;

import com.srrfrr.api.enums.SubscriptionStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class SubscriptionResponse {
    private UUID subscriptionId;
    private UUID driverId;
    private String planType;
    private double price;
    private List<String> descriptions;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private int ridesUsed;
    private int maxRides; // 0 = illimité
    private SubscriptionStatus status;
    private String message;
}
