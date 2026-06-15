package com.srrfrr.api.exceptions.wallet;

import org.springframework.http.HttpStatus;

import com.srrfrr.api.exceptions.BaseException;
import com.srrfrr.api.exceptions.ErrorCode;
import com.srrfrr.api.exceptions.ErrorMessage;

public class WalletNotFoundException extends BaseException { // to remove
    private static final ErrorCode ERROR_CODE = ErrorCode.from("wallet_not_found");
    private static final HttpStatus HTTP_STATUS = HttpStatus.NOT_FOUND;
    private static final ErrorMessage DEFAULT_MESSAGE = ErrorMessage.from("Wallet not found");

    public WalletNotFoundException(final String username) {
        this(DEFAULT_MESSAGE, username);
    }

    public WalletNotFoundException(final ErrorMessage message) {
        this(message, null);
    }


    public WalletNotFoundException(final ErrorMessage message, final String id){
        super(ERROR_CODE, HTTP_STATUS, message, new WalletNotFoundMetadata(id));
    }

    private record WalletNotFoundMetadata(String id) {
        public String toString(){return String.format("{id=%s}", id);}
    }
}