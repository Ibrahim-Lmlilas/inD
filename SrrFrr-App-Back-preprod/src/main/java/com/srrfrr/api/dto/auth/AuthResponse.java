package com.srrfrr.api.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.UUID;

@Data
@AllArgsConstructor
public class AuthResponse {

    private UUID id;
    private String message;
    private String accessToken;
    private String refreshToken;
}
