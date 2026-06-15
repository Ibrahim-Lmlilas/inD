package com.srrfrr.api.exceptions.authentication;

import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;
import org.springframework.http.HttpStatus;

public class SamePhoneNumberException extends BaseException {

    public SamePhoneNumberException() {
        super(
                ErrorCode.from("PHONE_NUMBER_SAME"),
                HttpStatus.BAD_REQUEST,
                ErrorMessage.from("The new phone number is the same as the current one. No OTP sent.")
        );
    }
}
