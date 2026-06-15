package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.Wallet.TransactionStatus;
import com.srrfrr.api.enums.Wallet.TransactionType;
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
@Table(name = "wallet_transactions", schema = "archive")
public class ArchiveWalletTransaction {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "wallet_id", nullable = true)
    private UUID walletId;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = true)
    private TransactionType type;

    @Column(name = "amount", nullable = true)
    private double amount;

    @Column(name = "created_at", nullable = true)
    private LocalDateTime createdAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private TransactionStatus status;



    public static ArchiveWalletTransaction fromMain(WalletTransaction transaction) {
        return ArchiveWalletTransaction.builder()
                .id(transaction.getId())
                .walletId(transaction.getWallet().getId())
                .type(transaction.getType())
                .amount(transaction.getAmount())
                .createdAt(transaction.getCreatedAt())
                .status(transaction.getStatus())
                
                .build();
    }
}