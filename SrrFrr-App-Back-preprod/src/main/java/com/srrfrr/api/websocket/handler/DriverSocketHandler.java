package com.srrfrr.api.websocket.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.dto.driver.DriverResponse;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.services.location.DriverLocationService;
import com.srrfrr.api.services.ride.RideService;
import com.srrfrr.api.services.ride.RideWebSocketService;
import com.srrfrr.api.services.user.DriverService;
import com.srrfrr.api.utils.ConvertToURL;
import com.srrfrr.api.utils.DebugConsole;
import com.srrfrr.api.websocket.managers.RideSessionManager;
import com.srrfrr.api.websocket.model.RideOffer;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

@Component
@Slf4j
public class DriverSocketHandler extends TextWebSocketHandler {

    private final DriverLocationService driverLocationService;
    private final DriverService driverService;
    private final DriverRepository driverRepository;
    private final RideSessionManager sessionManager;
    private final RideWebSocketService rideWebSocketService;
    private final RideService rideService;

    private final ObjectMapper mapper = new ObjectMapper();

    public DriverSocketHandler(DriverLocationService driverLocationService,
            RideSessionManager sessionManager,
            RideWebSocketService rideWebSocketService,
            DriverRepository driverRepository,
            RideService rideService,
            DriverService driverService) {
        this.driverLocationService = driverLocationService;
        this.rideWebSocketService = rideWebSocketService;
        this.sessionManager = sessionManager;
        this.rideService = rideService;
        this.driverRepository = driverRepository;
        this.driverService = driverService;
    }

    @Override
    protected void handleTextMessage(@NonNull WebSocketSession session, @NonNull TextMessage message) {
        try {
            JsonNode json = mapper.readTree(message.getPayload());
            if (!json.has("type"))
                return;

            String type = json.get("type").asText();
            switch (type) {
                case "driverLocation" -> handleDriverLocation(session, json);
                case "counterOffer" -> handleCounterOffer(session, json);
                case "acceptOffer" -> handleAcceptOffer(session, json);
                case "rejectRide" -> handleDriverRejectRide(session, json);
                case "cancelRide" -> handleCancelRide(session, json);
                default -> DebugConsole.methodWarning("WebSocketHandler", "handleMessage",
                        String.format("Unknown message type: %s", type));
            }
        } catch (Exception e) {
            DebugConsole.methodError("WebSocketHandler", "handleMessage",
                    "Failed to process WebSocket message from driver", e);
        }
    }

    /**
     * Handle driver rejecting a ride request or counter-offer
     * This prevents the ride from reappearing to this driver
     * If rejecting during active negotiation, notifies the passenger
     */
    private void handleDriverRejectRide(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "driverId")) {
            sendError(session, "Missing required fields: rideId, driverId");
            return;
        }

        String rideId = json.get("rideId").asText();
        String driverId = json.get("driverId").asText();

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);
        if (offer == null) {
            // Ride may have been accepted/cancelled - silently ignore
            DebugConsole.methodWarning("RideService", "driverRejectRide",
                    String.format("Ride %s not found - may have been resolved", rideId));
            return;
        }

        // Check if this driver is in active negotiation with passenger
        boolean isActiveNegotiation = driverId.equals(offer.getPendingDriverId());

        // Add driver to rejected list for this ride (prevent re-showing)
        offer.addRejectedDriver(driverId);

        // If driver was in active negotiation, notify passenger and reset negotiation state
        if (isActiveNegotiation) {
            offer.setPendingDriverId(null);
            offer.setPrice(offer.getLastPassengerPrice());

            // Notify passenger that driver rejected their counter-offer
            WebSocketSession passengerSession = offer.getPassengerSession();
            if (passengerSession != null && passengerSession.isOpen()) {
                sendDriverRejectionToPassenger(passengerSession, rideId, driverId, offer.getLastPassengerPrice());
            }

            DebugConsole.info("RideRejection",
                    String.format("Driver %s rejected passenger counter-offer for ride %s - passenger notified",
                            driverId, rideId));
        }

        // Send confirmation to driver
        try {
            ObjectNode msg = mapper.createObjectNode();
            msg.put("type", "rideRejected");
            msg.put("rideId", rideId);
            msg.put("message", "Ride request removed from your list");

            session.sendMessage(new TextMessage(msg.toString()));

            DebugConsole.info("RideRejection",
                    String.format("Driver %s rejected ride request %s", driverId, rideId));
        } catch (IOException e) {
            DebugConsole.methodError("DriverService", "sendRideRejection",
                    String.format("Failed to confirm rejection to driver for ride %s", rideId), e);
        }
    }

    // Mise à jour de la position du chauffeur
    private void handleDriverLocation(WebSocketSession session, JsonNode json) {
        String driverId = json.get("driverId").asText();
        double lat = json.get("latitude").asDouble();
        double lng = json.get("longitude").asDouble();

        sessionManager.driverSessions.put(driverId, session);
        driverLocationService.updateDriverLocation(UUID.fromString(driverId), lat, lng, true);
        DebugConsole.locationOperation("UPDATE", driverId, lat, lng);

        // Vérifier les offres actives à proximité
        notifyDriverOfNearbyPassengers(driverId, lat, lng, session);
    }

    /**
     * Notifie le chauffeur des offres actives dans un rayon de 15 km (via H3)
     */
    private void notifyDriverOfNearbyPassengers(String driverId, double driverLat, double driverLng,
            WebSocketSession session) {
        long driverH3 = driverLocationService.getH3Index(driverLat, driverLng, 6);
        Set<Long> nearbyHexagons = driverLocationService.getH3KRing(driverH3, 1);

        sessionManager.activeRideOffers.values().stream()
                .filter(offer -> !offer.isAccepted())
                .filter(offer -> !offer.isRejectedByDriver(driverId))
                .filter(offer -> {
                    Driver driver = driverRepository.findById(UUID.fromString(driverId)).orElse(null);
                    return driver != null
                            && driver.getPassenger() != null
                            && !(offer.getPassengerEntity().getInterfaceType() == InterfaceType.LADIES
                                    && driver.getPassenger().getGender() != GenderLabel.FEMALE)
                            && !(driver.getPassenger().getGender() == GenderLabel.FEMALE
                                    && offer.getPassengerEntity().getGender() != GenderLabel.FEMALE);
                })
                .filter(offer -> offer.getH3Neighbors().stream().anyMatch(nearbyHexagons::contains))
                .forEach(offer -> {
                    try {
                        ObjectNode msg = mapper.createObjectNode();
                        msg.put("type", "rideRequest");
                        msg.put("rideId", offer.getRideId());

                        // Passenger info
                        ObjectNode passengerNode = mapper.createObjectNode();
                        if (offer.getPassengerEntity() != null) {
                            passengerNode.put("id", offer.getPassengerEntity().getId().toString());
                            passengerNode.put("firstName", offer.getPassengerEntity().getFirstName());
                            passengerNode.put("lastName", offer.getPassengerEntity().getLastName());

                            passengerNode.put("profilePicture",
                                    ConvertToURL.convert(offer.getPassengerEntity().getProfilePicture()));

                            passengerNode.put("rating", offer.getPassengerEntity().getRating());
                            passengerNode.put("totalRides", offer.getPassengerEntity().getTotalRides());

                        } else {
                            passengerNode.put("id", offer.getPassengerId());
                            passengerNode.put("firstName", "");
                            passengerNode.put("lastName", "");
                            passengerNode.put("rating", 0.0);
                            passengerNode.put("totalRides", 0);
                        }
                        msg.set("passenger", passengerNode);

                        // Location information
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
                        // Ride info
                        msg.put("price", offer.getPrice());
                        msg.put("rideType", offer.getRideType() != null ? offer.getRideType() : "");
                        msg.put("vehicleType", offer.getVehicleType() != null ? offer.getVehicleType() : "");
                        msg.put("seats", offer.getSeats());
                        msg.put("distanceKm", offer.getDistanceKm());
                        msg.put("estimatedTime", offer.getEstimatedTime() != null ? offer.getEstimatedTime() : "");
                        msg.put("paymentType", offer.getPaymentType() != null ? offer.getPaymentType().name() : "");

                        session.sendMessage(new TextMessage(msg.toString()));
                        DebugConsole.info("NearbyRide",
                                String.format("Sent nearby ride %s to driver %s", offer.getRideId(), driverId));
                    } catch (IOException e) {
                        DebugConsole.methodError("notifyDriverOfNearbyPassengers",
                                String.format("Failed to send ride offer %s to driver %s", offer.getRideId(), driverId),
                                e);
                    }
                });
    }

    private ObjectNode createLocationNode(String address, double lat, double lng, String city) {
        ObjectNode node = mapper.createObjectNode();
        node.put("address", address != null ? address : "");
        node.put("latitude", lat);
        node.put("longitude", lng);
        node.put("city", city != null ? city : "");
        return node;
    }

    // Chauffeur envoie une contre-offre
    private void handleCounterOffer(WebSocketSession session, JsonNode json) throws IOException {
        String rideId = json.get("rideId").asText();
        String driverId = json.get("driverId").asText();
        double counterPrice = json.get("newPrice").asDouble();

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);

        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        if (offer.isAccepted()) {
            sendError(session, "Ride already accepted");
            return;
        }

        // SIMPLIFIED: Update price directly
        offer.setPrice(counterPrice);
        offer.setPendingDriverId(driverId);

        sendCounterOfferToPassenger(offer, driverId);

        // Confirm to driver that counter-offer was sent
        sendDriverOfferAcknowledgment(session, rideId, "counter");

        DebugConsole.info("Counter Offer",
                String.format("Driver %s sent counter offer %.2f for ride %s - awaiting passenger acceptance",
                        driverId, counterPrice, rideId));
    }

    private void handleAcceptOffer(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "driverId")) {
            sendError(session, "Missing required fields: rideId, driverId");
            return;
        }

        String rideId = json.get("rideId").asText();
        String driverId = json.get("driverId").asText();

        DebugConsole.info("Ride Acceptance",
                String.format("Driver %s attempting to accept ride %s", driverId, rideId));

        RideOffer offer = sessionManager.activeRideOffers.get(rideId);
        if (offer == null) {
            DebugConsole.methodError("DriverSocketHandler: findRideOffer",
                    String.format("Ride offer %s not found in activeRideOffers", rideId));
            sendError(session, "Ride offer not found");
            return;
        }

        if (offer.isAccepted()) {
            DebugConsole.methodWarning("RideService", "processRide",
                    String.format("Ride %s already accepted", rideId));
            sendError(session, "Ride already accepted");
            return;
        }

        // Driver accepts at current price (no need to set pending price)
        offer.setPendingDriverId(driverId);

        log.debug("Ride {} pending driver set to {}. Passenger session: {}",
                rideId, driverId,
                offer.getPassengerSession() != null ? "exists" : "NULL");

        // Send driver offer to passenger with full driver details
        sendDriverOfferToPassenger(offer, driverId);

        // Confirm to driver that offer was sent to passenger
        sendDriverOfferAcknowledgment(session, rideId, "accept");

        DebugConsole.methodSuccess("RideSessionManager", "acceptRide",
                String.format("Driver %s accepted ride %s at price %.2f - awaiting passenger acceptance",
                        driverId, rideId, offer.getPrice()));
    }

    private void sendDriverOfferToPassenger(RideOffer offer, String driverId) {
        if (offer.getPassengerSession() == null || !offer.getPassengerSession().isOpen()) {
            return;
        }

        try {
            ObjectNode msg = mapper.createObjectNode();
            msg.put("type", "driverOffer");
            msg.put("rideId", offer.getRideId());
            msg.put("driverId", driverId);
            msg.put("price", offer.getPrice());
            msg.put("offerType", "accept");

            // Add complete driver details
            DriverResponse driverInfo = driverService.getDriverBasicInfo(UUID.fromString(driverId));
            msg.set("driver", createDriverNode(driverInfo));

            offer.getPassengerSession().sendMessage(new TextMessage(msg.toString()));
            log.debug("Sent driver {} offer to passenger for ride {}", driverId, offer.getRideId());
        } catch (Exception e) {
            DebugConsole.methodError("DriverService", "sendDriverOffer",
                    String.format("Failed to send driver offer to passenger for ride %s", offer.getRideId()), e);
        }
    }

    // Annulation de la course

    @Transactional
    private void handleCancelRide(WebSocketSession session, JsonNode json) {
        if (!validateRequiredFields(json, "rideId", "userId")) {
            sendError(session, "Missing required fields: rideId, userId");
            return;
        }

        String rideId = json.get("rideId").asText();
        String driverId = json.get("userId").asText();

        RideOffer offer = sessionManager.activeRideOffers.remove(rideId);
        if (offer == null) {
            sendError(session, "Ride offer not found");
            return;
        }

        // Notify passenger
        WebSocketSession passengerSession = sessionManager.passengerSessions.get(offer.getPassengerId());
        if (passengerSession != null && passengerSession.isOpen()) {
            rideWebSocketService.sendCancellationNotification(passengerSession, rideId, driverId);
        }

        // Broadcast cancellation to nearby drivers (so others may receive the ride
        // again)
        rideWebSocketService.broadcastRideCancellationToNearbyDrivers(offer, driverId);

        // Confirm cancellation to driver
        rideWebSocketService.sendCancellationNotification(session, rideId, driverId);

        // Update database if ride was accepted
        if (offer.isAccepted()) {
            rideService.updateRideStatus(UUID.fromString(rideId), RideStatus.CANCELED);
        }

        DebugConsole.methodWarning("RideSessionManager", "cancelRide",
                String.format("Ride %s cancelled by driver %s", rideId, driverId));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessionManager.driverSessions.values().removeIf(s -> s.getId().equals(session.getId()));
        DebugConsole.info("WebSocket", String.format("Driver disconnected: %s", session.getId()));
    }

    private void sendDriverOfferAcknowledgment(WebSocketSession session, String rideId, String offerType) {
        try {
            ObjectNode msg = mapper.createObjectNode();
            msg.put("type", "offerSent");
            msg.put("rideId", rideId);
            msg.put("offerType", offerType);
            msg.put("message", "Your offer has been sent to the passenger. Waiting for their response.");

            session.sendMessage(new TextMessage(msg.toString()));
        } catch (IOException e) {
            DebugConsole.methodError("DriverService", "sendOfferAcknowledgment",
                    String.format("Failed to send offer acknowledgment for ride %s", rideId), e);
        }
    }

    private void sendCounterOfferToPassenger(RideOffer offer, String driverId) {
        if (offer.getPassengerSession() == null || !offer.getPassengerSession().isOpen()) {
            return;
        }

        try {
            ObjectNode msg = mapper.createObjectNode();
            msg.put("type", "driverOffer");
            msg.put("rideId", offer.getRideId());
            msg.put("driverId", driverId);
            msg.put("price", offer.getPrice());
            msg.put("offerType", "counter");

            // Add complete driver details
            DriverResponse driverInfo = driverService.getDriverBasicInfo(UUID.fromString(driverId));
            msg.set("driver", createDriverNode(driverInfo));

            offer.getPassengerSession().sendMessage(new TextMessage(msg.toString()));
            log.debug("Sent driver {} counter-offer of {} DH to passenger for ride {}",
                    driverId, offer.getPrice(), offer.getRideId());
        } catch (Exception e) {
            DebugConsole.methodError("DriverService", "sendCounterOffer",
                    String.format("Failed to send counter offer to passenger for ride %s", offer.getRideId()), e);
        }
    }

    private ObjectNode createDriverNode(DriverResponse driverInfo) {
        ObjectNode driverNode = mapper.createObjectNode();
        driverNode.put("id", driverInfo.getId().toString());
        driverNode.put("firstName", driverInfo.getFirstName());
        driverNode.put("lastName", driverInfo.getLastName());
        driverNode.put("profilePicture", driverInfo.getProfilePicture());
        driverNode.put("rating", driverInfo.getRating());
        driverNode.put("totalRides", driverInfo.getTotalRides());
        driverNode.put("isVerified", driverInfo.isVerified());

        // Convert VehicleType enum to String
        driverNode.put("vehicleType",
                driverInfo.getVehicleType() != null ? driverInfo.getVehicleType().toString() : null);

        driverNode.put("vehicleBrand", driverInfo.getVehicleBrand());
        driverNode.put("vehicleModel", driverInfo.getVehicleModel());
        driverNode.put("vehicleColor", driverInfo.getVehicleColor());
        return driverNode;
    }

    /**
     * Notifies passenger that driver rejected their counter-offer
     */
    private void sendDriverRejectionToPassenger(WebSocketSession passengerSession, String rideId,
            String driverId, double restoredPrice) {
        try {
            ObjectNode msg = mapper.createObjectNode();
            msg.put("type", "driverRejected");
            msg.put("rideId", rideId);
            msg.put("driverId", driverId);
            msg.put("restoredPrice", restoredPrice);
            msg.put("message", "Driver declined your counter-offer. Waiting for other drivers.");

            passengerSession.sendMessage(new TextMessage(msg.toString()));

            DebugConsole.methodSuccess("DriverService", "notifyPassengerOfRejection",
                    String.format("Passenger notified of driver rejection for ride %s", rideId));
        } catch (IOException e) {
            DebugConsole.methodError("DriverService", "sendDriverRejectionToPassenger",
                    String.format("Failed to notify passenger of driver rejection for ride %s", rideId), e);
        }
    }

    private boolean validateRequiredFields(JsonNode json, String... fields) {
        for (String field : fields) {
            if (!json.has(field)) {
                return false;
            }
        }
        return true;
    }

    private void sendError(WebSocketSession session, String error) {
        if (session != null && session.isOpen()) {
            try {
                ObjectNode msg = mapper.createObjectNode();
                msg.put("type", "error");
                msg.put("message", error);
                session.sendMessage(new TextMessage(msg.toString()));
            } catch (IOException e) {
                DebugConsole.methodError("WebSocketHandler", "sendErrorMessage", "Failed to send error message", e);
            }
        }
    }
}