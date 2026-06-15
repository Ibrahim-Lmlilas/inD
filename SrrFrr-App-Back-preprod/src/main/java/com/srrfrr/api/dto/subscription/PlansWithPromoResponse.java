package com.srrfrr.api.dto.subscription;

import com.srrfrr.api.entities.main.SubscriptionPlan;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class PlansWithPromoResponse {
    private List<SubscriptionPlan> plans;
    private boolean firstTimePromoEligible;
    private Integer promoDurationDays;
    private PromoMessages promoMessage;
    
    @Data
    @Builder
    public static class PromoMessages {
        private String en;
        private String fr;
        private String ar;
    }
}