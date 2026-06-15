package com.srrfrr.api.exceptions.chat;

import com.srrfrr.api.dto.exception.ErrorResponse;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Exception handler for chat-related exceptions.
 * Handles exceptions from the chat package with appropriate HTTP status codes.
 */
@Slf4j
@RestControllerAdvice
@NoArgsConstructor
@Order(5)
public class ChatExceptionHandler {

    // ==================== Not Found Exceptions (404) ====================

    @ExceptionHandler(ChatChannelNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleChatChannelNotFound(final ChatChannelNotFoundException ex) {
        log.warn("Chat channel not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(ChatMessageNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleChatMessageNotFound(final ChatMessageNotFoundException ex) {
        log.warn("Chat message not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND));
    }

    // ==================== Authorization Exceptions (403) ====================

    @ExceptionHandler(UnauthorizedChatAccessException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorizedChatAccess(final UnauthorizedChatAccessException ex) {
        log.warn("Unauthorized chat access: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.FORBIDDEN));
    }

    // ==================== Validation Exceptions (400) ====================

    @ExceptionHandler(InvalidMessageException.class)
    public ResponseEntity<ErrorResponse> handleInvalidMessage(final InvalidMessageException ex) {
        log.warn("Invalid message: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(ChatChannelAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleChatChannelAlreadyExists(final ChatChannelAlreadyExistsException ex) {
        log.warn("Chat channel already exists: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ErrorResponse(ex.getMessage(), HttpStatus.CONFLICT));
    }

    // ==================== Generic Chat Exception (500) ====================

    @ExceptionHandler(ChatException.class)
    public ResponseEntity<ErrorResponse> handleChatException(final ChatException ex) {
        log.error("Chat exception: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("A chat error occurred. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR));
    }
}