package com.srrfrr.api.websocket.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.domain.ride.RidePaymentHandler;
import com.srrfrr.api.dto.driver.DriverLocation;
import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.services.location.DriverLocationService;
import com.srrfrr.api.services.location.GeoUtils;
import com.srrfrr.api.services.loyalty.LoyaltyService;
import com.srrfrr.api.services.ride.RideService;
import com.srrfrr.api.services.ride.RideWebSocketService;
import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.managers.RideSessionManager;
import com.srrfrr.api.websocket.model.RideOffer;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket Handler for Real-Time Ride Tracking
 * 
 * Manages bi-directional communication between driver and passenger during active rides.
 * Handles location updates, ride state transitions, and proximity-based notifications.
 * 
 * Message Flow:
 * 1. ACCEPTED -> Driver updates location -> Passenger sees driver approaching
 * 2. Driver arrives (≤50m) -> "driverArrived" event -> Passenger notified
 * 3. Passenger clicks "I'm coming" -> "passengerComing" event -> Driver notified
 * 4. Driver clicks "Start Ride" -> "startRide" event -> Status STARTED
 * 5. STARTED -> Driver updates location -> Route to destination
 * 6. Driver arrives at destination -> "finishRide" event -> Status COMPLETED
 * 7. Any time -> User clicks "Cancel" -> "cancelRide" event -> Status CANCELED
 *
 * Security: No authentication on WebSocket (consider adding token validation)
 */
@Component
@Slf4j
public class RideTrackingSocketHandler extends TextWebSocketHandler {

    private final Map<String, Set<WebSocketSession>> rideSessions = new ConcurrentHashMap<>();
    private final ObjectMapper mapper = new ObjectMapper();
    private final DriverLocationService driverLocationService;
    private final RideService rideService;
    private final LoyaltyService loyaltyService;
    private final RideWebSocketService rideWebSocketService;
    private final RideSessionManager sessionManager;
    private final RidePaymentHandler ridePaymentHandler;

    // Distance thresholds in kilometers
    private static final double ARRIVAL_THRESHOLD_KM = 0.05; // 50 meters

    public RideTrackingSocketHandler(DriverLocationService driverLocationService,
                                    RideService rideService,
                                    LoyaltyService loyaltyService,
                                    RideWebSocketService rideWebSocketService,
                                    RideSessionManager sessionManager,
                                    RidePaymentHandler ridePaymentHandler) {
        this.driverLocationService = driverLocationService;
        this.loyaltyService = loyaltyService;
        this.rideService = rideService;
        this.rideWebSocketService = rideWebSocketService;
        this.sessionManager = sessionManager;
        this.ridePaymentHandler = ridePaymentHandler;
    }

    // ========================================================================
    // CONNECTION LIFECYCLE
    // ========================================================================

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String rideId = getRideIdFromUri(session);
        log.info("WebSocket connected for ride tracking: {}", rideId);

        // Add session to the ride's session set
        rideSessions.computeIfAbsent(rideId, k -> ConcurrentHashMap.newKeySet()).add(session);

        // Send connection confirmation
        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "connected");
        msg.put("rideId", rideId);
        msg.put("message", "Connected to ride tracking");
        session.sendMessage(new TextMessage(msg.toString()));

        log.info("Active sessions for ride {}: {}", rideId, rideSessions.get(rideId).size());

        try {
            Ride ride = rideService.getRideById(UUID.fromString(rideId));
            if (ride != null && ride.getDriver() != null) {
                UUID driverId = ride.getDriver().getId();

                // Chercher d'abord la position de tracking fermé (plus récente et spécifique au ride)
                DriverLocation lastLocation = driverLocationService.getClosedTrackingPosition(driverId, rideId);

                // Si pas de position de tracking fermé, chercher la dernière position générale
                if (lastLocation == null) {
                    lastLocation = driverLocationService.getLastDriverLocation(driverId);
                }

                if (lastLocation != null) {
                    // Créer le message de dernière position
                    ObjectNode locationMsg = mapper.createObjectNode();
                    locationMsg.put("type", "driverLocationUpdate");
                    locationMsg.put("rideId", rideId);
                    locationMsg.put("driverId", driverId.toString());
                    locationMsg.put("latitude", lastLocation.getLatitude());
                    locationMsg.put("longitude", lastLocation.getLongitude());
                    locationMsg.put("timestamp", lastLocation.getTimestamp());

                    // Calculer les distances selon le statut du ride
                    if (ride.getStatus() == RideStatus.ACCEPTED) {
                        double distanceToPickup = GeoUtils.distance(
                                lastLocation.getLatitude(),
                                lastLocation.getLongitude(),
                                ride.getDepartureLat(),
                                ride.getDepartureLng()
                        );
                        locationMsg.put("distanceToPickup", distanceToPickup);
                        locationMsg.put("message", String.format("Driver last known location (%.2f km from pickup)", distanceToPickup));

                    } else if (ride.getStatus() == RideStatus.STARTED) {
                        double distanceToDestination = GeoUtils.distance(
                                lastLocation.getLatitude(),
                                lastLocation.getLongitude(),
                                ride.getDestinationLat(),
                                ride.getDestinationLng()
                        );
                        locationMsg.put("distanceToDestination", distanceToDestination);
                        locationMsg.put("message", String.format("Driver last known location (%.2f km from destination)", distanceToDestination));
                    }

                    // Envoyer la dernière position au client qui vient de se connecter
                    session.sendMessage(new TextMessage(locationMsg.toString()));

                    log.info("Sent last known location to newly connected session for ride {}. Position age: {} minutes",
                            rideId, lastLocation.getAgeInMinutes());
                } else {
                    log.debug("No last known location found for driver {} in ride {}", driverId, rideId);
                }
            }
        } catch (Exception e) {
            log.error("Failed to retrieve and send last known location for ride {}: {}", rideId, e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String rideId = getRideIdFromUri(session);
        log.info("WebSocket disconnected for ride tracking: {}, status: {}", rideId, status);

        Set<WebSocketSession> sessions = rideSessions.get(rideId);
        if (sessions != null) {
            sessions.remove(session);
            if (sessions.isEmpty()) {
                rideSessions.remove(rideId);
                log.info("No more active sessions for ride: {}", rideId);

                // Stocker la dernière position du driver dans Redis lors de la fermeture du socket
                try {
                    Ride ride = rideService.getRideById(UUID.fromString(rideId));
                    if (ride != null && ride.getDriver() != null) {
                        UUID driverId = ride.getDriver().getId();

                        // Récupérer la dernière position connue depuis Redis
                        DriverLocation lastLocation = driverLocationService.getLastDriverLocation(driverId);

                        if (lastLocation != null) {
                            // Sauvegarder comme position de tracking fermé
                            driverLocationService.saveClosedTrackingPosition(driverId, rideId, lastLocation);
                            log.info("Saved last tracking position for driver {} in ride {}: lat={}, lng={}",
                                    driverId, rideId, lastLocation.getLatitude(), lastLocation.getLongitude());
                        }
                    }
                } catch (Exception e) {
                    log.error("Failed to save last tracking position for ride {}: {}", rideId, e.getMessage());
                }
            }
        }
    }

    // ========================================================================
    // MESSAGE ROUTING
    // ========================================================================

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            JsonNode json = mapper.readTree(message.getPayload());

            if (!json.has("type")) {
                sendError(session, "Missing 'type' field in message");
                return;
            }

            String type = json.get("type").asText();
            String rideId = getRideIdFromUri(session);

            log.info("Received message type: {} for ride: {}", type, rideId);

            switch (type) {
                case "driverLocationUpdate" -> handleDriverLocationUpdate(rideId, session, json);
                case "driverArrived" -> handleDriverArrived(rideId, session, json);
                case "passengerComing" -> handlePassengerComing(rideId, session, json);
                case "startRide" -> handleStartRide(rideId, session, json);
                case "finishRide" -> handleFinishRide(rideId, session, json);
                case "cancelRide" -> handleCancelRide(rideId, session, json);
                default -> sendError(session, "Unknown message type: " + type);
            }
        } catch (Exception e) {
            log.error("Error handling message: ", e);
            sendError(session, "Error processing message: " + e.getMessage());
        }
    }

    // ========================================================================
    // MESSAGE HANDLERS
    // ========================================================================

    /**
     * Handle driver location updates during ride
     * 
     * Expected payload:
     * {
     * "type": "driverLocationUpdate",
     * "driverId": "uuid",
     * "latitude": 33.5731,
     * "longitude": -7.5898
     * }
     * 
     * Broadcasts to passenger with distance calculations
     * Notifies driver when approaching destination (≤100m)
     */
    private void handleDriverLocationUpdate(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        // Validate required fields
        if (!json.has("latitude") || !json.has("longitude") || !json.has("driverId")) {
            sendError(session, "Missing required fields: latitude, longitude, or driverId");
            return;
        }

        double lat = json.get("latitude").asDouble();
        double lng = json.get("longitude").asDouble();
        UUID driverId = UUID.fromString(json.get("driverId").asText());

        // Update Redis cache for driver location
        driverLocationService.updateDriverLocation(driverId, lat, lng, true);
        log.debug("Driver {} location updated for ride {} -> lat: {}, lng: {}", driverId, rideId, lat, lng);

        // Get ride details
        Ride ride = rideService.getRideById(UUID.fromString(rideId));
        if (ride == null) {
            sendError(session, "Ride not found: " + rideId);
            return;
        }

        // Calculate distances based on ride status
        ObjectNode locationMsg = mapper.createObjectNode();
        locationMsg.put("type", "driverLocationUpdate");
        locationMsg.put("rideId", rideId);
        locationMsg.put("driverId", driverId.toString());
        locationMsg.put("latitude", lat);
        locationMsg.put("longitude", lng);
        locationMsg.put("timestamp", System.currentTimeMillis());

        if (ride.getStatus() == RideStatus.ACCEPTED) {
            // Driver approaching pickup location
            double distanceToPickup = GeoUtils.distance(
                    lat, lng,
                    ride.getDepartureLat(), ride.getDepartureLng()
            );
            locationMsg.put("distanceToPickup", distanceToPickup);

            log.debug("Driver approaching pickup. Distance: {} km", distanceToPickup);

            // Broadcast to ALL sessions (passenger will receive this)
            broadcastToRide(rideId, null, locationMsg);

        } else if (ride.getStatus() == RideStatus.STARTED) {
            // Driver heading to destination
            double distanceToDestination = GeoUtils.distance(
                    lat, lng,
                    ride.getDestinationLat(), ride.getDestinationLng()
            );
            locationMsg.put("distanceToDestination", distanceToDestination);

            log.debug("Ride in progress. Distance to destination: {} km", distanceToDestination);

            // Broadcast to ALL sessions (passenger will receive this)
            broadcastToRide(rideId, null, locationMsg);

            // Check if driver is approaching destination (≤100m)
            if (distanceToDestination <= 0.1) { // 100 meters = 0.1 km
                log.info("Driver {} approaching destination for ride {}. Distance: {} km",
                        driverId, rideId, distanceToDestination);

                // Send notification ONLY to driver (sender session)
                ObjectNode approachingMsg = mapper.createObjectNode();
                approachingMsg.put("type", "approachingDestination");
                approachingMsg.put("rideId", rideId);
                approachingMsg.put("distance", distanceToDestination);
                approachingMsg.put("message", "You are approaching the destination. Ready to finish ride?");

                try {
                    session.sendMessage(new TextMessage(approachingMsg.toString()));
                    log.info("Sent approaching destination notification to driver {}", driverId);
                } catch (IOException e) {
                    log.error("Failed to send approaching destination notification", e);
                }
            }
        }
    }

    /**
     * Handle driver arrival at pickup location
     * Driver clicks "I'm here" button when within 50m of pickup
     * 
     * Expected payload:
     * {
     * "type": "driverArrived",
     * "driverId": "uuid",
     * "latitude": 33.5731,
     * "longitude": -7.5898
     * }
     * 
     * Validates proximity and notifies passenger
     */
    private void handleDriverArrived(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        if (!json.has("driverId") || !json.has("latitude") || !json.has("longitude")) {
            sendError(session, "Missing required fields for driver arrival");
            return;
        }

        UUID driverId = UUID.fromString(json.get("driverId").asText());
        double lat = json.get("latitude").asDouble();
        double lng = json.get("longitude").asDouble();

        Ride ride = rideService.getRideById(UUID.fromString(rideId));
        if (ride.getStatus() != RideStatus.ACCEPTED) {
            sendError(session, "Invalid ride status for driver arrival");
            return;
        }

        // Verify driver is actually near pickup location
        double distanceToPickup = GeoUtils.distance(
                lat, lng,
                ride.getDepartureLat(), ride.getDepartureLng()
        );

        if (distanceToPickup > ARRIVAL_THRESHOLD_KM) {
            sendError(session, String.format("Too far from pickup location: %.2f km", distanceToPickup));
            return;
        }

        log.info("Driver {} confirmed arrival at pickup for ride {}. Distance: {} km",
                driverId, rideId, distanceToPickup);

        // Broadcast arrival notification to passenger
        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "driverArrived");
        msg.put("rideId", rideId);
        msg.put("driverId", driverId.toString());
        msg.put("distance", distanceToPickup);
        msg.put("message", "Driver has arrived at pickup location");

        broadcastToRide(rideId, session, msg);
    }

    /**
     * Handle passenger's "I'm coming" notification
     * Passenger clicks button after driver arrives
     * 
     * Expected payload:
     * {
     * "type": "passengerComing",
     * "passengerId": "uuid",
     * "message": "J'arrive dans 2 minutes" (optional)
     * }
     * 
     * Notifies driver that passenger is on the way
     */
    private void handlePassengerComing(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        UUID passengerId = json.has("passengerId")
                ? UUID.fromString(json.get("passengerId").asText())
                : null;

        String customMessage = json.has("message") ? json.get("message").asText() : null;

        log.info("Passenger {} notifying driver - coming to pickup for ride {}", passengerId, rideId);

        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "passengerComing");
        msg.put("rideId", rideId);
        if (passengerId != null) {
            msg.put("passengerId", passengerId.toString());
        }
        msg.put("message", customMessage != null ? customMessage : "Passenger is coming to pickup point");

        // Broadcast only to driver (exclude sender)
        broadcastToRide(rideId, session, msg);
    }

    /**
     * Handle ride start event
     * Driver clicks "Start Ride" after passenger gets in the car
     * 
     * Expected payload:
     * {
     * "type": "startRide",
     * "driverId": "uuid"
     * }
     * 
     * Updates ride status to STARTED and notifies both parties
     */
    private void handleStartRide(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        log.info("Starting ride: {}", rideId);

        UUID rideUUID = UUID.fromString(rideId);
        rideService.updateRideStatus(rideUUID, RideStatus.STARTED);

        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "rideStarted");
        msg.put("rideId", rideId);
        msg.put("message", "Ride has started - heading to destination");

        // Broadcast to both driver and passenger
        broadcastToRide(rideId, null, msg);

        log.info("Ride {} status updated to STARTED", rideId);
    }

    /**
     * Handle ride completion event
     * Driver clicks "Finish Ride" after arriving at destination
     * 
     * Expected payload:
     * {
     * "type": "finishRide",
     * "driverId": "uuid"
     * }
     * 
     * Updates ride status to COMPLETED, awards loyalty points, and notifies both parties
     */
    private void handleFinishRide(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        log.info("Finishing ride: {}", rideId);
        UUID rideUUID = UUID.fromString(rideId);

        // Update ride status
        rideService.updateRideStatus(rideUUID, RideStatus.COMPLETED);

        // Get ride with passenger for loyalty points
        Ride ride;
        try {
            ride = rideService.getRideWithPassenger(rideUUID);
        } catch (IllegalArgumentException e) {
            sendError(session, "Ride not found for ID: " + rideId);
            return;
        }

        // Award loyalty points to passenger
        UUID passengerId = ride.getPassenger().getId();
        double rideCost = ride.getPrice();
        loyaltyService.awardPoints(ride.getPassenger(), ridePaymentHandler.calculatePointsEarned(
                rideCost), LoyaltyTransactionType.TRAJET);
        DebugConsole.info("Loyalty award", "awarded points to passenger " + passengerId + " for ride " + rideId);
        // Broadcast completion to both driver and passenger
        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "rideCompleted");
        msg.put("rideId", rideId);
        msg.put("message", "Ride completed successfully");

        broadcastToRide(rideId, null, msg);

        log.info("Ride {} marked as COMPLETED", rideId);
    }

    /**
     * Handle ride cancellation event
     * Either driver or passenger cancels the ride during tracking
     *
     * Expected payload:
     * {
     *   "type": "cancelRide",
     *   "rideId": "uuid",
     *   "userId": "uuid",
     *   "reason": "User reported issue" (optional)
     * }
     *
     * Updates ride status to CANCELED and notifies both parties
     * Also broadcasts to main WebSockets if sessions exist
     */
    @Transactional
    private void handleCancelRide(String rideId, WebSocketSession session, JsonNode json) throws IOException {
        if (!json.has("userId")) {
            sendError(session, "Missing required field: userId");
            return;
        }

        String userId = json.get("userId").asText();
        String reason = json.has("reason") ? json.get("reason").asText() : "User cancelled";

        log.info("Processing ride cancellation: {} by user: {}", rideId, userId);

        // Update ride status in database
        try {
            rideService.updateRideStatus(UUID.fromString(rideId), RideStatus.CANCELED);
            log.info("Ride {} status updated to CANCELED", rideId);
        } catch (Exception e) {
            log.error("Failed to update ride status to CANCELED: {}", e.getMessage());
            sendError(session, "Failed to cancel ride");
            return;
        }

        // Get ride offer from session manager for additional notifications
        RideOffer offer = sessionManager.activeRideOffers.remove(rideId);

        // Prepare cancellation message
        ObjectNode msg = mapper.createObjectNode();
        msg.put("type", "cancelRide");
        msg.put("rideId", rideId);
        msg.put("userId", userId);
        msg.put("reason", reason);
        msg.put("message", "Ride has been cancelled");

        // STEP 1: Broadcast to TRACKING WebSocket (current connections)
        broadcastToRide(rideId, null, msg);
        log.info("Broadcasted cancellation to tracking WebSocket sessions for ride {}", rideId);

        // STEP 2: Send to MAIN WebSockets (driver/passenger sockets)
        if (offer != null) {
            // Notify driver through main driver WebSocket
            if (offer.getAcceptedDriverId() != null) {
                WebSocketSession driverSession = sessionManager.driverSessions.get(offer.getAcceptedDriverId());
                if (driverSession != null && driverSession.isOpen()) {
                    rideWebSocketService.sendCancellationNotification(driverSession, rideId, userId);
                    log.info("Sent cancellation to driver {} via main WebSocket", offer.getAcceptedDriverId());
                }
            }

            // Notify passenger through main passenger WebSocket
            WebSocketSession passengerSession = sessionManager.passengerSessions.get(offer.getPassengerId());
            if (passengerSession != null && passengerSession.isOpen()) {
                rideWebSocketService.sendCancellationNotification(passengerSession, rideId, userId);
                log.info("Sent cancellation to passenger {} via main WebSocket", offer.getPassengerId());
            }

            // Optional: Broadcast to nearby drivers (if needed for your use case)
            // rideWebSocketService.broadcastRideCancellationToNearbyDrivers(offer, userId);
        }

        log.info("Ride {} cancellation processed successfully", rideId);
    }

    // ========================================================================
    // UTILITY METHODS
    // ========================================================================

    /**
     * Broadcast message to all connected clients for a ride
     *
     * @param rideId Ride identifier
     * @param sender Session to exclude (null to send to all)
     * @param json   Message to broadcast
     */
    private void broadcastToRide(String rideId, WebSocketSession sender, JsonNode json) throws IOException {
        Set<WebSocketSession> sessions = rideSessions.get(rideId);
        if (sessions == null || sessions.isEmpty()) {
            log.warn("No active sessions for ride: {}", rideId);
            return;
        }

        int sentCount = 0;
        for (WebSocketSession ws : sessions) {
            if (ws.isOpen() && ws != sender) {
                try {
                    ws.sendMessage(new TextMessage(json.toString()));
                    sentCount++;
                } catch (IOException e) {
                    log.error("Failed to send message to session: {}", ws.getId(), e);
                }
            }
        }
        log.debug("Broadcasted {} message to {} sessions for ride: {}",
                json.get("type").asText(), sentCount, rideId);
    }

    /**
     * Send error message to specific session
     */
    private void sendError(WebSocketSession session, String errorMessage) {
        try {
            ObjectNode error = mapper.createObjectNode();
            error.put("type", "error");
            error.put("message", errorMessage);
            session.sendMessage(new TextMessage(error.toString()));
            log.warn("Error sent to session {}: {}", session.getId(), errorMessage);
        } catch (IOException e) {
            log.error("Failed to send error message", e);
        }
    }

    /**
     * Extract ride ID from WebSocket URI
     * Expected format: /ws/tracking/{rideId}
     */
    private String getRideIdFromUri(WebSocketSession session) {
        String path = session.getUri().getPath();
        return path.substring(path.lastIndexOf('/') + 1);
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        String rideId = getRideIdFromUri(session);

        // Ne pas logger les erreurs de connexion reset (connexion fermée par le client)
        if (exception instanceof java.net.SocketException &&
                exception.getMessage().contains("Connection reset")) {
            log.debug("Client disconnected abruptly for ride {}: Connection reset", rideId);
        }
        // Ne pas logger les erreurs de broken pipe (connexion fermée pendant l'écriture)
        else if (exception instanceof java.io.IOException &&
                exception.getMessage().contains("Broken pipe")) {
            log.debug("Client connection broken for ride {}: Broken pipe", rideId);
        }
        // Logger les vraies erreurs
        else {
            log.error("WebSocket transport error for ride {} and session {}: {}",
                    rideId, session.getId(), exception.getMessage());
        }

        // Nettoyer la session en cas d'erreur
        try {
            Set<WebSocketSession> sessions = rideSessions.get(rideId);
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    rideSessions.remove(rideId);
                }
            }
        } catch (Exception e) {
            log.debug("Error during session cleanup: {}", e.getMessage());
        }

        super.handleTransportError(session, exception);
    }
}