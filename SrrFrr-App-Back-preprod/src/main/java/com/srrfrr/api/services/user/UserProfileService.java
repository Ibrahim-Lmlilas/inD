package com.srrfrr.api.services.user;

import com.srrfrr.api.constants.StoragePaths;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.InterfaceType;
import com.srrfrr.api.enums.user.Language;
import com.srrfrr.api.exceptions.user.*;
import com.srrfrr.api.infrastructure.storage.IStorageService;
import com.srrfrr.api.exceptions.authentication.InvalidPasswordException;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.ArchiveService;
import com.srrfrr.api.utils.ConvertToURL;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j
public class UserProfileService {
    private final PassengerRepository passengerRepository;
    private final PasswordEncoder passwordEncoder;
    private final RideRepository rideRepository;
    private final ArchiveService archiveService;
    private final IStorageService storageService;

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    public UserProfileService(
            PassengerRepository passengerRepository,
            PasswordEncoder passwordEncoder,
            RideRepository rideRepository,
            ArchiveService archiveService,
            IStorageService storageService) {
        this.passengerRepository = passengerRepository;
        this.passwordEncoder = passwordEncoder;
        this.rideRepository = rideRepository;
        this.archiveService = archiveService;
        this.storageService = storageService;
    }

    @Transactional
    public String updateProfilePicture(UUID passengerId, MultipartFile file) {
        Passenger passenger = passengerRepository.findById(passengerId)
                .orElseThrow(() -> new PassengerNotFoundException(passengerId.toString()));

        validateFile(file);

        try {
            String userId = passengerId.toString();
            String extension = getFileExtension(file.getOriginalFilename());
            String fileName = StoragePaths.buildFilename("profile_picture", extension);
            String folderPath = StoragePaths.getPublicUserFolder(userId);

            // Soft delete old profile picture (marks it with old_ prefix)
            if (passenger.getProfilePicture() != null && !passenger.getProfilePicture().isEmpty()) {
                try {
                    storageService.deleteFile(passenger.getProfilePicture());
                    log.info("Old profile picture marked as old: {}", passenger.getProfilePicture());
                } catch (IOException e) {
                    log.warn("Failed to mark old profile picture as old: {}", passenger.getProfilePicture(), e);
                    // Continue with upload even if marking old file fails
                }
            }

            // Upload new profile picture
            String storageKey = storageService.uploadFile(file, folderPath, fileName);

            // Update passenger profile with new storage key
            passenger.setProfilePicture(storageKey);
            passengerRepository.save(passenger);

            log.info("Updated profile picture for passenger {}", passengerId);

            // Return public URL
            return ConvertToURL.convert(storageKey);

        } catch (IOException e) {
            log.error("Error saving profile picture for passenger {}", passengerId, e);
            throw new FileUploadException("Error saving profile picture", e);
        }
    }

    /**
     * Update interface type with validation.
     * LADIES interface is only available for female users.
     * 
     * @param passenger the passenger
     * @param newType   the new interface type
     */
    @Transactional
    public void updateInterfaceType(Passenger passenger, InterfaceType newType) {
        if (newType == InterfaceType.LADIES && passenger.getGender() != GenderLabel.FEMALE) {
            throw new LadiesInterfaceNotAllowedException();
        }

        InterfaceType oldType = passenger.getInterfaceType();
        passenger.setInterfaceType(newType);

        try {
            passengerRepository.save(passenger);
            log.info("Updated interface type for passenger {} from {} to {}",
                    passenger.getId(), oldType, newType);
        } catch (Exception e) {
            log.error("Failed to update interface type for passenger {}", passenger.getId(), e);
            throw new InvalidInterfaceTypeException("Failed to update interface type");
        }
    }

    @Transactional
    public void deleteProfilePicture(UUID passengerId) {
        Passenger passenger = passengerRepository.findById(passengerId)
                .orElseThrow(() -> new PassengerNotFoundException(passengerId.toString()));

        String storageKey = passenger.getProfilePicture();
        if (storageKey != null && !storageKey.isEmpty()) {
            try {
                // Mark file as old instead of permanent deletion
                storageService.deleteFile(storageKey);
                passenger.setProfilePicture(null);
                passengerRepository.save(passenger);
                log.info("Marked profile picture as old for passenger {}", passengerId);
            } catch (IOException e) {
                log.error("Failed to mark profile picture as old: {}", storageKey, e);
                throw new FileUploadException("Failed to delete profile picture", e);
            }
        }
    }

    @Transactional
    public void deleteUserAccount(UUID passengerId, String password) {
        Passenger passenger = passengerRepository.findById(passengerId)
                .orElseThrow(() -> new PassengerNotFoundException(passengerId.toString()));

        if (!passwordEncoder.matches(password, passenger.getPassword())) {
            throw new InvalidPasswordException("Invalid Password");
        }

        try {
            cancelActiveRides(passengerId);
            archiveService.archivePassenger(passengerId, "USER_DELETION_REQUEST");
            log.info("Successfully deleted and archived account for passenger {}", passengerId);
        } catch (Exception e) {
            log.error("Failed to delete account for passenger {}: {}", passengerId, e.getMessage(), e);
            throw new DeleteAccountException("Failed to delete account: " + e.getMessage());
        }
    }

    private void cancelActiveRides(UUID passengerId) {
        rideRepository.findActiveRideForPassenger(passengerId)
                .ifPresent(ride -> {
                    ride.setStatus(RideStatus.CANCELED);
                    rideRepository.save(ride);
                    log.debug("Cancelled active ride {} where user was passenger", ride.getId());
                });

        rideRepository.findActiveRideForDriver(passengerId)
                .ifPresent(ride -> {
                    ride.setStatus(RideStatus.CANCELED);
                    rideRepository.save(ride);
                    log.debug("Cancelled active ride {} where user was driver", ride.getId());
                });
    }

    /**
     * Validate uploaded file for size and type.
     * 
     * @param file the file to validate
     */
    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new InvalidFileException("File cannot be empty");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new FileSizeExceededException(file.getSize(), MAX_FILE_SIZE);
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            throw new InvalidFileException("Invalid file name");
        }

        String extension = getFileExtension(originalFilename);
        if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
            throw new InvalidFileTypeException(extension, String.join(", ", ALLOWED_EXTENSIONS));
        }
    }

    @Transactional
    public void updateLanguage(final Passenger passenger, final Language language) {
        passenger.setLanguage(language);
        passengerRepository.save(passenger);
        log.info("Language updated to {} for passenger {}", language, passenger.getId());
    }

    /**
     * Extract file extension from filename.
     * 
     * @param filename the filename
     * @return the file extension (without dot)
     */
    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.') + 1);
    }
}