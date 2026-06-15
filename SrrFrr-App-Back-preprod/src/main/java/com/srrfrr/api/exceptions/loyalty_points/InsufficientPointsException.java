package com.srrfrr.api.exceptions.loyalty_points;

public class InsufficientPointsException extends RuntimeException {
	public InsufficientPointsException(String message) {
		super(message);
	}
}