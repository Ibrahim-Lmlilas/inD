package com.srrfrr.api.repositories.main.loyalty;

import com.srrfrr.api.entities.main.LoyaltyReward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface LoyaltyRewardRepository extends JpaRepository<LoyaltyReward, UUID> {

}
