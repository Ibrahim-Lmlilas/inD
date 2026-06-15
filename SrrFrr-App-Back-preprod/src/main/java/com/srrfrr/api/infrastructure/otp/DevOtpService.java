package com.srrfrr.api.infrastructure.otp;

import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

/**
 * Development OTP service - always returns true with default OTP "000000".
 * No database storage, no rate limiting, no timeout.
 */
@Slf4j
@Service
@Profile({ "dev", "test" })
public class DevOtpService implements IOtpService {

    private static final String DEFAULT_OTP = "000000";

    @Override
    public boolean generateAndSendOtp(OtpRequest request) {
        String normalizedPhone = PhoneNumberUtils.normalizeToInternational(request.getPhoneNumber());

        if (normalizedPhone == null) {
            log.warn("Invalid phone number format: {}", request.getPhoneNumber());
            throw new IllegalArgumentException("Invalid phone number format");
        }

        log.info("[DEV] Generated OTP for {}: {} (not sent, dev mode)", normalizedPhone, DEFAULT_OTP);
        return true;
    }

    @Override
    public boolean isOtpValid(String phoneNumber, String otpCode) {
        String normalizedPhone = PhoneNumberUtils.normalizeToInternational(phoneNumber);

        if (normalizedPhone == null) {
            log.warn("Invalid phone number format: {}", phoneNumber);
            return false;
        }

        boolean isValid = DEFAULT_OTP.equals(otpCode);
        log.info("[DEV] OTP validation for {}: {} (expected: {})",
                normalizedPhone, isValid ? "VALID" : "INVALID", DEFAULT_OTP);

        return isValid;
    }

    @Override
    public boolean isOtpValidAndDeleteIfValid(String phoneNumber, String otpCode) {
        // In dev mode, same behavior as isOtpValid (no deletion needed)
        return isOtpValid(phoneNumber, otpCode);
    }
}