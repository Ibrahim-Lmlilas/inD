package com.srrfrr.api.dto.driver;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DriverLocation {
    private UUID driverId;
    private double latitude;
    private double longitude;
    private long timestamp;

    /**
     * Vérifie si la position est récente (moins de X minutes)
     */
    public boolean isRecent(int maxAgeMinutes) {
        long currentTime = System.currentTimeMillis();
        long ageInMinutes = (currentTime - timestamp) / (1000 * 60);
        return ageInMinutes <= maxAgeMinutes;
    }

    /**
     * Retourne l'âge de la position en minutes
     */
    public long getAgeInMinutes() {
        long currentTime = System.currentTimeMillis();
        return (currentTime - timestamp) / (1000 * 60);
    }
}