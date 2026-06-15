package com.srrfrr.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LastKnownLocationDTO {
    private Double latitude;
    private Double longitude;
    private Long timestamp;

    // Distance selon le statut du ride
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private Double distanceToPickup;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String distanceToPickupKm;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private Double distanceToDestination;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String distanceToDestinationKm;
}

