package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "wallet", schema = "app_mobile")
public class Wallet {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false, unique = true)
    private Driver driver;

    @Builder.Default
    @Column(name = "balance", nullable = false)
    private double balance = 1000;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "wallet", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @Builder.Default
    private List<WalletTransaction> transactions = new ArrayList<>();

    // Utility methods remain the same
    public void credit(final double amount) {
        this.balance += amount;
    }

    public void debit(final double amount) {
        if (this.balance < amount) {
            throw new IllegalArgumentException("Insufficient wallet balance");
        }
        this.balance -= amount;
    }
}
