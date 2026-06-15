package com.srrfrr.api.exceptions;

import com.srrfrr.api.dto.exception.ErrorResponseDto;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.servlet.NoHandlerFoundException;


@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(5)
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseException.class)
    public ResponseEntity<Object> handleBaseException(final BaseException ex, final ServletWebRequest request) {
        ExceptionLoggingHelper.log(ex, request);
        final ErrorResponseDto response = ErrorResponseDto.builder()
                .errorCode(ex.getErrorCode().value())
                .httpStatusCode(ex.getHttpStatus().value())
                .errorMetadata(ex.getErrorMetadata())
                .message(ex.getMessage())
                .build();
        return ResponseEntity.status(ex.getHttpStatus()).body(response);
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ErrorDetails> handleNotFound(final NoHandlerFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorDetails("NOT_FOUND", "Endpoint not found", null));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorDetails> handleMethodNotSupported(final HttpRequestMethodNotSupportedException ex) {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(new ErrorDetails("METHOD_NOT_ALLOWED", "HTTP method not supported for this endpoint", null));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorDetails> handleRuntimeException(final RuntimeException ex) {
        if (ex.getMessage().contains("not found")) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    new ErrorDetails("NOT_FOUND", ex.getMessage(), null)
            );
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                new ErrorDetails("BAD_REQUEST", ex.getMessage(), null)
        );
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorDetails> handleGeneric(final Exception ex) {
        log.error("Unhandled exception: ", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorDetails("INTERNAL_ERROR", "Unexpected error occurred", null));
    }
}
