package com.srrfrr.api.exceptions.authentication;

import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;
import org.springframework.http.HttpStatus;

public class InvalidTokenException extends BaseException {
    public InvalidTokenException(final String message) {
        super(ErrorCode.from("INVALID_TOKEN"), HttpStatus.UNAUTHORIZED, ErrorMessage.from(message));
    }
}
