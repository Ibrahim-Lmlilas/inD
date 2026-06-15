package com.srrfrr.api.services.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class TokenService {
    private final Key signingKey;
    private static final long ACCESS_TOKEN_VALIDITY = 1000L * 60 * 60 * 24 * 7; // 7 days
    private static final long REFRESH_TOKEN_VALIDITY = 1000L * 60 * 60 * 24 * 30; // 30 days
    private static final long WS_TOKEN_VALIDITY = 1000L * 60 * 60; // 1 hour

    public TokenService(@Value("${jwt.secret}") String secret) {
        this.signingKey = Keys.hmacShaKeyFor(secret.getBytes());
    }

    /**
     * Generate access token (HTTP API)
     */
    public String generateAccessToken(String phoneNumber, String userId, String deviceId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("phoneNumber", phoneNumber);
        claims.put("deviceId", deviceId);
        claims.put("type", "access");

        return buildToken(claims, userId, ACCESS_TOKEN_VALIDITY);
    }

    /**
     * Generate refresh token
     */
    public String generateRefreshToken(String phoneNumber, String userId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("phoneNumber", phoneNumber);
        claims.put("type", "refresh");

        return buildToken(claims, userId, REFRESH_TOKEN_VALIDITY);
    }

    /**
     * Generate WebSocket token (for chat connections)
     */
    public String generateWebSocketToken(String userId, String channelId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("channelId", channelId);
        claims.put("type", "websocket");

        return buildToken(claims, userId, WS_TOKEN_VALIDITY);
    }

    /**
     * Validate and extract claims
     */
    public Claims validateAndExtractClaims(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(signingKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    /**
     * Check if token is valid and not expired
     */
    public boolean isTokenValid(String token) {
        try {
            Claims claims = validateAndExtractClaims(token);
            return !claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    private String buildToken(Map<String, Object> claims, String subject, long validity) {
        return Jwts.builder()
            .setClaims(claims)
            .setSubject(subject)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + validity))
            .signWith(signingKey, SignatureAlgorithm.HS256)
            .compact();
    }
}