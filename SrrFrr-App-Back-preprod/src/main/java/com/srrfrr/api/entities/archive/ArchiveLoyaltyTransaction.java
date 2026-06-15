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
@Table(name = "loyalty_transactions", schema = "archive")
public class ArchiveLoyaltyTransaction {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "passenger_id", nullable = true)
    private UUID passengerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = true)
    private LoyaltyTransactionType type;

    @Column(name = "points", nullable = true)
    private int points;

    @Column(name = "created_at", nullable = true)
    private LocalDateTime createdAt;



    public static ArchiveLoyaltyTransaction fromMain(LoyaltyTransaction transaction) {
        return ArchiveLoyaltyTransaction.builder()
                .id(transaction.getId())
                .passengerId(transaction.getPassenger().getId())
                .type(transaction.getType())
                .points(transaction.getPoints())
                .createdAt(transaction.getCreatedAt())
                
                .build();
    }
}
