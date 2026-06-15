package com.srrfrr.api.exceptions.authentication;


import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;
import org.springframework.http.HttpStatus;


public class OtpRateLimitException extends BaseException {
    public OtpRateLimitException(final String message) {
        super(
                ErrorCode.TOO_MANY_OTP_REQUESTS,
                HttpStatus.TOO_MANY_REQUESTS,
                ErrorMessage.from(message)
        );
    }
}


