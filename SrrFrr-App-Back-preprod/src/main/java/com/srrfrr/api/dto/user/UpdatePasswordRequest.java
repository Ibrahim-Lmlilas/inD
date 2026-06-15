package com.srrfrr.api.dto.user;

import com.srrfrr.api.annotations.ValidPassword;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdatePasswordRequest {

    @NotBlank(message = "Current password cannot be null")
    private String currentPassword;

    @ValidPassword
    private String newPassword;

    @ValidPassword
    private String confirmNewPassword;
}
