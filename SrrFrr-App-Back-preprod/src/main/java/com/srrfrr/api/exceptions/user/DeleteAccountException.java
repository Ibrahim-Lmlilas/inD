package com.srrfrr.api.exceptions.user;

/**
 * Thrown when a user account has failed to be deleted
 */

public class DeleteAccountException extends UserException {
	public DeleteAccountException(String message) {
		super(message);
	}

	public DeleteAccountException(String passengerId, boolean IsConfirmed) {
		super(String.format("Action not permitted for user with ID: %s", passengerId));
	}
}
