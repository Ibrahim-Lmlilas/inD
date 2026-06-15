package com.srrfrr.api.configurations;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
			return new BCryptPasswordEncoder();
    }

    @Bean
    @Order(1)
    public SecurityFilterChain internalSecurityFilterChain(final HttpSecurity http, final JwtAuthFilter jwtAuthFilter) throws Exception {
        http
					.securityMatcher("/api/internal/**")
					.csrf(csrf -> csrf.disable())
					.sessionManagement(session -> session
						.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
					.authorizeHttpRequests(auth -> auth
						.requestMatchers("/api/internal/**").authenticated()
						.anyRequest().permitAll()
					)
					.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    @Order(2)
    public SecurityFilterChain apiSecurityFilterChain(final HttpSecurity http,final JwtAuthFilter jwtAuthFilter) throws Exception {
        http
					.securityMatcher("/api/**")
					.csrf(AbstractHttpConfigurer::disable)
					.cors(Customizer.withDefaults())
					.sessionManagement(session -> session
						.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
					)
					.authorizeHttpRequests(auth -> auth
						.requestMatchers("/api/internal/**").denyAll()
						.anyRequest().permitAll()
					)
					.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
