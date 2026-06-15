package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.Wallet;
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
@Table(name = "wallet", schema = "archive")
public class ArchiveWallet {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "driver_id", nullable = true)
    private UUID driverId;

    @Column(name = "balance", nullable = true)
    private double balance;

    @Column(name = "created_at", nullable = true)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = true)
    private LocalDateTime updatedAt;

    public static ArchiveWallet fromMain(Wallet wallet) {
        return ArchiveWallet.builder()
                .id(wallet.getId())
                .driverId(wallet.getDriver().getId())
                .balance(wallet.getBalance())
                .createdAt(wallet.getCreatedAt())
                .updatedAt(wallet.getUpdatedAt())
                .build();
    }
}