package com.srrfrr.api.dto.exception;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ErrorResponseDto {
    private String errorCode;
    private String message;
    private int httpStatusCode;
    private Object errorMetadata;
}
