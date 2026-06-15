package com.srrfrr.api.websocket;

import com.srrfrr.api.websocket.handler.*;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
@EnableScheduling
public class WebSocketConfig implements WebSocketConfigurer {

    private final PassengerSocketHandler passengerSocketHandler;
    private final DriverSocketHandler driverSocketHandler;
    private final RideTrackingSocketHandler rideTrackingSocketHandler;
    private final ChatSocketHandler chatSocketHandler;
    private final NotificationSocketHandler notificationSocketHandler;

    public WebSocketConfig(DriverSocketHandler driverSocketHandler,
                        PassengerSocketHandler passengerSocketHandler,
                        NotificationSocketHandler notificationSocketHandler,
                        RideTrackingSocketHandler rideTrackingSocketHandler,
                        ChatSocketHandler chatSocketHandler) {
        this.chatSocketHandler = chatSocketHandler;
        this.driverSocketHandler = driverSocketHandler;
        this.passengerSocketHandler = passengerSocketHandler;
        this.rideTrackingSocketHandler = rideTrackingSocketHandler;
        this.notificationSocketHandler = notificationSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(driverSocketHandler, "/ws/driver")
                .setAllowedOriginPatterns("*");

        registry.addHandler(passengerSocketHandler, "/ws/passenger")
                .setAllowedOriginPatterns("*");

        registry.addHandler(chatSocketHandler, "/ws/chat")
                .setAllowedOriginPatterns("*");

        registry.addHandler(rideTrackingSocketHandler, "/ws/tracking/{rideId}")
                .setAllowedOriginPatterns("*");

        registry.addHandler(notificationSocketHandler, "/notifications/{notificationsId}")
                .setAllowedOrigins("*");
    }
}