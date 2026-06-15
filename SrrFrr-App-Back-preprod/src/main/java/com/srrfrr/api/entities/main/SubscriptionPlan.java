package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "subscription_plan", schema = "app_mobile")
@Data
public class SubscriptionPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", unique = true, nullable = false)
    protected UUID id;

    @Column(unique = true, nullable = false)
    private String type;
    // "PRO", "PREMIUM", "BASIC"

    @Column(nullable = false)
    private double price;

    // Liste dynamique de descriptions
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "subscription_plan_description", schema = "app_mobile", joinColumns = @JoinColumn(name = "plan_id"))
    @Column(name = "description")
    private List<String> descriptions = new ArrayList<>();
}
