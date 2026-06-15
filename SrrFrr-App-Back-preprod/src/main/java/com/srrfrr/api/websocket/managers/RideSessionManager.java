package com.srrfrr.api.websocket.managers;

import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.model.RideOffer;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class RideSessionManager {
    public final Map<String, WebSocketSession> driverSessions = new ConcurrentHashMap<>();
    public final Map<String, RideOffer> activeRideOffers = new ConcurrentHashMap<>();

    public final Map<String, WebSocketSession> passengerSessions = new ConcurrentHashMap<>();

    private static final int RIDE_OFFER_TIMEOUT_MINUTES = 10;

    /**
     * Clean up expired ride offers every minute
     */
    @Scheduled(fixedRate = 60000)
    public void cleanupExpiredOffers() {
        int removed = 0;

        for (Map.Entry<String, RideOffer> entry : activeRideOffers.entrySet()) {
            RideOffer offer = entry.getValue();

            if (offer.isExpired(RIDE_OFFER_TIMEOUT_MINUTES) && !offer.isAccepted()) {
                activeRideOffers.remove(entry.getKey());
                removed++;
                DebugConsole.debugData("Cleanup", "Removed expired offer", entry.getKey());
            }
        }

        if (removed > 0) {
            DebugConsole.info("Cleanup", String.format("Cleaned up %d expired ride offers", removed));
        }
    }

    /**
     * Clean up closed WebSocket sessions
     */
    @Scheduled(fixedRate = 30000)
    public void cleanupClosedSessions() {
        int driversCleaned = cleanupSessionMap(driverSessions, "driver");
        int passengersCleaned = cleanupSessionMap(passengerSessions, "passenger");

        if (driversCleaned > 0 || passengersCleaned > 0) {
            DebugConsole.info("Session Cleanup",
                    String.format("Cleaned up %d driver sessions and %d passenger sessions",
                            driversCleaned, passengersCleaned));
        }
    }

    private int cleanupSessionMap(Map<String, WebSocketSession> sessionMap, String type) {
        int removed = 0;

        for (Map.Entry<String, WebSocketSession> entry : sessionMap.entrySet()) {
            WebSocketSession session = entry.getValue();

            if (session == null || !session.isOpen()) {
                sessionMap.remove(entry.getKey());
                removed++;
            }
        }

        return removed;
    }

    /**
     * Get active driver count
     */
    public int getActiveDriverCount() {
        return (int) driverSessions.values().stream()
                .filter(session -> session != null && session.isOpen())
                .count();
    }

    /**
     * Get active passenger count
     */
    public int getActivePassengerCount() {
        return (int) passengerSessions.values().stream()
                .filter(session -> session != null && session.isOpen())
                .count();
    }

    /**
     * Get active ride offer count
     */
    public int getActiveRideOfferCount() {
        return activeRideOffers.size();
    }

    /**
     * Log session statistics
     */
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void logStatistics() {
        DebugConsole.sessionStats("WebSocket",
                getActiveDriverCount(),
                getActivePassengerCount(),
                getActiveRideOfferCount());
    }

    public void addDriverSession(String driverId, WebSocketSession session) {
        driverSessions.put(driverId, session);
        log.info("Driver connected: {}", driverId);
    }

    public void addPassengerSession(String passengerId, WebSocketSession session) {
        passengerSessions.put(passengerId, session);
        log.info("Passenger connected: {}", passengerId);
    }

    public WebSocketSession getDriverSession(String driverId) {
        return driverSessions.get(driverId);
    }

    public WebSocketSession getPassengerSession(String passengerId) {
        return passengerSessions.get(passengerId);
    }

    public void removeDriverSession(String driverId) {
        driverSessions.remove(driverId);
        log.info("Driver disconnected: {}", driverId);
    }

    public void removePassengerSession(String passengerId) {
        passengerSessions.remove(passengerId);
        log.info("Passenger disconnected: {}", passengerId);
    }
}
