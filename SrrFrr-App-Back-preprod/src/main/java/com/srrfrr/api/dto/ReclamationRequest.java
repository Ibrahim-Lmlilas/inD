package com.srrfrr.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.UUID;

import com.srrfrr.api.enums.Reclamation.CategoryReclamation;

@Data
public class ReclamationRequest {
    @NotBlank(message = "Content cannot be null")
    @Size(min = 10, max = 500, message = "Content must be between 10 and 500 characters")
    private String content;

    @NotNull(message = "category cannot be null")
    private CategoryReclamation category;

    private UUID rideId;
}
