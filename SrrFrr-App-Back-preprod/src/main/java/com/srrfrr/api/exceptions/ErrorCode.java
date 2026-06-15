package com.srrfrr.api.exceptions;

public record ErrorCode(String value) {
    public static final ErrorCode TOO_MANY_OTP_REQUESTS = new ErrorCode("TOO_MANY_OTP_REQUESTS");

    public static ErrorCode from(final String value){
        return new ErrorCode(value);
    }

}
