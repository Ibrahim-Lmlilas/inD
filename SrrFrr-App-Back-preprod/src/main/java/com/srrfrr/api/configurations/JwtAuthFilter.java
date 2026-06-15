package com.srrfrr.api.configurations;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.srrfrr.api.entities.main.Authentication;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.exceptions.ErrorDetails;
import com.srrfrr.api.exceptions.authentication.InvalidTokenException;
import com.srrfrr.api.repositories.main.AuthenticationRepository;
import com.srrfrr.api.services.auth.TokenService;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Value("${jwt.internal}")
    private String secret;

    private final TokenService tokenService;
    private final AuthenticationRepository authRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    final Logger log = Logger.getLogger(JwtAuthFilter.class.getName());

    public JwtAuthFilter(final TokenService tokenService,
                         final AuthenticationRepository authRepository) {
        super();
        this.tokenService = tokenService;
        this.authRepository = authRepository;
    }

    @Override
    protected void doFilterInternal(final HttpServletRequest request,
                                    final HttpServletResponse response,
                                    final FilterChain filterChain) throws ServletException, IOException {

        log.info("Processing request: " + request.getRequestURI());

        final String authHeader = request.getHeader("Authorization");
        final boolean isInternalEndpoint = request.getRequestURI().startsWith("/api/internal/");

        if (isInternalEndpoint) {
            handleInternalEndpoint(request, response, filterChain, authHeader);
        } else {
            handleRegularEndpoint(request, response, filterChain, authHeader);
        }
    }

    private void handleInternalEndpoint(final HttpServletRequest request, final HttpServletResponse response,
                                        final FilterChain filterChain, final String authHeader)
            throws IOException {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Authorization header required");
            return;
        }

        try {
            final String token = authHeader.substring(7);
            final SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

            final Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            final String username = claims.getSubject();
            final String type = (String) claims.get("type");

            if ("service".equals(type)) {
                final UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        username, null, List.of(new SimpleGrantedAuthority("ROLE_SERVICE")));
                SecurityContextHolder.getContext().setAuthentication(authToken);
                filterChain.doFilter(request, response);
            } else {
                sendError(response, HttpServletResponse.SC_FORBIDDEN, "Invalid token type for internal endpoint");
            }
        } catch (Exception e) {
            sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Invalid token");
        }
    }

    private void handleRegularEndpoint(final HttpServletRequest request,
                                       final HttpServletResponse response,
                                       final FilterChain filterChain,
                                       final String authHeader)
            throws ServletException, IOException {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                filterChain.doFilter(request, response);
                return;
            }

            final String token = authHeader.substring(7);

            if (!tokenService.isTokenValid(token)) {
                filterChain.doFilter(request, response);
                return;
            }

            final Claims claims = tokenService.validateAndExtractClaims(token);
            final String userId = claims.getSubject();
            final String tokenDeviceId = claims.get("deviceId", String.class);

            final Authentication auth = authRepository.findByPassengerId(UUID.fromString(userId)).orElse(null);

            if (auth == null || !auth.getDeviceId().equals(tokenDeviceId)) {
                throw new InvalidTokenException("Access token is invalid: used from a different device");
            }

            final Passenger userDetails = auth.getPassenger();

            final UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities());
            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authToken);

            filterChain.doFilter(request, response);

        } catch (InvalidTokenException ex) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");

            final ErrorDetails errorDetails = new ErrorDetails(
                    "INVALID_TOKEN",
                    ex.getMessage(),
                    "The token was rejected due to device mismatch"
            );

            final String json = objectMapper.writeValueAsString(errorDetails);
            response.getWriter().write(json);
        }
    }

    private void sendError(final HttpServletResponse response, final int status, final String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"" + message + "\"}");
    }
}