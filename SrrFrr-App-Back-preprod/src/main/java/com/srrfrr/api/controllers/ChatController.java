package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.ApiResponse;
import com.srrfrr.api.dto.chat.ChatMessageResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.chat.ChatService;
import com.srrfrr.api.utils.DebugConsole;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/chat")
public class ChatController {
    private final ChatService chatService;

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;

    public ChatController(final ChatService chatService){
        this.chatService=chatService;
    }

    @GetMapping("/messages/{rideId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRideMessages(
            @PathVariable final UUID rideId,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size,
            @AuthenticationPrincipal final Passenger passenger) {

        // Validate and limit page size
        final int validatedSize = Math.min(size, MAX_PAGE_SIZE);
        
        // Create pageable with descending order (newest first)
        final Pageable pageable = PageRequest.of(
            page, 
            validatedSize, 
            Sort.by(Sort.Direction.DESC, "sentAt")
        );

        final Page<ChatMessageResponse> messagesPage = chatService.getMessagesByRide(
            rideId, 
            passenger.getId(), 
            pageable
        );

        DebugConsole.info("Fetched " + messagesPage.getNumberOfElements() + 
                        " messages for ride " + rideId);

        // Create a flatter response structure
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("messages", messagesPage.getContent());
        response.put("last", messagesPage.isLast());
        response.put("first", messagesPage.isFirst());
        response.put("totalPages", messagesPage.getTotalPages());
        response.put("totalElements", messagesPage.getTotalElements());
        response.put("currentPage", page);
        response.put("pageSize", validatedSize);

        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
