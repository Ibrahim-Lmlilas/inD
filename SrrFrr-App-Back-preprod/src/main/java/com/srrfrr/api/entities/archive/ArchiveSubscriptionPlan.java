package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.SubscriptionPlan;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "subscription_plan", schema = "archive")
public class ArchiveSubscriptionPlan {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "type")
    private String type;

    @Column(name = "price")
    private double price;

    @ElementCollection
    @CollectionTable(
            name = "subscription_plan_description", 
            schema = "archive",
            joinColumns = @JoinColumn(name = "plan_id")
    )
    @Column(name = "description")
    @Builder.Default
    private List<String> descriptions = new ArrayList<>();

    public static ArchiveSubscriptionPlan fromMain(SubscriptionPlan plan) {
        return ArchiveSubscriptionPlan.builder()
                .id(plan.getId())
                .type(plan.getType())
                .price(plan.getPrice())
                .descriptions(plan.getDescriptions() != null ? 
                    new ArrayList<>(plan.getDescriptions()) : new ArrayList<>())
                .build();
    }
}