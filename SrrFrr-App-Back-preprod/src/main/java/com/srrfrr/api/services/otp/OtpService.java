package com.srrfrr.api.services.otp;

import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.exceptions.security.InvalidPhoneNumberFormatException;
import com.srrfrr.api.exceptions.user.UserNotFoundException;
import com.srrfrr.api.infrastructure.otp.IOtpService;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OtpService {

    private final IOtpService otpService;
    private final PassengerRepository passengerRepository;

    public void sendOtp(OtpRequest request, boolean requireExisting) {
        if (requireExisting) {
            final String normalized = PhoneNumberUtils.normalizeToInternational(request.getPhoneNumber());

            if (normalized == null) {
                throw new InvalidPhoneNumberFormatException(request.getPhoneNumber());
            }

            if (!passengerRepository.existsByPhoneNumber(normalized)) {
                throw new UserNotFoundException("Phone number not found: " + normalized);
            }
        }

        otpService.generateAndSendOtp(request);
    }

    public boolean isOtpValid(String phoneNumber, String otp) {
        return otpService.isOtpValid(phoneNumber, otp);
    }
}
