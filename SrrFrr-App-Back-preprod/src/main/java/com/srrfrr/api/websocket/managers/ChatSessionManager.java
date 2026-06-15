package com.srrfrr.api.websocket.managers;

import com.srrfrr.api.utils.DebugConsole;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

@Component
@Slf4j
public class ChatSessionManager {

    // User ID -> WebSocket Session mapping
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();

    // Session ID -> User ID mapping (for quick lookup)
    private final Map<String, String> sessionToUser = new ConcurrentHashMap<>();

    // User ID -> User Type mapping
    private final Map<String, String> userTypes = new ConcurrentHashMap<>();

    // User ID -> Set of active channel IDs
    private final Map<String, Set<String>> userChannels = new ConcurrentHashMap<>();

    /**
     * Adds a user session to the manager.
     *
     * @param userId   User ID
     * @param session  WebSocket session
     * @param userType User type (driver/passenger)
     */
    public void addSession(String userId, WebSocketSession session, String userType) {
        userSessions.put(userId, session);
        sessionToUser.put(session.getId(), userId);
        userTypes.put(userId, userType);
        userChannels.putIfAbsent(userId, new CopyOnWriteArraySet<>());

        DebugConsole.debugData("ChatSessionManager", "User session added",
                String.format("User %s (%s) - Total sessions: %d", userId, userType, userSessions.size()));
    }

    /**
     * Removes a session from the manager.
     *
     * @param sessionId WebSocket session ID
     */
    public void removeSession(String sessionId) {
        String userId = sessionToUser.remove(sessionId);
        if (userId != null) {
            userSessions.remove(userId);
            userTypes.remove(userId);
            userChannels.remove(userId);

            DebugConsole.debugData("ChatSessionManager", "User session removed",
                    String.format("User %s - Total sessions: %d", userId, userSessions.size()));
        }
    }

    /**
     * Gets user ID by session ID.
     *
     * @param sessionId WebSocket session ID
     * @return User ID or null if not found
     */
    public String getUserIdBySession(String sessionId) {
        return sessionToUser.get(sessionId);
    }

    /**
     * Gets WebSocket session by user ID.
     *
     * @param userId User ID
     * @return WebSocket session or null if not found
     */
    public WebSocketSession getSessionByUserId(String userId) {
        return userSessions.get(userId);
    }

    /**
     * Adds a channel to user's active channels.
     *
     * @param userId    User ID
     * @param channelId Channel ID
     */
    public void addUserChannel(String userId, String channelId) {
        userChannels.computeIfAbsent(userId, k -> new CopyOnWriteArraySet<>())
                .add(channelId);
    }

    /**
     * Removes a channel from user's active channels.
     *
     * @param userId    User ID
     * @param channelId Channel ID
     */
    public void removeUserChannel(String userId, String channelId) {
        Set<String> channels = userChannels.get(userId);
        if (channels != null) {
            channels.remove(channelId);
        }
    }

    /**
     * Gets all active channels for a user.
     *
     * @param userId User ID
     * @return Set of channel IDs
     */
    public Set<String> getUserChannels(String userId) {
        return userChannels.getOrDefault(userId, Set.of());
    }

    /**
     * Gets user type (driver/passenger).
     *
     * @param userId User ID
     * @return User type or null if not found
     */
    public String getUserType(String userId) {
        return userTypes.get(userId);
    }

    /**
     * Checks if a user is currently online.
     *
     * @param userId User ID
     * @return true if user is online, false otherwise
     */
    public boolean isUserOnline(String userId) {
        WebSocketSession session = userSessions.get(userId);
        return session != null && session.isOpen();
    }

    /**
     * Gets all online user IDs.
     *
     * @return Set of online user IDs
     */
    public Set<String> getOnlineUsers() {
        return userSessions.keySet();
    }

    /**
     * Gets active session count.
     *
     * @return Number of active sessions
     */
    public int getActiveSessionCount() {
        return (int) userSessions.values().stream()
                .filter(session -> session != null && session.isOpen())
                .count();
    }

    /**
     * Clean up closed WebSocket sessions periodically.
     */
    @Scheduled(fixedRate = 30000) // Every 30 seconds
    public void cleanupClosedSessions() {
        int removed = 0;

        for (Map.Entry<String, WebSocketSession> entry : userSessions.entrySet()) {
            WebSocketSession session = entry.getValue();
            if (session == null || !session.isOpen()) {
                removeSession(session.getId());
                removed++;
            }
        }

        if (removed > 0) {
            DebugConsole.info("ChatSessionCleanup",
                    String.format("Cleaned up %d closed chat sessions", removed));
        }
    }

    /**
     * Log session statistics periodically.
     */
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void logStatistics() {
        int activeSessions = getActiveSessionCount();
        int onlineUsers = getOnlineUsers().size();

        DebugConsole.sessionStats("ChatWebSocket", activeSessions, onlineUsers, 0);
    }
}
