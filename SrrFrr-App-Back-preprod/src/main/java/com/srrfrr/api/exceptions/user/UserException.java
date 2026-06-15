
package com.srrfrr.api.exceptions.user;

/**
 * Base exception for all user-related errors.
 */
public abstract class UserException extends RuntimeException {
    protected UserException(String message) {
        super(message);
    }

    protected UserException(String message, Throwable cause) {
        super(message, cause);
    }
}