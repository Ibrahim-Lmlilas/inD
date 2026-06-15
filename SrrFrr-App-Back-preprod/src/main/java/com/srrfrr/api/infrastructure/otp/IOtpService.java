package com.srrfrr.api.infrastructure.otp;

import com.srrfrr.api.dto.otp.OtpRequest;

/**
 * OTP service interface for generating and validating OTPs.
 * Implementations handle different environments (dev vs prod).
 */
public interface IOtpService {

	/**
	 * Generate and send OTP to the provided phone number.
	 * 
	 * @param request OTP request containing phone number
	 * @return true if OTP was sent successfully
	 */
	boolean generateAndSendOtp(OtpRequest request);

	/**
	 * Validate OTP without deleting it.
	 * 
	 * @param phoneNumber the phone number
	 * @param otpCode     the OTP code to validate
	 * @return true if OTP is valid
	 */
	boolean isOtpValid(String phoneNumber, String otpCode);

	/**
	 * Validate OTP and delete if valid.
	 * 
	 * @param phoneNumber the phone number
	 * @param otpCode     the OTP code to validate
	 * @return true if OTP is valid (and was deleted)
	 */
	boolean isOtpValidAndDeleteIfValid(String phoneNumber, String otpCode);
}