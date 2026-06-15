package com.srrfrr.api.dto.subscription;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubscribeDriverRequest {

    @NotBlank(message = "Plan type is required")
    @Pattern(regexp = "PRO|PREMIUM|BASIC", message = "Plan type must be PRO, PREMIUM, or BASIC")
    private String planType;

}