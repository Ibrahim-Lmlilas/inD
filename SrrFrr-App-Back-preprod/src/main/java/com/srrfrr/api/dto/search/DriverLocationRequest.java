package com.srrfrr.api.dto.search;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DriverLocationRequest {
    private UUID driverId;
    private double longitude;
    private double latitude;
}
