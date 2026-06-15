package com.srrfrr.api.dto.otp;

import com.srrfrr.api.annotations.ValidPhoneNumber;
import com.srrfrr.api.enums.user.Language;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class OtpRequest {

    @ValidPhoneNumber
    private String phoneNumber;

    private String otp;

    private Language language;
}