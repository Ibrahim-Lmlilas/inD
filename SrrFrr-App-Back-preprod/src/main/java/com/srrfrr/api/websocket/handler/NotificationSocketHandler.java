package com.srrfrr.api.websocket.handler;

import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriTemplate;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Configuration
@EnableScheduling
@NoArgsConstructor
public class NotificationSocketHandler extends TextWebSocketHandler {
    private static final Map<String, WebSocketSession> USERS = new ConcurrentHashMap<>();
    private static final Map<String, Long> LAST_PONG_TIMES = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(final WebSocketSession session) throws Exception {
        final String userId = extractUserId(session);

        if (userId == null) {
            session.close(CloseStatus.BAD_DATA);
            return;
        }
        USERS.computeIfAbsent(userId, k -> session);
        LAST_PONG_TIMES.put(session.getId(), System.currentTimeMillis());
        log.info("WebSocket connecté : userId={}", userId);
    }


    @Override
    protected void handleTextMessage(final WebSocketSession session, final TextMessage message) throws IOException {
        final String payload = message.getPayload();

        if ("pong".equalsIgnoreCase(payload)) {
            LAST_PONG_TIMES.put(session.getId(), System.currentTimeMillis());
            return;
        }

        final String userId = extractUserId(session);
        final WebSocketSession userSessions = USERS.get(userId);
        if (userSessions != null && userSessions.isOpen()) {
            userSessions.sendMessage(message);
        }
    }

    @Override
    public void afterConnectionClosed(final WebSocketSession session, final CloseStatus status) {
        final String userId = extractUserId(session);
        if (userId != null) {
            USERS.remove(userId);
        }

        LAST_PONG_TIMES.remove(session.getId());

        log.info("WebSocket session closed for deviceId={}", userId);
    }

    private String extractUserId(final WebSocketSession session) {
        final String path = session.getUri().getPath();
        final UriTemplate template = new UriTemplate("/notifications/{notificationsId}");
        final Map<String, String> parameters = template.match(path);
        return parameters.get("notificationsId");
    }

    public void broadcastMessage(final String notificationsId, final TextMessage message) throws IOException {
        final WebSocketSession userSessions = USERS.get(notificationsId);
        if (userSessions != null && userSessions.isOpen()) {
            userSessions.sendMessage(message);
        }
    }

    public void sendToDevice(final String userId, final String payload) {
        final WebSocketSession session = USERS.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(payload));
                USERS.remove(userId);
                session.close();
            } catch (IOException e) {
                log.error("Erreur d'envoi WebSocket à l'appareil {}", userId, e);
            }
        } else {
            log.warn("Session non trouvée ou fermée pour l'appareil {}", userId);
        }
    }


//    @Scheduled(fixedRate = 5000) // Every 10 seconds
//    public void sendPingAndCloseUnresponsiveSessions() {
//        final long now = System.currentTimeMillis();
//        final long timeout = 10_000; // 15 seconds allowed for a pong response
//        for (final WebSocketSession sessions : USERS.values()) {
//            if (!sessions.isOpen()) {
//                continue;
//            }
//            final String sessionId = sessions.getId();
//            final Long lastPong = LAST_PONG_TIMES.get(sessionId);
//
//            // If the session hasn't responded within timeout
//            if (lastPong == null || now - lastPong > timeout) {
//                try {
//                    sessions.close(CloseStatus.SESSION_NOT_RELIABLE);
//                } catch (IOException e) {
//                    log.warn("Error closing session: {}", e.getMessage());
//                }
//                continue;
//            }
//
//            // Send ping message
//            try {
//                sessions.sendMessage(new TextMessage("ping"));
//            } catch (IOException e) {
//                log.warn("Failed to send ping to session: {}", e.getMessage());
//            }
//        }
//    }
}