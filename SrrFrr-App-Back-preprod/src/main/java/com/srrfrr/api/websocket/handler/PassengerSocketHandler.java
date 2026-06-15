package com.srrfrr.api.websocket.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.domain.ride.RideValidationService;
import com.srrfrr.api.dto.driver.DriverResponse;
import com.srrfrr.api.entities.main.ChatChannel;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Ride.PaymentType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.auth.TokenService;
import com.srrfrr.api.services.chat.ChatService;
import com.srrfrr.api.services.location.DriverLocationService;
import com.srrfrr.api.services.ride.RideService;
import com.srrfrr.api.services.ride.RideWebSocketService;
import com.srrfrr.api.services.user.DriverService;
import com.srrfrr.api.utils.ConvertToURL;
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

@Component
@Slf4j
public class PassengerSocketHandler extends TextWebSocketHandler {

    private final DriverLocationService driverLocationService;
    private final RideService rideService;
    private final DriverService driverService;
    private final RideWebSocketService rideWebSocketService;
    private final PassengerRepository passengerRepository;
    private final RideSessionManager sessionManager;
    private final ObjectMapper objectMapper;
    private final TokenService tokenService;
    private final ChatService chatService;
    private final DriverRepository driverRepository;
    private final RideValidationService validationService;

    public PassengerSocketHandler(DriverLocationService driverLocationService,
            DriverService driverService,
            PassengerRepository passengerRepository,
            RideSessionManager sessionManager,
            RideWebSocketService rideWebSocketService,
            ChatService chatService,
            ObjectMapper objectMapper,
            DriverRepository driverRepository,
            RideService rideService,
            TokenService tokenService,
            RideValidationService validationService) {
        this.driverLocationService = driverLocationService;
        this.driverService = driverService;
        this.passengerRepository = passengerRepository;
        this.driverRepository = driverRepository;
        this.sessionManager = sessionManager;
        this.rideWebSocketService = rideWebSocketService;
        this.chatService = chatService;
        this.objectMapper = objectMapper;
        this.rideService = rideService;
        this.tokenService = tokenService;
        this.validationService = validationService;
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        try {
            JsonNode json = objectMapper.readTree(message.getPayload());

            if (!json.has("type")) {
                sendError(session, "Message type is required");
                return;
            }

            String type = json.get("type").asText();

            switch (type) {
                case "rideRequest" -> handleRideRequest(session, json);
                case "counterOffer" -> handlePassengerCounterOffer(session, json);
                case "acceptDriver" -> handleAcceptDriver(session, json);
                case "rejectDriver" -> handleRejectDriver(session, json);
                case "cancelRide" -> handleCancelRide(session, json);
                default -> DebugConsole.methodWarning("WebSocketHandler", "handleMessage",
                        String.format("Unknown message type: %s", type));
            }
        } catch (Exception e) {
            DebugConsole.methodError("WebSocketHandler", "handleMessage",
                    "Failed to process WebSocket message from passenger", e);
            sendError(session, "Failed to process message");
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessionManager.passengerSessions.values().removeIf(s -> s.getId().equals(session.getId()));
        DebugConsole.info("Websocket", String.format("Passanger disconnected: %s", session.getId()));
    }

    @Transactional
    private void handleRideRequest(WebSocketSession session, JsonNode json) {
        if (!validateRideRequest(json)) {
            sendError(session, "Invalid ride request format");
            return;
        }

        String passengerId = json.get("passengerId").asText();

        Passenger passenger = passengerRepository.findById(UUID.fromString(passengerId)).orElse(null);
        if (passenger == null) {
            sendError(session, "Passenger not found");
            return;
        }

        // Remove previous active offers for this passenger (one request at a time)
        sessionManager.activeRideOffers.values()
                .removeIf(offer -> offer.getPassengerId().equals(passengerId) && !offer.isAccepted());

        // Extract location data
        JsonNode departure = json.get("departure");
        JsonNode destination = json.get("destination");

        double fromLat = departure.get("latitude").asDouble();
        double fromLng = departure.get("longitude").asDouble();
        double toLat = destination.get("latitude").asDouble();
        double toLng = destination.get("longitude").asDouble();

        String departureAddress = getTextValue(departure, "address");
        String departureCity = getTextValue(departure, "city");
        String destinationAddress = getTextValue(destination, "address");
        String destinationCity = getTextValue(destination, "city");

        // Extract ride details
        double price = json.get("price").asDouble();
        String rideType = getTextValue(json, "rideType", "standard");
        String vehicleType = getTextValue(json, "vehicleType", "any");
        int seats = json.has("seats") ? json.get("seats").asInt() : 1;
        double distanceKm = json.has("distanceKm") ? json.get("distanceKm").asDouble() : 0.0;
        String estimatedTime = getTextValue(json, "estimatedTime", "");

        PaymentType paymentType = PaymentType.valueOf(getTextValue(json, "paymentType", ""));

        // VALIDATE free ride eligibility
        if (paymentType == PaymentType.FREERIDE) {
            try {
                int pointsNeeded = (int) Math.ceil(price);

                // Only validate - points will be deducted when driver accepts
                RideValidationService.ValidationResult validation = validationService.validateFreeRide(passenger,
                        pointsNeeded);

                if (!validation.isValid()) {
                    sendError(session, validation.getMessage());
                    return;
                }

                log.info("Free ride request validated for passenger {}: has {} points, needs {} points for {} DH ride",
                        passengerId, passenger.getPoints(), pointsNeeded, price);

            } catch (Exception e) {
                sendError(session, "Free ride validation failed: " + e.getMessage());
                return;
            }
        }

        // Calculate H3 hexagons for geo-proximity
        int resolution = 6;
        long centerH3 = driverLocationService.getH3Index(fromLat, fromLng, resolution);
        Set<Long> hexagons = driverLocationService.getH3KRing(centerH3, 1);

        // Create ride offer
        String rideId = UUID.randomUUID().toString();

        RideOffer offer = new RideOffer(
                rideId, passengerId, fromLat, fromLng, toLat, toLng, price, hexagons,
                passenger, departureAddress, departureCity, destinationAddress, destinationCity,
                rideType, vehicleType, seats, distanceKm, estimatedTime, paymentType);

        offer.setPassengerSession(session);
        sessionManager.activeRideOffers.put(rideId, offer);

        sessionManager.passengerSessions.put(passengerId, session);

        // Send H3 info to passenger (for debugging/monitoring)
        sendH3Info(session, rideId, centerH3, hexagons);

        // Broadcast to nearby drivers
        broadcastToNearbyDrivers(offer);

        DebugConsole.methodSuccess("RideService", "createRideRequest",
                String.format("Ride request %s created by passenger %s (payment: %s)",
                        rideId, passengerId, paymentType));
    }

    private void broadcastToNearbyDrivers(RideOffer offer) {
        int driverCount = 0;
        int totalDrivers = sessionManager.driverSessions.size();

        DebugConsole.info("Broadcast",
                String.format("Starting broadcast for ride %s to %d connected drivers",
                        offer.getRideId(), totalDrivers));

        for (Map.Entry<String, WebSocketSession> entry : sessionManager.driverSessions.entrySet()) {
            String driverId = entry.getKey();
            WebSocketSession driverSession = entry.getValue();

            // CHECK 1: Session validation
            if (driverSession == null || !driverSession.isOpen()) {
                DebugConsole.methodWarning("Broadcast", "skipDriver",
                        String.format("Driver %s: session null or closed", driverId));
                continue;
            }

            // CHECK 2: Driver entity validation
            Driver driver = driverRepository.findById(UUID.fromString(driverId)).orElse(null);
            if (driver == null) {
                DebugConsole.methodWarning("Broadcast", "skipDriver",
                        String.format("Driver %s: entity not found in database", driverId));
                continue;
            }

            if (driver.getPassenger() == null) {
                DebugConsole.methodWarning("Broadcast", "skipDriver",
                        String.format("Driver %s: no linked passenger entity for gender check", driverId));
                continue;
            }

            // CHECK 3: Gender filtering
            if (offer.getPassengerEntity().getInterfaceType() == InterfaceType.LADIES &&
                    driver.getPassenger().getGender() != GenderLabel.FEMALE) {
                DebugConsole.info("Broadcast",
                        String.format("Driver %s filtered: LADIES mode, driver not female", driverId));
                continue;
            }

            // if (driver.getPassenger().getGender() == GenderLabel.FEMALE &&
            //         offer.getPassengerEntity().getGender() != GenderLabel.FEMALE) {
            //     DebugConsole.info("Broadcast",
            //             String.format("Driver %s filtered: female driver, passenger not female", driverId));
            //     continue;
            // }

            // CHECK 4: H3 proximity
            if (isDriverNearby(driverId, offer.getH3Neighbors())) {
                DebugConsole.info("Broadcast",
                        String.format("Driver %s MATCHED - sending offer", driverId));
                sendRideOfferToDriver(driverSession, offer);
                driverCount++;
            } else {
                DebugConsole.info("Broadcast",
                        String.format("Driver %s filtered: not in nearby H3 hexagons", driverId));
            }
        }

        DebugConsole.methodSuccess("BroadcastRide", "broadcastToNearbyDrivers",
                String.format("Ride %s broadcast to %d/%d drivers",
                        offer.getRideId(), driverCount, totalDrivers));
    }

    private boolean isDriverNearby(String driverId, Set<Long> hexagons) {
        return hexagons.stream()
                .anyMatch(hex -> {
                    Set<String> drivers = driverLocationService.getDriversInH3(hex);
                    return drivers != null && drivers.contains(driverId);
                });
    }

    private void sendRideOfferToDriver(WebSocketSession driverSession, RideOffer offer) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "rideRequest");
            msg.put("rideId", offer.getRideId());

            // Passenger info
            if (offer.getPassengerEntity() != null) {
                ObjectNode passengerNode = objectMapper.createObjectNode();
                passengerNode.put("id", offer.getPassengerEntity().getId().toString());
                passengerNode.put("firstName", offer.getPassengerEntity().getFirstName());
                passengerNode.put("lastName", offer.getPassengerEntity().getLastName());
                passengerNode.put("profilePicture",
                        ConvertToURL.convert(offer.getPassengerEntity().getProfilePicture()));
                passengerNode.put("rating", offer.getPassengerEntity().getRating());
                passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());
                msg.set("passenger", passengerNode);
            }

            // Location info
            msg.set("departure", createLocationNode(
                    offer.getDepartureAddress(),
                    offer.getFromLat(),
                    offer.getFromLng(),
                    offer.getDepartureCity()));

            msg.set("destination", createLocationNode(
                    offer.getDestinationAddress(),
                    offer.getToLat(),
                    offer.getToLng(),
                    offer.getDestinationCity()));

            // Ride details
            msg.put("price", offer.getPrice());
            msg.put("rideType", offer.getRideType());
            msg.put("vehicleType", offer.getVehicleType());
            msg.put("seats", offer.getSeats());
            msg.put("distanceKm", offer.getDistanceKm());
            msg.put("estimatedTime", offer.getEstimatedTime());
            msg.put("paymentType", offer.getPaymentType() != null ? offer.getPaymentType().name() : "");

            driverSession.sendMessage(new TextMessage(msg.toString()));
            log.debug("Broadcast ride {} to driver", offer.getRideId());

        } catch (IOException e) {
            DebugConsole.methodError("PassengerService", "broadcastRideOffer",
                    String.format("Failed to broadcast ride offer %s", offer.getRideId()), e);
        }
    }

    private void handlePassengerCounterOffer(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "passengerId", "newPrice")) {
            sendError(session, "Missing required fields");
            return;
        }

        String rideId = json.get("rideId").asText();
        String passengerId = json.get("passengerId").asText();
        double newPrice = json.get("newPrice").asDouble();

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);
        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        if (offer.isAccepted()) {
            sendError(session, "Ride already accepted");
            return;
        }

        // If this is a free ride, validate they have enough points for the NEW price
        if (offer.getPaymentType() == PaymentType.FREERIDE) {
            try {
                Passenger passenger = passengerRepository.findById(UUID.fromString(passengerId))
                        .orElseThrow(() -> new IllegalStateException("Passenger not found"));

                int pointsNeeded = (int) Math.ceil(newPrice);

                RideValidationService.ValidationResult validation = validationService.validateFreeRide(passenger,
                        pointsNeeded);

                if (!validation.isValid()) {
                    sendError(session, "Insufficient points for counter-offer: " + validation.getMessage());
                    return;
                }

                log.info("Free ride counter-offer validated: passenger {} has {} points for {} DH counter-offer",
                        passengerId, passenger.getPoints(), newPrice);

            } catch (Exception e) {
                sendError(session, "Counter-offer validation failed: " + e.getMessage());
                return;
            }
        }

        String pendingDriverId = offer.getPendingDriverId();
        offer.setPrice(newPrice);
        offer.setLastPassengerPrice(newPrice);

        if (pendingDriverId != null) {
            // Passenger is counter-offering back to a specific driver — notify only that driver
            WebSocketSession driverSession = sessionManager.driverSessions.get(pendingDriverId);
            if (driverSession != null && driverSession.isOpen()) {
                sendPassengerCounterOfferToDriver(driverSession, offer, pendingDriverId, newPrice);
            }
            // pendingDriverId stays set: negotiation continues with this driver
        } else {
            // No active negotiation — broadcast updated price to all nearby drivers
            broadcastToNearbyDrivers(offer);
        }

        // Confirm to passenger
        sendCounterOfferConfirmation(session, rideId, newPrice);

        DebugConsole.info("Counter Offer",
                String.format("Passenger %s sent counter offer %.2f for ride %s", passengerId, newPrice, rideId));
    }
    
    /**
     * Sends confirmation to passenger that counter-offer was broadcast.
     */
    private void sendCounterOfferConfirmation(WebSocketSession session, String rideId, double newPrice) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "counterOfferSent");
            msg.put("rideId", rideId);
            msg.put("newPrice", newPrice);
            msg.put("message", "Your counter-offer has been sent to nearby drivers");

            session.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("PassengerService", "sendCounterOfferConfirmation",
                    String.format("Failed to send counter-offer confirmation for ride %s", rideId), e);
        }
    }

    @Transactional
    private void handleAcceptDriver(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "driverId", "passengerId")) {
            sendError(session, "Missing required fields");
            return;
        }

        String rideId = json.get("rideId").asText();
        String driverId = json.get("driverId").asText();
        String passengerId = json.get("passengerId").asText();

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);
        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        if (offer.isAccepted()) {
            sendError(session, "Ride already accepted");
            return;
        }

        // Verify this is the pending driver
        if (!driverId.equals(offer.getPendingDriverId())) {
            sendError(session, "This driver has not made an offer for this ride");
            return;
        }

        // IMPORTANT: Re-validate free ride at FINAL price
        // Price may have changed due to counter-offers!
        if (offer.getPaymentType() == PaymentType.FREERIDE) {
            Passenger passenger = passengerRepository.findById(UUID.fromString(passengerId))
                    .orElseThrow(() -> new IllegalStateException("Passenger not found"));

            int pointsNeeded = (int) Math.ceil(offer.getPrice());

            // Re-validate at the FINAL negotiated price
            RideValidationService.ValidationResult validation = validationService.validateFreeRide(passenger,
                    pointsNeeded);

            if (!validation.isValid()) {
                sendError(session, "Insufficient points for final price: " + validation.getMessage());
                return;
            }

            log.info("Free ride re-validated at final price {} DH (needs {} points, has {} points)",
                    offer.getPrice(), pointsNeeded, passenger.getPoints());
        }

        try {
            // Mark as accepted and set final price
            offer.setAccepted(true);
            offer.setAcceptedDriverId(driverId);

            // Persist ride to database
            // The saveRide method calls processPayment which deducts points
            Ride savedRide = rideService.saveRide(offer, RideStatus.ACCEPTED);

            if (savedRide == null) {
                sendError(session, "Failed to save ride");
                return;
            }

            log.info("Ride {} successfully saved with ID {} (payment: {}, price: {} DH)",
                    rideId, savedRide.getId(), offer.getPaymentType(), offer.getPrice());

            // Get or create chat channel
            ChatChannel channel = chatService.getOrCreateChannel(savedRide.getId());
            String channelId = channel.getId().toString();

            // Send confirmation to driver with correct channelId
            WebSocketSession driverSession = sessionManager.driverSessions.get(driverId);
            if (driverSession != null && driverSession.isOpen()) {
                sendRideConfirmationToDriver(driverSession, offer, driverId, offer.getPrice(), channelId);
            }

            // Send confirmation to passenger with correct channelId
            sendRideConfirmationToPassenger(session, offer, driverId, offer.getPrice(), channelId);

            DebugConsole.methodSuccess("RideService", "acceptDriver",
                    String.format(
                            "Passenger %s accepted driver %s for ride %s at price %.2f with channel %s (payment: %s)",
                            passengerId, driverId, rideId, offer.getPrice(), channelId, offer.getPaymentType()));

        } catch (IllegalStateException e) {
            log.error("Failed to accept driver for ride {}: {}", rideId, e.getMessage(), e);
            sendError(session, "Failed to accept driver: " + e.getMessage());

            // Clean up the offer if ride creation failed
            offer.setAccepted(false);
            offer.setAcceptedDriverId(null);
        }
    }
    
    private void handleRejectDriver(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "driverId", "passengerId")) {
            sendError(session, "Missing required fields");
            return;
        }

        String rideId = json.get("rideId").asText();
        String driverId = json.get("driverId").asText();
        String passengerId = json.get("passengerId").asText();

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);
        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        if (offer.isAccepted()) {
            sendError(session, "Ride already accepted");
            return;
        }

        // Clear pending driver and restore the passenger's last offered price
        offer.setPendingDriverId(null);
        offer.setPrice(offer.getLastPassengerPrice());

        // Notify driver of rejection
        WebSocketSession driverSession = sessionManager.driverSessions.get(driverId);
        if (driverSession != null && driverSession.isOpen()) {
            sendDriverRejection(driverSession, rideId, offer.getLastPassengerPrice());
        }

        // Confirm rejection to passenger
        sendRejectionConfirmation(session, rideId, driverId);

        DebugConsole.methodWarning("RideService", "rejectDriver",
                String.format("Passenger %s rejected driver %s for ride %s", passengerId, driverId, rideId));
    }

    /**
     * Sends rejection notification to driver, including the restored passenger price
     * so the driver's UI can display the correct current offer.
     */
    private void sendDriverRejection(WebSocketSession driverSession, String rideId, double restoredPrice) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "offerRejected");
            msg.put("rideId", rideId);
            msg.put("restoredPrice", restoredPrice);
            msg.put("message", "The passenger declined your offer");

            driverSession.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("PassengerService", "sendRejectionToDriver",
                    String.format("Failed to send rejection to driver for ride %s", rideId), e);
        }
    }

    /**
     * Sends the passenger's counter-offer to a specific driver during bilateral negotiation.
     */
    private void sendPassengerCounterOfferToDriver(WebSocketSession driverSession, RideOffer offer,
            String driverId, double newPrice) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "passengerCounterOffer");
            msg.put("rideId", offer.getRideId());
            msg.put("passengerId", offer.getPassengerId());
            msg.put("newPrice", newPrice);

            // Include passenger details so the driver's UI can display them
            if (offer.getPassengerEntity() != null) {
                ObjectNode passengerNode = objectMapper.createObjectNode();
                passengerNode.put("id", offer.getPassengerEntity().getId().toString());
                passengerNode.put("firstName", offer.getPassengerEntity().getFirstName());
                passengerNode.put("lastName", offer.getPassengerEntity().getLastName());
                passengerNode.put("profilePicture",
                        ConvertToURL.convert(offer.getPassengerEntity().getProfilePicture()));
                passengerNode.put("rating", offer.getPassengerEntity().getRating());
                passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());
                msg.set("passenger", passengerNode);
            }

            driverSession.sendMessage(new TextMessage(msg.toString()));
            DebugConsole.info("Counter Offer",
                    String.format("Passenger sent counter %.2f back to driver %s for ride %s",
                            newPrice, driverId, offer.getRideId()));
        } catch (IOException e) {
            DebugConsole.methodError("PassengerService", "sendPassengerCounterOffer",
                    String.format("Failed to send passenger counter-offer to driver for ride %s", offer.getRideId()),
                    e);
        }
    }

    /**
     * Sends rejection confirmation to passenger.
     */
    private void sendRejectionConfirmation(WebSocketSession session, String rideId, String driverId) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "driverRejected");
            msg.put("rideId", rideId);
            msg.put("driverId", driverId);
            msg.put("message", "Driver offer rejected. Waiting for other drivers.");

            session.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("PassengerService", "sendRejectionConfirmation",
                    String.format("Failed to send rejection confirmation for ride %s", rideId), e);
        }
    }

    /**
     * Handles ride cancellation by passenger.
     */
    @Transactional
    private void handleCancelRide(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "userId")) {
            sendError(session, "Missing required fields");
            return;
        }

        String rideId = json.get("rideId").asText();
        String passengerId = json.get("userId").asText();

        RideOffer offer = sessionManager.activeRideOffers.remove(rideId);
        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        // Notify pending driver if exists
        if (offer.getPendingDriverId() != null) {
            WebSocketSession driverSession = sessionManager.driverSessions.get(offer.getPendingDriverId());
            if (driverSession != null && driverSession.isOpen()) {
                rideWebSocketService.sendCancellationNotification(driverSession, rideId, passengerId);
            }
        }

        // Notify accepted driver if ride was already accepted
        if (offer.getAcceptedDriverId() != null) {
            WebSocketSession driverSession = sessionManager.driverSessions.get(offer.getAcceptedDriverId());
            if (driverSession != null && driverSession.isOpen()) {
                rideWebSocketService.sendCancellationNotification(driverSession, rideId, passengerId);
            }
        }

        rideWebSocketService.broadcastRideCancellationToNearbyDrivers(offer, passengerId);

        // Confirm cancellation to passenger
        rideWebSocketService.sendCancellationNotification(session, rideId, passengerId);

        // Persist cancelled ride to database if it was accepted
        if (offer.isAccepted()) {
            rideService.updateRideStatus(UUID.fromString(rideId), RideStatus.CANCELED);
        }

        DebugConsole.methodWarning("RideService", "cancelRide",
                String.format("Ride %s cancelled by passenger %s", rideId, passengerId));
    }

    private void sendRideConfirmationToPassenger(WebSocketSession session, RideOffer offer,
            String driverId, double price, String channelId) {
        try {
            String wsToken = tokenService.generateWebSocketToken(offer.getPassengerId(), channelId);

            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "rideConfirmed");
            msg.put("rideId", offer.getRideId());
            msg.put("driverId", driverId);
            msg.put("passengerId", offer.getPassengerId());
            msg.put("channelId", channelId);
            msg.put("wsToken", wsToken);
            msg.put("price", price);
            msg.put("message", "Ride confirmed! Your driver is on the way.");

            // Add complete driver details
            DriverResponse driverInfo = driverService.getDriverBasicInfo(UUID.fromString(driverId));
            ObjectNode driverNode = objectMapper.createObjectNode();
            driverNode.put("id", driverInfo.getId().toString());
            driverNode.put("firstName", driverInfo.getFirstName());
            driverNode.put("lastName", driverInfo.getLastName());
            driverNode.put("profilePicture", driverInfo.getProfilePicture());
            driverNode.put("phoneNumber", driverInfo.getPhoneNumber());
            driverNode.put("rating", driverInfo.getRating());
            driverNode.put("totalRides", driverInfo.getTotalRides());
            driverNode.put("isVerified", driverInfo.isVerified());
            driverNode.put("vehicleType",
                    driverInfo.getVehicleType() != null ? driverInfo.getVehicleType().toString() : null);
            driverNode.put("vehicleBrand", driverInfo.getVehicleBrand());
            driverNode.put("vehicleModel", driverInfo.getVehicleModel());
            driverNode.put("vehicleColor", driverInfo.getVehicleColor());
            driverNode.put("vehicleRegistrationCode", driverInfo.getVehicleRegistrationCode());
            msg.set("driver", driverNode);

            // Add passenger details
            if (offer.getPassengerEntity() != null) {
                ObjectNode passengerNode = objectMapper.createObjectNode();
                passengerNode.put("id", offer.getPassengerEntity().getId().toString());
                passengerNode.put("firstName", offer.getPassengerEntity().getFirstName());
                passengerNode.put("lastName", offer.getPassengerEntity().getLastName());
                passengerNode.put("profilePicture",
                        ConvertToURL.convert(offer.getPassengerEntity().getProfilePicture()));
                passengerNode.put("phoneNumber", offer.getPassengerEntity().getPhoneNumber());
                passengerNode.put("rating", offer.getPassengerEntity().getRating());
                passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());
                msg.set("passenger", passengerNode);
            }

            // Add ride locations
            msg.set("departure", createLocationNode(
                    offer.getDepartureAddress(),
                    offer.getFromLat(),
                    offer.getFromLng(),
                    offer.getDepartureCity()));

            msg.set("destination", createLocationNode(
                    offer.getDestinationAddress(),
                    offer.getToLat(),
                    offer.getToLng(),
                    offer.getDestinationCity()));

            // Add ride details
            msg.put("rideType", offer.getRideType() != null ? offer.getRideType() : "standard");
            msg.put("vehicleType", offer.getVehicleType() != null ? offer.getVehicleType() : "");
            msg.put("seats", offer.getSeats());
            msg.put("distanceKm", offer.getDistanceKm());
            msg.put("estimatedTime", offer.getEstimatedTime() != null ? offer.getEstimatedTime() : "");

            session.sendMessage(new TextMessage(msg.toString()));

            DebugConsole.methodSuccess("PassengerService", "sendRideConfirmation",
                    String.format("Confirmation sent to passenger for ride %s", offer.getRideId()));
        } catch (Exception e) {
            DebugConsole.methodError("PassengerService", "sendRideConfirmation",
                    String.format("Failed to send ride confirmation to passenger for ride %s",
                            offer.getRideId()),
                    e);
        }
    }

    private void sendRideConfirmationToDriver(WebSocketSession driverSession, RideOffer offer,
            String driverId, double price, String channelId) {
        try {
            String wsToken = tokenService.generateWebSocketToken(driverId, channelId);

            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "rideConfirmed");
            msg.put("rideId", offer.getRideId());
            msg.put("driverId", driverId);
            msg.put("passengerId", offer.getPassengerId());
            msg.put("channelId", channelId);
            msg.put("wsToken", wsToken);
            msg.put("price", price);
            msg.put("message", "The passenger accepted your offer!");

            // Add complete driver details
            DriverResponse driverInfo = driverService.getDriverBasicInfo(UUID.fromString(driverId));
            ObjectNode driverNode = objectMapper.createObjectNode();
            driverNode.put("id", driverInfo.getId().toString());
            driverNode.put("firstName", driverInfo.getFirstName());
            driverNode.put("lastName", driverInfo.getLastName());
            driverNode.put("profilePicture", driverInfo.getProfilePicture());
            driverNode.put("phoneNumber", driverInfo.getPhoneNumber());
            driverNode.put("rating", driverInfo.getRating());
            driverNode.put("totalRides", driverInfo.getTotalRides());
            driverNode.put("isVerified", driverInfo.isVerified());
            driverNode.put("vehicleType",
                    driverInfo.getVehicleType() != null ? driverInfo.getVehicleType().toString() : null);
            driverNode.put("vehicleBrand", driverInfo.getVehicleBrand());
            driverNode.put("vehicleModel", driverInfo.getVehicleModel());
            driverNode.put("vehicleColor", driverInfo.getVehicleColor());
            msg.set("driver", driverNode);

            // Add passenger details
            if (offer.getPassengerEntity() != null) {
                ObjectNode passengerNode = objectMapper.createObjectNode();
                passengerNode.put("id", offer.getPassengerEntity().getId().toString());
                passengerNode.put("firstName", offer.getPassengerEntity().getFirstName());
                passengerNode.put("lastName", offer.getPassengerEntity().getLastName());
                passengerNode.put("profilePicture",
                        ConvertToURL.convert(offer.getPassengerEntity().getProfilePicture()));
                passengerNode.put("rating", offer.getPassengerEntity().getRating());
                passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());
                passengerNode.put("phoneNumber", offer.getPassengerEntity().getPhoneNumber());
                passengerNode.put("rating", offer.getPassengerEntity().getRating());
                passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());
                msg.set("passenger", passengerNode);
            }

            // Add ride locations
            msg.set("departure", createLocationNode(
                    offer.getDepartureAddress(),
                    offer.getFromLat(),
                    offer.getFromLng(),
                    offer.getDepartureCity()));

            msg.set("destination", createLocationNode(
                    offer.getDestinationAddress(),
                    offer.getToLat(),
                    offer.getToLng(),
                    offer.getDestinationCity()));

            // Add ride details
            msg.put("rideType", offer.getRideType());
            msg.put("vehicleType", offer.getVehicleType());
            msg.put("seats", offer.getSeats());
            msg.put("distanceKm", offer.getDistanceKm());
            msg.put("estimatedTime", offer.getEstimatedTime());

            driverSession.sendMessage(new TextMessage(msg.toString()));

            DebugConsole.methodSuccess("DriverService", "sendRideConfirmation",
                    String.format("Confirmation sent to driver for ride %s", offer.getRideId()));
        } catch (Exception e) {
            DebugConsole.methodError("DriverService", "sendRideConfirmation",
                    String.format("Failed to send ride confirmation to driver for ride %s", offer.getRideId()), e);
        }
    }

    private void sendH3Info(WebSocketSession session, String rideId, long centerH3, Set<Long> hexagons) {
        try {
            ObjectNode msg = objectMapper.createObjectNode();
            msg.put("type", "rideH3Info");
            msg.put("rideId", rideId);
            msg.put("centerH3", centerH3);

            ArrayNode hexArray = objectMapper.createArrayNode();
            hexagons.forEach(hexArray::add);
            msg.set("hexagons", hexArray);

            session.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("H3Service", "sendH3Info",
                    String.format("Failed to send H3 info for ride %s", rideId), e);
        }
    }

    private ObjectNode createLocationNode(String address, double lat, double lng, String city) {
        ObjectNode node = objectMapper.createObjectNode();
        node.put("address", address != null ? address : "");
        node.put("latitude", lat);
        node.put("longitude", lng);
        node.put("city", city != null ? city : "");
        return node;
    }

    private boolean validateRideRequest(JsonNode json) {
        return validateRequiredFields(json, "passengerId", "departure", "destination", "price")
                && json.get("departure").has("latitude")
                && json.get("departure").has("longitude")
                && json.get("destination").has("latitude")
                && json.get("destination").has("longitude");
    }

    private boolean validateRequiredFields(JsonNode json, String... fields) {
        for (String field : fields) {
            if (!json.has(field)) {
                return false;
            }
        }
        return true;
    }

    private String getTextValue(JsonNode json, String field) {
        return json.has(field) ? json.get(field).asText() : "";
    }

    private String getTextValue(JsonNode json, String field, String defaultValue) {
        return json.has(field) ? json.get(field).asText() : defaultValue;
    }

    private void sendError(WebSocketSession session, String error) {
        if (session != null && session.isOpen()) {
            try {
                ObjectNode msg = objectMapper.createObjectNode();
                msg.put("type", "error");
                msg.put("message", error);
                session.sendMessage(new TextMessage(msg.toString()));
            } catch (IOException e) {
                DebugConsole.methodError("WebSocketHandler", "sendErrorMessage", "Failed to send error message", e);
            }
        }
    }
}