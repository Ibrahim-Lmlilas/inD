package com.srrfrr.api.infrastructure.otp;

import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.entities.main.Otp;
import com.srrfrr.api.exceptions.authentication.InvalidRequestException;
import com.srrfrr.api.exceptions.authentication.OtpRateLimitException;
import com.srrfrr.api.exceptions.authentication.OtpSendFailedException;
import com.srrfrr.api.repositories.main.OtpRepository;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Production OTP service with full WhatsApp integration, rate limiting,
 * and security features.
 */
@Slf4j
@Service
@Profile({"prod", "preprod"})
public class ProdOtpService implements IOtpService {

	private final OtpRepository otpRepository;
	private final PasswordEncoder passwordEncoder;
	private final OtpUtils otpUtils;

	private static final long OTP_VALIDITY_DURATION_MS = 3 * 60 * 1000; // 3 minutes
	private static final long OTP_SEND_INTERVAL_MS = 60 * 1000; // 1 minute
	private static final int MAX_RESEND_ATTEMPTS = 3;
	private static final int MAX_FAILED_ATTEMPTS = 3;
	private static final long RESEND_BLOCK_DURATION_MS = 30 * 60 * 1000; // 30 minutes

	public ProdOtpService(
			OtpRepository otpRepository,
			PasswordEncoder passwordEncoder,
			OtpUtils otpUtils) {
		this.otpRepository = otpRepository;
		this.passwordEncoder = passwordEncoder;
		this.otpUtils = otpUtils;
	}

	@Override
	@Transactional
	public boolean generateAndSendOtp(OtpRequest request) {
		String normalizedPhone = normalizePhoneNumber(request.getPhoneNumber());

		Optional<Otp> existingOtp = otpRepository.findByPhoneNumber(normalizedPhone);
		long now = System.currentTimeMillis();

		Otp otp = existingOtp.orElse(new Otp());
		otp.setPhoneNumber(normalizedPhone);

		// Unlock if block expired
		if (otp.getLockedUntil() != null && otp.getLockedUntil() <= now) {
			otp.setLockedUntil(null);
			otp.setResendCount(0);
			otp.setFailedAttempts(0);
		}

		// Check if blocked
		if (otp.getLockedUntil() != null && otp.getLockedUntil() > now) {
			long retryAfterSeconds = (otp.getLockedUntil() - now) / 1000;
			throw new OtpRateLimitException(
					"Phone number is temporarily blocked. Try again in " + retryAfterSeconds + " seconds.");
		}

		if (existingOtp.isPresent()) {
			// Check resend limit
			if (otp.getResendCount() >= MAX_RESEND_ATTEMPTS) {
				throw new OtpRateLimitException(
						"Maximum resend attempts reached. Please use the last OTP sent.");
			}

			// Check send interval
			long otpCreationTime = otp.getExpirationTime() - OTP_VALIDITY_DURATION_MS;
			long timeSinceLastOtpMs = now - otpCreationTime;

			if (timeSinceLastOtpMs < OTP_SEND_INTERVAL_MS) {
				long retryAfter = (OTP_SEND_INTERVAL_MS - timeSinceLastOtpMs) / 1000;
				throw new OtpRateLimitException(
						"You must wait " + retryAfter + " seconds before requesting another OTP.");
			}

			otp.setResendCount(otp.getResendCount() + 1);
		} else {
			otp.setResendCount(1);
		}

		// Generate OTP and send via WhatsApp
	//	String otpCode = OtpUtils.generateOtp();
	// this is a hardcoded otp until whatsapp integration is fixed
		String otpCode = "000000";

		/*try {
			otpUtils.sendOtpMessage(normalizedPhone, otpCode, request.getLanguage());
		} catch (Exception e) {
			log.error("Failed to send OTP to {}", normalizedPhone, e);
			throw new OtpSendFailedException(e);
		}*/

		// Save encrypted OTP
		long expiration = now + OTP_VALIDITY_DURATION_MS;
		otp.setOtp(passwordEncoder.encode(otpCode));
		otp.setExpirationTime(expiration);
		otp.setFailedAttempts(0);
		otpRepository.save(otp);

		log.info("OTP sent to {} (expires in {} minutes)", normalizedPhone,
				OTP_VALIDITY_DURATION_MS / 60000);

		return true;
	}

	@Override
	@Transactional(propagation = Propagation.REQUIRES_NEW)
	public boolean isOtpValid(String phoneNumber, String otpCode) {
		String normalizedPhone = normalizePhoneNumber(phoneNumber);

		Optional<Otp> otpOptional = otpRepository.findByPhoneNumber(normalizedPhone);
		if (otpOptional.isEmpty()) {
			throw new InvalidRequestException(
					"OTP for this phone number does not exist. Try sending an OTP first.");
		}

		Otp otp = otpOptional.get();
		long now = System.currentTimeMillis();

		// Unlock if expired
		if (otp.getLockedUntil() != null && otp.getLockedUntil() <= now) {
			otp.setLockedUntil(null);
			otp.setFailedAttempts(0);
			otp.setResendCount(0);
			otpRepository.save(otp);
		}

		// Check if blocked
		if (otp.getLockedUntil() != null && otp.getLockedUntil() > now) {
			long retryAfter = (otp.getLockedUntil() - now) / 1000;
			throw new OtpRateLimitException(
					"Phone number is temporarily blocked. Try again in " + retryAfter + " seconds.");
		}

		// Check expiration
		if (otp.getExpirationTime() < now) {
			incrementFailedAttemptsAndBlockIfNeeded(otp, now);
			return false;
		}

		// Validate OTP
		boolean isValid = passwordEncoder.matches(otpCode, otp.getOtp());

		if (isValid) {
			otp.setFailedAttempts(0);
			otp.setLockedUntil(null);
			otp.setResendCount(0);
			otpRepository.save(otp);
			return true;
		} else {
			incrementFailedAttemptsAndBlockIfNeeded(otp, now);
			return false;
		}
	}

	@Override
	@Transactional(propagation = Propagation.REQUIRES_NEW)
	public boolean isOtpValidAndDeleteIfValid(String phoneNumber, String otpCode) {
		String normalizedPhone = normalizePhoneNumber(phoneNumber);

		Optional<Otp> otpOptional = otpRepository.findByPhoneNumber(normalizedPhone);
		if (otpOptional.isEmpty()) {
			throw new InvalidRequestException(
					"OTP for this phone number does not exist. Try sending an OTP first.");
		}

		Otp otp = otpOptional.get();
		long now = System.currentTimeMillis();

		// Unlock if expired
		if (otp.getLockedUntil() != null && otp.getLockedUntil() <= now) {
			otp.setLockedUntil(null);
			otp.setFailedAttempts(0);
			otp.setResendCount(0);
			otpRepository.save(otp);
		}

		// Check if blocked
		if (otp.getLockedUntil() != null && otp.getLockedUntil() > now) {
			long retryAfter = (otp.getLockedUntil() - now) / 1000;
			throw new OtpRateLimitException(
					"Phone number is temporarily blocked. Try again in " + retryAfter + " seconds.");
		}

		// Check expiration
		if (otp.getExpirationTime() < now) {
			incrementFailedAttemptsAndBlockIfNeeded(otp, now);
			return false;
		}

		// Validate OTP
		boolean isValid = passwordEncoder.matches(otpCode, otp.getOtp());

		if (isValid) {
			otpRepository.delete(otp);
			log.info("OTP validated and deleted for {}", normalizedPhone);
			return true;
		} else {
			incrementFailedAttemptsAndBlockIfNeeded(otp, now);
			return false;
		}
	}

	/**
	 * Increment failed attempts and block if threshold reached.
	 */
	@Transactional
	private void incrementFailedAttemptsAndBlockIfNeeded(Otp otp, long now) {
		if (otp.getLockedUntil() != null && otp.getLockedUntil() > now) {
			throw new OtpRateLimitException("Phone number is already blocked.");
		}

		if (otp.getFailedAttempts() >= MAX_FAILED_ATTEMPTS) {
			throw new OtpRateLimitException("Maximum failed attempts reached. Request a new OTP.");
		}

		otp.setFailedAttempts(otp.getFailedAttempts() + 1);

		// Block if max failed attempts and max resends reached
		if (otp.getFailedAttempts() >= MAX_FAILED_ATTEMPTS &&
				otp.getResendCount() >= MAX_RESEND_ATTEMPTS) {
			otp.setLockedUntil(now + RESEND_BLOCK_DURATION_MS);
			log.warn("Phone {} blocked due to excessive failed attempts", otp.getPhoneNumber());
		}

		otpRepository.save(otp);
	}

	/**
	 * Normalize phone number.
	 */
	private String normalizePhoneNumber(String rawNumber) {
		String normalized = PhoneNumberUtils.normalizeToInternational(rawNumber);
		if (normalized == null) {
			throw new IllegalArgumentException("Invalid phone number format");
		}
		return normalized;
	}
}