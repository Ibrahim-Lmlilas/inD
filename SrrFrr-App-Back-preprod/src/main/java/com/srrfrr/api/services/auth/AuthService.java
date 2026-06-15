package com.srrfrr.api.services.auth;

import com.srrfrr.api.constants.StoragePaths;
import com.srrfrr.api.dto.auth.*;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.user.Approval;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.Status;
import com.srrfrr.api.exceptions.authentication.*;
import com.srrfrr.api.exceptions.user.UserNotFoundException;
import com.srrfrr.api.infrastructure.otp.IOtpService;
import com.srrfrr.api.infrastructure.storage.IStorageService;
import com.srrfrr.api.repositories.main.*;
import com.srrfrr.api.repositories.main.user.*;
import com.srrfrr.api.services.payment.WalletService;
import com.srrfrr.api.services.referral.InviteService;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Slf4j
@Service
public class AuthService {

    private final AuthenticationRepository authRepository;
    private final TokenService tokenService;
    private final InviteService inviteService;
    private final PasswordEncoder passwordEncoder;
    private final OtpRepository otpRepository;
    private final IOtpService otpService;
    private final PassengerRepository passengerRepository;
    private final DriverRepository driverRepository;
    private final WalletService walletService;
    private final IStorageService storageService;

    public AuthService(
            final AuthenticationRepository authRepository,
            final TokenService tokenService,
            final PasswordEncoder passwordEncoder,
            final IOtpService otpService,
            final InviteService inviteService,
            final PassengerRepository passengerRepository,
            final DriverRepository driverRepository,
            final WalletService walletService,
            final OtpRepository otpRepository,
            final IStorageService storageService) {
        this.authRepository = authRepository;
        this.tokenService = tokenService;
        this.passwordEncoder = passwordEncoder;
        this.otpRepository = otpRepository;
        this.otpService = otpService;
        this.inviteService = inviteService;
        this.passengerRepository = passengerRepository;
        this.walletService = walletService;
        this.driverRepository = driverRepository;
        this.storageService = storageService;
    }

    @Transactional
    public AuthResponse createPassenger(final CreatePassengerRequest request) throws IOException {
        final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(request.getPhoneNumber());
        log.info("Creating passenger with normalized phone: {}", normalizedPhone);

        if (normalizedPhone == null) {
            throw new InvalidRequestException("Invalid phone number format");
        }

        if (!otpService.isOtpValidAndDeleteIfValid(normalizedPhone, request.getOtpCode())) {
            throw new InvalidOtpException("Invalid or expired OTP");
        }

        if (passengerRepository.findByPhoneNumber(normalizedPhone).isPresent()) {
            throw new InvalidRequestException("Phone number already in use");
        }

        if (request.getFcmToken() == null || request.getDeviceId() == null) {
            throw new InvalidRequestException("FCM Token and Device ID are required");
        }

        final GenderLabel gender = GenderLabel.fromString(request.getGender());
        final Passenger passenger = new Passenger();

        passenger.setFirstName(request.getFirstName());
        passenger.setLastName(request.getLastName());
        passenger.setPhoneNumber(normalizedPhone);
        passenger.setInterfaceType(request.getInterfaceType());
        passenger.setLanguage(request.getLanguage());
        passenger.setTermsAccepted(request.isTermsAccepted());
        passenger.setPassword(passwordEncoder.encode(request.getPassword()));
        passenger.setGender(gender);

        // Save passenger first to get ID
        final Passenger savedPassenger = passengerRepository.save(passenger);
        final String userId = savedPassenger.getId().toString();

        // Upload profile picture to user's public folder
        if (request.getProfilePicture() != null && !request.getProfilePicture().isEmpty()) {
            String storageKey = uploadFile(
                    request.getProfilePicture(),
                    StoragePaths.getPublicUserFolder(userId),
                    "profile_picture");
            savedPassenger.setProfilePicture(storageKey);
            passengerRepository.save(savedPassenger);
        }

        final String refreshToken = tokenService.generateRefreshToken(normalizedPhone, userId);

        final Authentication authentication = new Authentication();
        authentication.setPassenger(savedPassenger);
        authentication.setFcmToken(request.getFcmToken());
        authentication.setRefreshToken(refreshToken);
        authentication.setDeviceId(request.getDeviceId());
        authRepository.save(authentication);

        final String accessToken = tokenService.generateAccessToken(normalizedPhone, userId,
                authentication.getDeviceId());

        inviteService.handlePassengerInvited(savedPassenger);
        // otpRepository.deleteByPhoneNumber(normalizedPhone);

        log.info("Passenger {} created successfully", savedPassenger.getId());

        return new AuthResponse(
                savedPassenger.getId(),
                "Passenger created successfully",
                accessToken,
                refreshToken);
    }

    @Transactional
    public AuthResponse createDriver(
            final Passenger passengerPrincipal,
            final CreateDriverRequest request) throws IOException {

        final Passenger passenger = passengerRepository.findById(passengerPrincipal.getId())
                .orElseThrow(() -> new InvalidRequestException("Passenger not found"));

        if (driverRepository.existsByPassengerId(passenger.getId())) {
            throw new InvalidRequestException("User is already registered as a Driver");
        }

        validateDriverDocuments(request);

        // Create and save driver to get ID
        final Driver driver = new Driver();
        driver.setPassenger(passenger);
        driver.setCinCode(request.getCinCode());
        driver.setExpirationDate(request.getExpirationDate());
        driver.setVehicleType(request.getVehicleType());
        driver.setVehicleRegistrationCode(request.getVehicleRegistrationCode());
        driver.setVehicleBrand(request.getVehicleBrand());
        driver.setVehicleModel(request.getVehicleModel());
        driver.setVehicleColor(request.getVehicleColor());
        driver.setProductionYear(request.getProductionYear());
        driver.setApproval(Approval.PENDING);

        final String driverId = passenger.getId().toString();
        final String driverFolder = StoragePaths.getPrivateDriverFolder(driverId);

        // Upload all driver documents to driver's private folder
        driver.setCinRecto(uploadFile(request.getCinRecto(), driverFolder, "cin_recto"));
        driver.setCinVerso(uploadFile(request.getCinVerso(), driverFolder, "cin_verso"));
        driver.setSelfie(uploadFile(request.getSelfie(), driverFolder, "selfie"));
        driver.setVehicleRegistrationRecto(
                uploadFile(request.getVehicleRegistrationRecto(), driverFolder, "reg_recto"));
        driver.setVehicleRegistrationVerso(
                uploadFile(request.getVehicleRegistrationVerso(), driverFolder, "reg_verso"));

        // Upload vehicle picture to user's public folder
        final String userId = passenger.getId().toString();
        String vehicleKey = uploadFile(
                request.getVehiclePicture(),
                StoragePaths.getPublicUserFolder(userId),
                "vehicle");
        driver.setVehiclePicture(vehicleKey);

        driverRepository.save(driver);
        walletService.getOrCreateWallet(driver);

        final Authentication authentication = authRepository.findByPassenger(passenger)
                .orElseThrow(() -> new RuntimeException("Authentication not found"));

        final String accessToken = tokenService.generateAccessToken(
                passenger.getPhoneNumber(),
                passenger.getId().toString(),
                authentication.getDeviceId());

        log.info("Driver {} created successfully", driver.getId());

        return new AuthResponse(
                driver.getId(),
                "Driver created successfully",
                accessToken,
                authentication.getRefreshToken());
    }

    /**
     * Upload a file to storage.
     * Single source of truth for file uploads.
     */
    private String uploadFile(MultipartFile file, String folderPath, String prefix) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new InvalidRequestException(prefix + " is required");
        }

        try {
            String extension = getFileExtension(file.getOriginalFilename());
            String fileName = StoragePaths.buildFilename(prefix, extension);

            String storageKey = storageService.uploadFile(file, folderPath, fileName);
            log.debug("Uploaded file {}/{}: {}", folderPath, fileName, storageKey);
            return storageKey;

        } catch (IOException e) {
            log.error("Failed to upload {}", prefix, e);
            throw new InvalidRequestException("Failed to upload " + prefix + ": " + e.getMessage());
        }
    }

    /**
     * Validate all driver documents are present.
     */
    private void validateDriverDocuments(final CreateDriverRequest request) {
        if (request.getCinRecto() == null || request.getCinRecto().isEmpty()) {
            throw new InvalidRequestException("CIN recto is required");
        }
        if (request.getCinVerso() == null || request.getCinVerso().isEmpty()) {
            throw new InvalidRequestException("CIN verso is required");
        }
        if (request.getSelfie() == null || request.getSelfie().isEmpty()) {
            throw new InvalidRequestException("Selfie is required");
        }
        if (request.getVehiclePicture() == null || request.getVehiclePicture().isEmpty()) {
            throw new InvalidRequestException("Vehicle picture is required");
        }
        if (request.getVehicleRegistrationRecto() == null || request.getVehicleRegistrationRecto().isEmpty()) {
            throw new InvalidRequestException("Vehicle registration recto is required");
        }
        if (request.getVehicleRegistrationVerso() == null || request.getVehicleRegistrationVerso().isEmpty()) {
            throw new InvalidRequestException("Vehicle registration verso is required");
        }
    }

    /**
     * Extract file extension from filename.
     */
    private String getFileExtension(final String filename) {
        if (filename == null || !filename.contains(".")) {
            return "png";
        }
        return filename.substring(filename.lastIndexOf('.') + 1);
    }

    @Transactional
    public void verifyOtpAndResetPassword(final ResetPasswordRequest request) {
        final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(request.getPhoneNumber());
        if (normalizedPhone == null) {
            throw new IllegalArgumentException("Invalid phone number format");
        }

        final boolean otpValid = otpService.isOtpValidAndDeleteIfValid(normalizedPhone, request.getOtp());
        if (!otpValid) {
            throw new IllegalArgumentException("Invalid or expired OTP");
        }

        final Passenger targetPassenger = passengerRepository.findByPhoneNumber(normalizedPhone)
                .orElseThrow(() -> new IllegalArgumentException("Passenger not found"));

        targetPassenger.setPassword(passwordEncoder.encode(request.getNewPassword()));
        passengerRepository.save(targetPassenger);
    }

    @Transactional
    public AuthResponse loginPassenger(final LoginRequest request) {
        final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(request.getPhoneNumber());
        log.info("Creating passenger with normalized phone: {}", normalizedPhone);
        if (normalizedPhone == null) {
            throw new InvalidCredentialsException("Invalid phone number format");
        }

        final Passenger passenger = passengerRepository.findByPhoneNumber(normalizedPhone)
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        if (passenger.getStatus() == Status.DELETED) {
            throw new UserNotFoundException("User not found");
        }

        if (!passwordEncoder.matches(request.getPassword(), passenger.getPassword())) {
            throw new InvalidCredentialsException("Invalid password");
        }

        final String newRefreshToken = tokenService.generateRefreshToken(
                normalizedPhone,
                passenger.getId().toString());
        final String newAccessToken = tokenService.generateAccessToken(
                normalizedPhone,
                passenger.getId().toString(),
                request.getDeviceId());

        Authentication auth = authRepository.findByPassenger(passenger).orElse(null);

        if (auth != null) {
            auth.setIsvalid(true);
            auth.setDeviceId(request.getDeviceId());
            auth.setFcmToken(request.getFcmToken());
            auth.setRefreshToken(newRefreshToken);
        } else {
            auth = new Authentication();
            auth.setPassenger(passenger);
            auth.setDeviceId(request.getDeviceId());
            auth.setFcmToken(request.getFcmToken());
            auth.setIsvalid(true);
            auth.setRefreshToken(newRefreshToken);
        }

        authRepository.save(auth);

        log.info("Passenger login successful with token rotation for user: {}", passenger.getId());

        return new AuthResponse(
                passenger.getId(),
                "Passenger login successful",
                newAccessToken,
                newRefreshToken);
    }

    @Transactional
    public AuthResponse refresh(final String refreshToken) {
        final Authentication auth = authRepository.findByRefreshToken(refreshToken)
                .orElseThrow(() -> new InvalidTokenException("Refresh token not found"));

        if (!auth.isIsvalid()) {
            throw new InvalidTokenException("Token no longer valid");
        }

        final Passenger passenger = passengerRepository.findById(auth.getPassenger().getId())
                .orElseThrow(() -> new UserNotFoundException("Passenger not found"));

        final String phoneNumber = passenger.getPhoneNumber();

        final String newAccessToken = tokenService.generateAccessToken(
                phoneNumber,
                passenger.getId().toString(),
                auth.getDeviceId());

        return new AuthResponse(
                passenger.getId(),
                "New access token generated successfully",
                newAccessToken,
                refreshToken);
    }

    @Transactional
    public void logout(final Passenger passenger, final String password) {
        if (passenger == null) {
            throw new InvalidTokenException("User not specified or session is invalid");
        }

        if (!passwordEncoder.matches(password, passenger.getPassword())) {
            throw new InvalidCredentialsException("Invalid password");
        }

        final Authentication auth = authRepository.findByPassengerId(passenger.getId())
                .orElseThrow(() -> new InvalidTokenException("Token not found"));

        authRepository.delete(auth);
    }
}