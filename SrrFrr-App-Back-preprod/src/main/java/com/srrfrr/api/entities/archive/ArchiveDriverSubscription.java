package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.*;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "driver_subscription", schema = "archive")
public class ArchiveDriverSubscription {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "driver_id", nullable = true)
    private UUID driverId;

    @Column(name = "subscription_plan_id", nullable = true)
    private UUID subscriptionPlanId;

    @Column(name = "start_date", nullable = true)
    private LocalDateTime startDate;

    @Column(name = "end_date", nullable = true)
    private LocalDateTime endDate;

    @Column(name = "rides_used", nullable = true)
    private int ridesUsed;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = true)
    private SubscriptionStatus status;

    @Column(name = "created_at", nullable = true)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = true)
    private LocalDateTime updatedAt;



    public static ArchiveDriverSubscription fromMain(DriverSubscription subscription) {
        return ArchiveDriverSubscription.builder()
                .id(subscription.getId())
                .driverId(subscription.getDriver().getId())
                .subscriptionPlanId(subscription.getSubscriptionPlan().getId())
                .startDate(subscription.getStartDate())
                .endDate(subscription.getEndDate())
                .ridesUsed(subscription.getRidesUsed())
                .status(subscription.getStatus())
                .createdAt(subscription.getCreatedAt())
                .updatedAt(subscription.getUpdatedAt())
                
                .build();
    }
}
