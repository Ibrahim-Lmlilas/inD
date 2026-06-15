package com.srrfrr.api.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
@Data
@NoArgsConstructor
public class SuccessResponse {
    private String message;
    private int status;
    private LocalDateTime timestamp;

    public SuccessResponse(String message, int status) {
        this.message = message;
        this.status = status;
        this.timestamp = LocalDateTime.now();
    }
}
