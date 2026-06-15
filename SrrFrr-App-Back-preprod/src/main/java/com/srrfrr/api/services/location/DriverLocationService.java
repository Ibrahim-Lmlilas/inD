package com.srrfrr.api.services.location;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.driver.DriverLocation;
import com.uber.h3core.H3Core;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.Duration;
import java.util.*;
//
//@Service
//@Slf4j
//public class DriverLocationService {
//
//    private final StringRedisTemplate redisTemplate;
//    private final H3Core h3;
//    private static final String KEY_H3 = "drivers:h3";
//    private static final String DRIVER_LAST_H3 = "driver:lastH3:";
//
//    public DriverLocationService(final StringRedisTemplate redisTemplate) throws IOException {
//        this.redisTemplate = redisTemplate;
//        this.h3 = H3Core.newInstance();
//    }
//
//    /**
//     * Met à jour la position du chauffeur dans Redis + index H3 MULTI-RÉSOLUTION
//     */
//    public void updateDriverLocation(final UUID driverId, final double lat, final double lng, final boolean online) {
//        String driverIdStr = driverId.toString();
//        int[] resolutions = { 5, 6, 7 };
//
//        // Supprimer les anciens H3 stockés
//        String lastH3Key = DRIVER_LAST_H3 + driverIdStr;
//        String oldH3List = redisTemplate.opsForValue().get(lastH3Key);
//        if (oldH3List != null) {
//            for (String oldH3 : oldH3List.split(",")) {
//                redisTemplate.opsForSet().remove(KEY_H3 + ":" + oldH3, driverIdStr);
//            }
//        }
//
//        // Ajouter les nouveaux
//        List<String> newH3List = new ArrayList<>();
//        for (int resolution : resolutions) {
//            long h3Index = h3.geoToH3(lat, lng, resolution);
//            redisTemplate.opsForSet().add(KEY_H3 + ":" + h3Index, driverIdStr);
//            newH3List.add(String.valueOf(h3Index));
//        }
//
//        // Stocker la liste des derniers H3 pour ce driver
//        redisTemplate.opsForValue().set(lastH3Key, String.join(",", newH3List));
//    }
//
//    public Set<String> getDriversInH3(long h3Index) {
//        return redisTemplate.opsForSet().members(KEY_H3 + ":" + h3Index);
//    }
//
//    public long getH3Index(double lat, double lng, int resolution) {
//        return h3.geoToH3(lat, lng, resolution);
//    }
//
//    public Set<Long> getH3KRing(long h3Index, int k) {
//        return new HashSet<>(h3.kRing(h3Index, k));
//    }
//}
//
//



@Service
@Slf4j
public class DriverLocationService {

    private final StringRedisTemplate redisTemplate;
    private final H3Core h3;

    private static final String KEY_H3 = "drivers:h3";
    private static final String DRIVER_LAST_H3 = "driver:lastH3:";

    // Nouvelles clés pour stocker la dernière position
    private static final String DRIVER_LAST_LOCATION = "driver:lastLocation:";
    private static final String DRIVER_TRACKING_CLOSED = "driver:trackingClosed:";

    // TTL pour les positions (12 heures)
    private static final long LOCATION_TTL_HOURS = 12;

    public DriverLocationService(final StringRedisTemplate redisTemplate) throws IOException {
        this.redisTemplate = redisTemplate;
        this.h3 = H3Core.newInstance();
    }

    /**
     * Met à jour la position du chauffeur dans Redis + index H3 MULTI-RÉSOLUTION
     */
    public void updateDriverLocation(final UUID driverId, final double lat, final double lng, final boolean online) {
        String driverIdStr = driverId.toString();
        int[] resolutions = { 5, 6, 7 };

        // Supprimer les anciens H3 stockés
        String lastH3Key = DRIVER_LAST_H3 + driverIdStr;
        String oldH3List = redisTemplate.opsForValue().get(lastH3Key);
        if (oldH3List != null) {
            for (String oldH3 : oldH3List.split(",")) {
                redisTemplate.opsForSet().remove(KEY_H3 + ":" + oldH3, driverIdStr);
            }
        }

        // Ajouter les nouveaux
        List<String> newH3List = new ArrayList<>();
        for (int resolution : resolutions) {
            long h3Index = h3.geoToH3(lat, lng, resolution);
            redisTemplate.opsForSet().add(KEY_H3 + ":" + h3Index, driverIdStr);
            newH3List.add(String.valueOf(h3Index));
        }

        // Stocker la liste des derniers H3 pour ce driver
        redisTemplate.opsForValue().set(lastH3Key, String.join(",", newH3List));

        // NOUVEAU: Stocker la dernière position du driver
        saveLastLocation(driverId, lat, lng);
    }

    /**
     * Sauvegarde la dernière position connue du driver dans Redis
     */
    private void saveLastLocation(UUID driverId, double lat, double lng) {
        String locationKey = DRIVER_LAST_LOCATION + driverId.toString();

        // Créer un objet JSON avec lat, lng et timestamp
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode locationData = mapper.createObjectNode();
        locationData.put("latitude", lat);
        locationData.put("longitude", lng);
        locationData.put("timestamp", System.currentTimeMillis());

        try {
            String locationJson = mapper.writeValueAsString(locationData);
            redisTemplate.opsForValue().set(locationKey, locationJson,
                    Duration.ofHours(LOCATION_TTL_HOURS));

            log.debug("Saved last location for driver {}: lat={}, lng={}", driverId, lat, lng);
        } catch (Exception e) {
            log.error("Failed to save last location for driver {}: {}", driverId, e.getMessage());
        }
    }

    /**
     * Récupère la dernière position connue du driver depuis Redis
     */
    public DriverLocation getLastDriverLocation(UUID driverId) {
        String locationKey = DRIVER_LAST_LOCATION + driverId.toString();
        String locationJson = redisTemplate.opsForValue().get(locationKey);

        if (locationJson == null) {
            log.debug("No last location found for driver {}", driverId);
            return null;
        }

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode locationData = mapper.readTree(locationJson);

            double lat = locationData.get("latitude").asDouble();
            double lng = locationData.get("longitude").asDouble();
            long timestamp = locationData.get("timestamp").asLong();

            return new DriverLocation(driverId, lat, lng, timestamp);
        } catch (Exception e) {
            log.error("Failed to parse last location for driver {}: {}", driverId, e.getMessage());
            return null;
        }
    }

    /**
     * Sauvegarde la position du driver lors de la fermeture du tracking WebSocket
     * Cette position sera utilisée pour reprendre le tracking si le socket se reconnecte
     */
    public void saveClosedTrackingPosition(UUID driverId, String rideId, DriverLocation location) {
        String trackingKey = DRIVER_TRACKING_CLOSED + driverId.toString() + ":" + rideId;

        ObjectMapper mapper = new ObjectMapper();
        ObjectNode trackingData = mapper.createObjectNode();
        trackingData.put("latitude", location.getLatitude());
        trackingData.put("longitude", location.getLongitude());
        trackingData.put("timestamp", location.getTimestamp());
        trackingData.put("rideId", rideId);

        try {
            String trackingJson = mapper.writeValueAsString(trackingData);
            redisTemplate.opsForValue().set(trackingKey, trackingJson,
                    Duration.ofHours(LOCATION_TTL_HOURS));

            log.info("Saved tracking closed position for driver {} in ride {}", driverId, rideId);
        } catch (Exception e) {
            log.error("Failed to save tracking closed position: {}", e.getMessage());
        }
    }

    /**
     * Récupère la dernière position de tracking fermé pour un ride spécifique
     * Utilisé quand le WebSocket se reconnecte
     */
    public DriverLocation getClosedTrackingPosition(UUID driverId, String rideId) {
        String trackingKey = DRIVER_TRACKING_CLOSED + driverId.toString() + ":" + rideId;
        String trackingJson = redisTemplate.opsForValue().get(trackingKey);

        if (trackingJson == null) {
            log.debug("No closed tracking position found for driver {} in ride {}", driverId, rideId);
            return null;
        }

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode trackingData = mapper.readTree(trackingJson);

            double lat = trackingData.get("latitude").asDouble();
            double lng = trackingData.get("longitude").asDouble();
            long timestamp = trackingData.get("timestamp").asLong();

            // Supprimer la clé après récupération (one-time use)
            redisTemplate.delete(trackingKey);

            log.info("Retrieved and deleted closed tracking position for driver {} in ride {}", driverId, rideId);

            return new DriverLocation(driverId, lat, lng, timestamp);
        } catch (Exception e) {
            log.error("Failed to parse closed tracking position: {}", e.getMessage());
            return null;
        }
    }

    public Set<String> getDriversInH3(long h3Index) {
        return redisTemplate.opsForSet().members(KEY_H3 + ":" + h3Index);
    }

    public long getH3Index(double lat, double lng, int resolution) {
        return h3.geoToH3(lat, lng, resolution);
    }

    public Set<Long> getH3KRing(long h3Index, int k) {
        return new HashSet<>(h3.kRing(h3Index, k));
    }
}