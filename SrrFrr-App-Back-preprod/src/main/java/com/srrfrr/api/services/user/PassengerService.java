package com.srrfrr.api.services.user;

import com.srrfrr.api.dto.PassengerResponse;
import com.srrfrr.api.dto.otp.OtpRequest;
import com.srrfrr.api.dto.user.UpdatePhoneNumberResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.exceptions.security.InvalidOtpException;
import com.srrfrr.api.exceptions.security.IncorrectPasswordException;
import com.srrfrr.api.exceptions.security.PasswordMismatchException;
import com.srrfrr.api.exceptions.security.SamePasswordException;
import com.srrfrr.api.exceptions.security.SamePhoneNumberException;
import com.srrfrr.api.exceptions.security.PhoneNumberAlreadyExistsException;
import com.srrfrr.api.exceptions.security.InvalidPhoneNumberFormatException;
import com.srrfrr.api.exceptions.user.PassengerNotFoundException;
import com.srrfrr.api.infrastructure.otp.IOtpService;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.ride.CurrentRideService;
import com.srrfrr.api.utils.ConvertToURL;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Service for passenger-specific operations.
 * Handles passenger profile, password updates, and phone number changes.
 */
@Service
@Slf4j
public class PassengerService {

    private final PassengerRepository passengerRepository;
    private final PasswordEncoder passwordEncoder;
    private final IOtpService otpService;
    private final CurrentRideService currentRideService;

    public PassengerService(
            final PassengerRepository passengerRepository,
            final PasswordEncoder passwordEncoder,
            final IOtpService otpService,
            final CurrentRideService currentRideService) {
        this.passengerRepository = passengerRepository;
        this.passwordEncoder = passwordEncoder;
        this.otpService = otpService;
        this.currentRideService = currentRideService;
    }

    /**
     * Get complete passenger profile with current ride.
     * 
     * @param passengerId the passenger ID
     * @return passenger response DTO
     */
    public PassengerResponse getPassenger(final UUID passengerId) {
        final Passenger passenger = passengerRepository.findById(passengerId)
                .orElseThrow(() -> new PassengerNotFoundException(passengerId.toString()));

        final PassengerResponse response = new PassengerResponse();
        response.setId(passenger.getId());
        response.setFirstName(passenger.getFirstName());
        response.setLastName(passenger.getLastName());
        response.setPhoneNumber(passenger.getPhoneNumber());
        response.setProfilePicture(ConvertToURL.convert(passenger.getProfilePicture()));
        response.setPoints(passenger.getPoints());
        response.setInterfaceType(passenger.getInterfaceType().toString());
        response.setGender(passenger.getGender());
        response.setLanguage(passenger.getLanguage());
        response.setRating(passenger.getRating());
        response.setTotalRides(passenger.getTotalRides());

        // Get current active ride using consolidated service
        response.setCurrentRide(currentRideService.getCurrentRideForPassenger(passengerId));

        return response;
    }

    /**
     * Update passenger password with validation.
     * 
     * @param passenger          the passenger
     * @param currentPassword    current password for verification
     * @param newPassword        new password
     * @param confirmNewPassword password confirmation
     */
    @Transactional
    public void updatePassword(
            final Passenger passenger,
            final String currentPassword,
            final String newPassword,
            final String confirmNewPassword) {

        validatePasswordUpdate(passenger, currentPassword, newPassword, confirmNewPassword);

        final String encodedPassword = passwordEncoder.encode(newPassword);
        passenger.setPassword(encodedPassword);
        passengerRepository.save(passenger);

        log.info("Password updated for passenger {}", passenger.getId());
    }

    /**
     * Check if passenger exists by phone number.
     * 
     * @param phoneNumber the phone number to check
     * @return true if exists, false otherwise
     */
    public boolean checkIfPassengerExistsByPhoneNumber(final String phoneNumber) {
        return passengerRepository.existsByPhoneNumber(phoneNumber);
    }

    /**
     * Send OTP for phone number update.
     * Validates password and phone number before sending OTP.
     * 
     * @param passenger      the passenger
     * @param newPhoneNumber new phone number
     * @param password       current password for verification
     * @return update response with OTP status
     */
    @Transactional
    public UpdatePhoneNumberResponse sendOtpForPhoneNumberUpdate(
            final Passenger passenger,
            final String newPhoneNumber,
            final String password) {

        // Verify password
        if (!passwordEncoder.matches(password, passenger.getPassword())) {
            throw new IncorrectPasswordException();
        }

        // Normalize and validate phone number
        final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(newPhoneNumber);
        if (normalizedPhone == null) {
            throw new InvalidPhoneNumberFormatException(newPhoneNumber);
        }

        // Check if same as current
        if (normalizedPhone.equals(passenger.getPhoneNumber())) {
            throw new SamePhoneNumberException();
        }

        // Check if already exists
        if (passengerRepository.existsByPhoneNumber(normalizedPhone)) {
            throw new PhoneNumberAlreadyExistsException(normalizedPhone);
        }

        // Generate and send OTP
        final OtpRequest request = new OtpRequest();
        request.setPhoneNumber(normalizedPhone);

        final boolean sent = otpService.generateAndSendOtp(request);

        log.info("OTP {} for phone update to {} for passenger {}",
                sent ? "sent" : "failed", normalizedPhone, passenger.getId());

        final UpdatePhoneNumberResponse response = new UpdatePhoneNumberResponse();
        response.setPhoneNumber(normalizedPhone);
        response.setMessage(sent
                ? "OTP sent to new phone number. Please verify to complete update."
                : "Failed to send OTP. Please try again.");

        return response;
    }

    /**
     * Confirm phone number update with OTP verification.
     * 
     * @param passenger      the passenger
     * @param newPhoneNumber new phone number
     * @param otpCode        OTP code for verification
     * @return update response
     */
    @Transactional
    public UpdatePhoneNumberResponse confirmPhoneNumberUpdateWithOtp(
            final Passenger passenger,
            final String newPhoneNumber,
            final String otpCode) {

        // Normalize phone number
        final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(newPhoneNumber);
        if (normalizedPhone == null) {
            throw new InvalidPhoneNumberFormatException(newPhoneNumber);
        }

        // Verify OTP
        final boolean isValidOtp = otpService.isOtpValidAndDeleteIfValid(normalizedPhone, otpCode);
        if (!isValidOtp) {
            throw new InvalidOtpException();
        }

        // Update phone number
        passenger.setPhoneNumber(normalizedPhone);
        passengerRepository.save(passenger);

        log.info("Phone number updated to {} for passenger {}", normalizedPhone, passenger.getId());

        final UpdatePhoneNumberResponse response = new UpdatePhoneNumberResponse();
        response.setPhoneNumber(normalizedPhone);
        response.setMessage("Phone number updated successfully");

        return response;
    }

    /**
     * Validate password update request.
     */
    private void validatePasswordUpdate(
            Passenger passenger,
            String currentPassword,
            String newPassword,
            String confirmNewPassword) {

        if (!newPassword.equals(confirmNewPassword)) {
            throw new PasswordMismatchException();
        }

        if (!passwordEncoder.matches(currentPassword, passenger.getPassword())) {
            throw new IncorrectPasswordException();
        }

        if (passwordEncoder.matches(newPassword, passenger.getPassword())) {
            throw new SamePasswordException();
        }
    }
}