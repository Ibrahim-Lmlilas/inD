package com.srrfrr.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
public class RatingValuesResponse {
    private int ratingLevel;
    private List<RatingOption> options;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class RatingOption {
        private UUID id;
        private String labelAR;
        private String labelFR;
        private String labelEN;
    }
}