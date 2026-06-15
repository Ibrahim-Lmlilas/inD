package com.srrfrr.api.services.ride;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.managers.RideSessionManager;
import com.srrfrr.api.websocket.model.RideOffer;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;

@Component

public class RideWebSocketService {
    private final ObjectMapper objectMapper;
    private final RideSessionManager sessionManager;

    public RideWebSocketService(ObjectMapper objectMapper,
                                RideSessionManager sessionManager) {
        this.objectMapper = objectMapper;
        this.sessionManager = sessionManager;

    }

    @Transactional
    public void broadcastRideCancellationToNearbyDrivers(RideOffer offer, String passengerId) {
        ObjectNode msg = objectMapper.createObjectNode();
        msg.put("type", "cancelRide");
        msg.put("rideId", offer.getRideId());
        msg.put("userId", passengerId);
        msg.put("message", "Passenger cancelled this ride request");

        // Get all connected drivers in the ride's H3 region
        sessionManager.driverSessions.forEach((driverId, driverSession) -> {
            if (driverId.equals(passengerId)) {
                return;
            }
            // Skip drivers already notified
            if (driverId.equals(offer.getPendingDriverId()) ||
                    driverId.equals(offer.getAcceptedDriverId())) {
                return;
            }

            // Send to all drivers in the area
            if (driverSession != null && driverSession.isOpen()) {
                try {
                    driverSession.sendMessage(new TextMessage(msg.toString()));
                } catch (IOException e) {
                    DebugConsole.methodError("BroadcastCancellation", "sendMessage",
                            String.format("Failed to send cancellation to driver %s", driverId), e);
                }
            }
        });

        DebugConsole.info("RideCancellation",
                String.format("Broadcasted cancellation of ride %s to all drivers", offer.getRideId()));
    }

    public void sendCancellationNotification(WebSocketSession session, String rideId,
                                             String cancelledBy) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "cancelRide");
            msg.put("rideId", rideId);
            msg.put("userId", cancelledBy);

            session.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("NotificationService", "sendCancellationNotification",
                    String.format("Failed to send cancellation notification for ride %s", rideId), e);
        }
    }
}
