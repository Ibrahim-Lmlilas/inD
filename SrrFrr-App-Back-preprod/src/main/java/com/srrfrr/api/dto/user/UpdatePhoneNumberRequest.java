package com.srrfrr.api.dto.user;

import com.srrfrr.api.annotations.ValidPhoneNumber;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UpdatePhoneNumberRequest {
    @ValidPhoneNumber
    private String phoneNumber;

    @NotBlank(message = "Password cannot be null")
    private String password;
}
