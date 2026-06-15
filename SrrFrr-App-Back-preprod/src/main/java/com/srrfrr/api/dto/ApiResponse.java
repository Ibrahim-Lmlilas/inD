package com.srrfrr.api.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private LocalDateTime timestamp;

    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
            .success(true)
            .data(data)
            .timestamp(LocalDateTime.now())
            .build();
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
            .success(true)
            .message(message)
            .data(data)
            .timestamp(LocalDateTime.now())
            .build();
    }

    public static ApiResponse<Void> error(String message) {
        return ApiResponse.<Void>builder()
            .success(false)
            .message(message)
            .timestamp(LocalDateTime.now())
            .build();
    }

    /**
     * Generic error response for any type.
     * Use this when you need to return an error with a specific generic type.
     * 
     * @param message error message
     * @param <T> the generic type
     * @return error response with null data
     */
    public static <T> ApiResponse<T> errorWithType(String message) {
        return ApiResponse.<T>builder()
            .success(false)
            .message(message)
            .data(null)
            .timestamp(LocalDateTime.now())
            .build();
    }
}
