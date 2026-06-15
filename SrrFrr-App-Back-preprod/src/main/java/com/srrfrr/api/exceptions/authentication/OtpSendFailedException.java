package com.srrfrr.api.exceptions.authentication;


import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;
import org.springframework.http.HttpStatus;

public class OtpSendFailedException extends BaseException {
    public OtpSendFailedException(final Exception cause) {
        super(
                ErrorCode.from("OTP_SEND_FAILED"),
                HttpStatus.INTERNAL_SERVER_ERROR,
                ErrorMessage.from("Failed to send OTP. Please try again."),
                cause,
                null
        );
    }
}

