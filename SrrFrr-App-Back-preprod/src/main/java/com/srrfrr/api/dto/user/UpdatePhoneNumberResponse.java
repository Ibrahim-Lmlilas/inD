package com.srrfrr.api.dto.user;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UpdatePhoneNumberResponse {
    private String phoneNumber;
    private String message;
}
