package com.srrfrr.api.exceptions.authentication;

import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;
import org.springframework.http.HttpStatus;

public class AlreadyAuthenticatedException extends BaseException {
    public static final ErrorCode CODE = ErrorCode.from("ALREADY_AUTHENTICATED");

    public AlreadyAuthenticatedException(final String message) {
        super(CODE, HttpStatus.CONFLICT, ErrorMessage.from(message));
    }
}
