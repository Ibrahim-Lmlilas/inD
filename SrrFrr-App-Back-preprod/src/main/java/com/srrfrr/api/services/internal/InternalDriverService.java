package com.srrfrr.api.services.internal;

import com.srrfrr.api.dto.driver.DriverDocumentsResponse;
import com.srrfrr.api.dto.driver.UpdateApprovalDriverRequest;
import com.srrfrr.api.dto.notification.NotificationRequest;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.NotificationType;
import com.srrfrr.api.enums.user.Approval;
import com.srrfrr.api.exceptions.user.DriverProfileNotFoundException;
import com.srrfrr.api.infrastructure.storage.IStorageService;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.services.notification.NotificationService;
import com.srrfrr.api.utils.ConvertToURL;

import java.io.IOException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Service for internal driver operations (admin/backoffice).
 * Uses NotificationType enum for all notifications.
 */
@Slf4j
@Service
public class InternalDriverService {

    private final DriverRepository driverRepository;
    private final NotificationService notificationService;
    private final IStorageService storageService;

    public InternalDriverService(
            final DriverRepository driverRepository,
            final NotificationService notificationService,
            final IStorageService storageService) {
        this.driverRepository = driverRepository;
        this.notificationService = notificationService;
        this.storageService = storageService;
    }

    /**
     * Update driver approval status and send appropriate notification.
     * 
     * @param driverId the driver ID
     * @param request  the approval update request
     * @return true if updated, false if no change
     */
    @Transactional
    public boolean updateUserApproval(final UUID driverId, final UpdateApprovalDriverRequest request) {
        final Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found with ID: " + driverId));

        final Approval newApproval = request.getApproval();
        final Approval currentApproval = driver.getApproval();

        // No change needed
        if (currentApproval == newApproval) {
            log.info("Driver {} already has approval {}, no update performed", driverId, currentApproval);
            return false;
        }

        log.info("Updating driver {} approval from {} to {}", driverId, currentApproval, newApproval);

        // Update approval and timestamps
        driver.setApproval(newApproval);
        driver.setValidatedAt(null);
        driver.setRejectedAt(null);

        switch (newApproval) {
            case VALIDATED -> driver.setValidatedAt(LocalDateTime.now());
            case REJECTED -> driver.setRejectedAt(LocalDateTime.now());
            case PENDING -> {
            } // Timestamps remain null
        }

        driverRepository.save(driver);

        // Send notification using enum
        sendApprovalNotification(driver, newApproval);

        return true;
    }

    /**
     * Send approval notification based on status.
     * Uses NotificationType enum for type safety.
     */
    private void sendApprovalNotification(Driver driver, Approval status) {
        Passenger linkedPassenger = driver.getPassenger();
        if (linkedPassenger == null) {
            log.warn("Driver {} has no linked passenger for notification", driver.getId());
            return;
        }

        // Determine notification type from enum
        NotificationType notifType = switch (status) {
            case VALIDATED -> NotificationType.ACCOUNT_VALIDATED;
            case REJECTED -> NotificationType.ACCOUNT_REJECTED;
            case PENDING -> NotificationType.ACCOUNT_PENDING;
        };

        String firstName = linkedPassenger.getFirstName();

        // Customize content with passenger name in all languages
        String contentAR = switch (status) {
            case VALIDATED -> String.format(
                    "تهانينا %s! تم التحقق من حساب السائق الخاص بك بنجاح.",
                    firstName);
            case REJECTED -> String.format(
                    "مرحباً %s، تم رفض التحقق من حساب السائق الخاص بك. " +
                            "يرجى مراجعة معلوماتك والمحاولة مرة أخرى.",
                    firstName);
            case PENDING -> String.format(
                    "مرحباً %s، حساب السائق الخاص بك قيد المراجعة حالياً. " +
                            "سيتم إخطارك بمجرد معالجته.",
                    firstName);
        };

        String contentFR = switch (status) {
            case VALIDATED -> String.format(
                    "Félicitations %s ! Votre compte chauffeur a été validé avec succès.",
                    firstName);
            case REJECTED -> String.format(
                    "Bonjour %s, la validation de votre compte chauffeur a été rejetée. " +
                            "Veuillez vérifier vos informations et réessayer.",
                    firstName);
            case PENDING -> String.format(
                    "Bonjour %s, votre compte chauffeur est actuellement en cours d'examen. " +
                            "Vous serez notifié une fois traité.",
                    firstName);
        };

        String contentEN = switch (status) {
            case VALIDATED -> String.format(
                    "Congratulations %s! Your driver account has been successfully validated.",
                    firstName);
            case REJECTED -> String.format(
                    "Hello %s, your driver account validation has been rejected. " +
                            "Please review your information and try again.",
                    firstName);
            case PENDING -> String.format(
                    "Hello %s, your driver account is currently under review. " +
                            "You'll be notified once it's processed.",
                    firstName);
        };

        // Create and send notification with all translations
        NotificationRequest request = NotificationRequest.withCustomContent(
                notifType,
                linkedPassenger.getId(),
                contentAR,
                contentFR,
                contentEN);

        notificationService.sendNotification(request);

        log.info("Sent {} notification to user {}", notifType, linkedPassenger.getId());
    }

    /**
     * Get all driver documents with URLs.
     */
    public DriverDocumentsResponse getDriverDocuments(final UUID driverId) {
        final Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new DriverProfileNotFoundException("Driver not found"));

        final DriverDocumentsResponse response = new DriverDocumentsResponse();
        response.setCinRecto(ConvertToURL.convert(driver.getCinRecto()));
        response.setCinVerso(ConvertToURL.convert(driver.getCinVerso()));
        response.setSelfie(ConvertToURL.convert(driver.getSelfie()));
        response.setVehiclePicture(ConvertToURL.convert(driver.getVehiclePicture()));
        response.setVehicleRegistrationRecto(ConvertToURL.convert(driver.getVehicleRegistrationRecto()));
        response.setVehicleRegistrationVerso(ConvertToURL.convert(driver.getVehicleRegistrationVerso()));

        return response;
    }

    /**
     * Update a specific driver document.
     */
    @Transactional
    public void updateDriverDocument(
            final UUID driverId,
            final String documentType,
            final MultipartFile file) throws IOException {

        final Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new DriverProfileNotFoundException("Driver not found"));

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is required");
        }

        // Upload new document
        final long timestamp = System.currentTimeMillis();
        final String extension = getFileExtension(file.getOriginalFilename());
        final String fileName = String.format("%s_%d.%s", documentType, timestamp, extension);

        // Vehicle picture goes to public folder, other docs to private folder
        final String folderPath = documentType.equalsIgnoreCase("vehicle")
                ? "public/" + driverId
                : "private/drivers/" + driverId;

        final String newKey = storageService.uploadFile(file, folderPath, fileName);

        // Delete old document and update driver entity
        String oldKey = null;
        switch (documentType.toLowerCase()) {
            case "cin_recto":
                oldKey = driver.getCinRecto();
                driver.setCinRecto(newKey);
                break;
            case "cin_verso":
                oldKey = driver.getCinVerso();
                driver.setCinVerso(newKey);
                break;
            case "selfie":
                oldKey = driver.getSelfie();
                driver.setSelfie(newKey);
                break;
            case "vehicle":
                oldKey = driver.getVehiclePicture();
                driver.setVehiclePicture(newKey);
                break;
            case "reg_recto":
                oldKey = driver.getVehicleRegistrationRecto();
                driver.setVehicleRegistrationRecto(newKey);
                break;
            case "reg_verso":
                oldKey = driver.getVehicleRegistrationVerso();
                driver.setVehicleRegistrationVerso(newKey);
                break;
            default:
                throw new IllegalArgumentException("Invalid document type: " + documentType);
        }

        // Delete old document if exists
        if (oldKey != null && !oldKey.isEmpty()) {
            try {
                storageService.deleteFile(oldKey);
            } catch (IOException e) {
                log.warn("Failed to delete old document: {}", oldKey, e);
            }
        }

        driverRepository.save(driver);
        log.info("Updated {} for driver {}", documentType, driverId);
    }
    
    /**
     * Delete a specific driver document.
     */
    @Transactional
    public void deleteDriverDocument(final UUID driverId, final String documentType) throws IOException {
        final Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new DriverProfileNotFoundException("Driver not found"));

        String keyToDelete = null;

        switch (documentType.toLowerCase()) {
            case "cin_recto":
                keyToDelete = driver.getCinRecto();
                driver.setCinRecto(null);
                break;
            case "cin_verso":
                keyToDelete = driver.getCinVerso();
                driver.setCinVerso(null);
                break;
            case "selfie":
                keyToDelete = driver.getSelfie();
                driver.setSelfie(null);
                break;
            case "vehicle":
                keyToDelete = driver.getVehiclePicture();
                driver.setVehiclePicture(null);
                break;
            case "reg_recto":
                keyToDelete = driver.getVehicleRegistrationRecto();
                driver.setVehicleRegistrationRecto(null);
                break;
            case "reg_verso":
                keyToDelete = driver.getVehicleRegistrationVerso();
                driver.setVehicleRegistrationVerso(null);
                break;
            default:
                throw new IllegalArgumentException("Invalid document type: " + documentType);
        }

        if (keyToDelete != null && !keyToDelete.isEmpty()) {
            storageService.deleteFile(keyToDelete);
            driverRepository.save(driver);
            log.info("Deleted {} for driver {}", documentType, driverId);
        }
    }

    /**
     * Delete all driver documents.
     */
    @Transactional
    public void deleteAllDriverDocuments(final UUID driverId) throws IOException {
        final Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new DriverProfileNotFoundException("Driver not found"));

        // Delete all documents from storage
        deleteDocumentIfExists(driver.getCinRecto());
        deleteDocumentIfExists(driver.getCinVerso());
        deleteDocumentIfExists(driver.getSelfie());
        deleteDocumentIfExists(driver.getVehiclePicture());
        deleteDocumentIfExists(driver.getVehicleRegistrationRecto());
        deleteDocumentIfExists(driver.getVehicleRegistrationVerso());

        // Clear all document references
        driver.setCinRecto(null);
        driver.setCinVerso(null);
        driver.setSelfie(null);
        driver.setVehiclePicture(null);
        driver.setVehicleRegistrationRecto(null);
        driver.setVehicleRegistrationVerso(null);

        driverRepository.save(driver);
        log.info("Deleted all documents for driver {}", driverId);
    }

    private void deleteDocumentIfExists(final String key) {
        if (key != null && !key.isEmpty()) {
            try {
                storageService.deleteFile(key);
            } catch (IOException e) {
                log.warn("Failed to delete document: {}", key, e);
            }
        }
    }

    private String getFileExtension(final String filename) {
        if (filename == null || !filename.contains(".")) {
            return "png";
        }
        return filename.substring(filename.lastIndexOf('.') + 1);
    }
}