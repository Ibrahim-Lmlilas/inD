package com.srrfrr.api.services.profile;

import com.srrfrr.api.constants.StoragePaths;
import com.srrfrr.api.dto.driver.DriverProfileEditRequestCreateRequest;
import com.srrfrr.api.dto.driver.DriverProfileEditRequestResponse;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.DriverProfileEditRequest;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.enums.user.Approval;
import com.srrfrr.api.exceptions.user.DriverProfileNotFoundException;
import com.srrfrr.api.exceptions.user.FileUploadException;
import com.srrfrr.api.exceptions.user.PassengerNotFoundException;
import com.srrfrr.api.infrastructure.storage.IStorageService;
import com.srrfrr.api.repositories.main.user.DriverProfileEditRequestRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.utils.ConvertToURL;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Slf4j
public class DriverProfileEditRequestService {

    private final DriverProfileEditRequestRepository requestRepository;
    private final DriverRepository driverRepository;
    private final PassengerRepository passengerRepository;
    private final IStorageService storageService;

    public DriverProfileEditRequestService(
            final DriverProfileEditRequestRepository requestRepository,
            final DriverRepository driverRepository,
            final PassengerRepository passengerRepository,
            final IStorageService storageService) {
        this.requestRepository = requestRepository;
        this.driverRepository = driverRepository;
        this.passengerRepository = passengerRepository;
        this.storageService = storageService;
    }

    @Transactional
    public void createRequest(final Passenger passenger, final DriverProfileEditRequestCreateRequest request) {
        final Driver driver = driverRepository.findByPassengerId(passenger.getId())
                .orElseThrow(() -> new DriverProfileNotFoundException("No driver profile found for this user"));

        if (requestRepository.existsByDriver_IdAndStatus(driver.getId(), Approval.PENDING)) {
            throw new IllegalStateException("You already have a pending profile edit request.");
        }

        if (!hasAnyChange(request)) {
            throw new IllegalArgumentException("No changes provided for profile edit request.");
        }

        final DriverProfileEditRequest entity = new DriverProfileEditRequest();
        entity.setDriver(driver);
        entity.setRequestedFirstName(trimToNull(request.getFirstName()));
        entity.setRequestedLastName(trimToNull(request.getLastName()));
        entity.setRequestedVehicleBrand(trimToNull(request.getVehicleBrand()));
        entity.setRequestedVehicleModel(trimToNull(request.getVehicleModel()));
        entity.setRequestedVehicleColor(trimToNull(request.getVehicleColor()));
        entity.setRequestedVehicleRegistrationCode(trimToNull(request.getVehicleRegistrationCode()));
        entity.setRequestedProductionYear(trimToNull(request.getProductionYear()));
        entity.setRequestedVehicleType(request.getVehicleType());

        final String driverId = driver.getId().toString();
        final String privateFolder = StoragePaths.getPrivateDriverFolder(driverId);
        final String publicFolder = StoragePaths.getPublicUserFolder(driverId);

        entity.setRequestedCinRecto(uploadIfPresent(request.getCinRecto(), privateFolder, "cin_recto"));
        entity.setRequestedCinVerso(uploadIfPresent(request.getCinVerso(), privateFolder, "cin_verso"));
        entity.setRequestedSelfie(uploadIfPresent(request.getSelfie(), privateFolder, "selfie"));
        entity.setRequestedVehicleRegistrationRecto(
                uploadIfPresent(request.getVehicleRegistrationRecto(), privateFolder, "reg_recto"));
        entity.setRequestedVehicleRegistrationVerso(
                uploadIfPresent(request.getVehicleRegistrationVerso(), privateFolder, "reg_verso"));
        entity.setRequestedVehiclePicture(uploadIfPresent(request.getVehiclePicture(), publicFolder, "vehicle"));

        requestRepository.save(entity);
        log.info("Driver profile edit request created for driver {}", driver.getId());
    }

    @Transactional(readOnly = true)
    public List<DriverProfileEditRequestResponse> listByStatus(final Approval status) {
        if (status == null) {
            return requestRepository.findAll().stream()
                    .map(this::toResponse)
                    .collect(Collectors.toList());
        }
        return requestRepository.findByStatusOrderByCreatedAtDesc(status).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DriverProfileEditRequestResponse getRequest(final UUID requestId) {
        final DriverProfileEditRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));
        return toResponse(request);
    }

    @Transactional(readOnly = true)
    public List<DriverProfileEditRequestResponse> listForDriver(final UUID driverId) {
        return requestRepository.findAllByDriver_IdOrderByCreatedAtDesc(driverId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void approveRequest(final UUID requestId) {
        final DriverProfileEditRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        if (request.getStatus() != Approval.PENDING) {
            throw new IllegalStateException("Request is not pending.");
        }

        final Driver driver = request.getDriver();
        if (driver == null) {
            throw new DriverProfileNotFoundException("Driver not found for request: " + requestId);
        }

        final Passenger passenger = driver.getPassenger();
        if (passenger == null) {
            throw new PassengerNotFoundException("Passenger not found for driver: " + driver.getId());
        }

        applyPassengerChanges(passenger, request);
        applyDriverChanges(driver, request);
        applyDocumentChanges(driver, request);

        request.setStatus(Approval.VALIDATED);

        passengerRepository.save(passenger);
        driverRepository.save(driver);
        requestRepository.save(request);

        log.info("Driver profile edit request {} approved", requestId);
    }

    @Transactional
    public void rejectRequest(final UUID requestId) {
        final DriverProfileEditRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        if (request.getStatus() != Approval.PENDING) {
            throw new IllegalStateException("Request is not pending.");
        }

        cleanupRequestFiles(request);
        request.setStatus(Approval.REJECTED);
        requestRepository.save(request);

        log.info("Driver profile edit request {} rejected", requestId);
    }

    private void applyPassengerChanges(final Passenger passenger, final DriverProfileEditRequest request) {
        if (request.getRequestedFirstName() != null) {
            passenger.setFirstName(request.getRequestedFirstName());
        }
        if (request.getRequestedLastName() != null) {
            passenger.setLastName(request.getRequestedLastName());
        }
    }

    private void applyDriverChanges(final Driver driver, final DriverProfileEditRequest request) {
        if (request.getRequestedVehicleBrand() != null) {
            driver.setVehicleBrand(request.getRequestedVehicleBrand());
        }
        if (request.getRequestedVehicleModel() != null) {
            driver.setVehicleModel(request.getRequestedVehicleModel());
        }
        if (request.getRequestedVehicleColor() != null) {
            driver.setVehicleColor(request.getRequestedVehicleColor());
        }
        if (request.getRequestedVehicleRegistrationCode() != null) {
            driver.setVehicleRegistrationCode(request.getRequestedVehicleRegistrationCode());
        }
        if (request.getRequestedProductionYear() != null) {
            driver.setProductionYear(request.getRequestedProductionYear());
        }
        if (request.getRequestedVehicleType() != null) {
            driver.setVehicleType(request.getRequestedVehicleType());
        }
    }

    private void applyDocumentChanges(final Driver driver, final DriverProfileEditRequest request) {
        replaceDocumentIfPresent(request.getRequestedCinRecto(), driver.getCinRecto(), driver::setCinRecto);
        replaceDocumentIfPresent(request.getRequestedCinVerso(), driver.getCinVerso(), driver::setCinVerso);
        replaceDocumentIfPresent(request.getRequestedSelfie(), driver.getSelfie(), driver::setSelfie);
        replaceDocumentIfPresent(request.getRequestedVehiclePicture(), driver.getVehiclePicture(),
                driver::setVehiclePicture);
        replaceDocumentIfPresent(request.getRequestedVehicleRegistrationRecto(), driver.getVehicleRegistrationRecto(),
                driver::setVehicleRegistrationRecto);
        replaceDocumentIfPresent(request.getRequestedVehicleRegistrationVerso(), driver.getVehicleRegistrationVerso(),
                driver::setVehicleRegistrationVerso);
    }

    private void replaceDocumentIfPresent(final String newKey, final String oldKey,
            final java.util.function.Consumer<String> setter) {
        if (newKey == null || newKey.isEmpty()) {
            return;
        }

        if (oldKey != null && !oldKey.isEmpty()) {
            try {
                storageService.deleteFile(oldKey);
            } catch (IOException e) {
                log.warn("Failed to mark old file as old: {}", oldKey, e);
            }
        }

        setter.accept(newKey);
    }

    private void cleanupRequestFiles(final DriverProfileEditRequest request) {
        deleteIfPresent(request.getRequestedCinRecto());
        deleteIfPresent(request.getRequestedCinVerso());
        deleteIfPresent(request.getRequestedSelfie());
        deleteIfPresent(request.getRequestedVehiclePicture());
        deleteIfPresent(request.getRequestedVehicleRegistrationRecto());
        deleteIfPresent(request.getRequestedVehicleRegistrationVerso());
    }

    private void deleteIfPresent(final String key) {
        if (key == null || key.isEmpty()) {
            return;
        }
        try {
            storageService.deleteFile(key);
        } catch (IOException e) {
            log.warn("Failed to mark request file as old: {}", key, e);
        }
    }

    private boolean hasAnyChange(final DriverProfileEditRequestCreateRequest request) {
        return isNotBlank(request.getFirstName()) ||
                isNotBlank(request.getLastName()) ||
                isNotBlank(request.getVehicleBrand()) ||
                isNotBlank(request.getVehicleModel()) ||
                isNotBlank(request.getVehicleColor()) ||
                isNotBlank(request.getVehicleRegistrationCode()) ||
                isNotBlank(request.getProductionYear()) ||
                request.getVehicleType() != null ||
                hasFile(request.getCinRecto()) ||
                hasFile(request.getCinVerso()) ||
                hasFile(request.getSelfie()) ||
                hasFile(request.getVehiclePicture()) ||
                hasFile(request.getVehicleRegistrationRecto()) ||
                hasFile(request.getVehicleRegistrationVerso());
    }

    private boolean hasFile(final MultipartFile file) {
        return file != null && !file.isEmpty();
    }

    private String uploadIfPresent(final MultipartFile file, final String folder, final String prefix) {
        if (!hasFile(file)) {
            return null;
        }

        try {
            final String extension = getFileExtension(file.getOriginalFilename());
            final String fileName = StoragePaths.buildFilename(prefix, extension);
            return storageService.uploadFile(file, folder, fileName);
        } catch (IOException e) {
            throw new FileUploadException("Failed to upload " + prefix, e);
        }
    }

    private String getFileExtension(final String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.') + 1);
    }

    private String trimToNull(final String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean isNotBlank(final String value) {
        return value != null && !value.trim().isEmpty();
    }

    private DriverProfileEditRequestResponse toResponse(final DriverProfileEditRequest request) {
        final DriverProfileEditRequestResponse response = new DriverProfileEditRequestResponse();
        response.setId(request.getId());
        response.setDriverId(request.getDriver().getId());
        response.setPassengerId(request.getDriver().getPassenger() != null
                ? request.getDriver().getPassenger().getId()
                : null);
        response.setStatus(request.getStatus());
        response.setCreatedAt(request.getCreatedAt());
        response.setUpdatedAt(request.getUpdatedAt());
        if (request.getDriver() != null && request.getDriver().getPassenger() != null) {
            response.setDriverFirstName(request.getDriver().getPassenger().getFirstName());
            response.setDriverLastName(request.getDriver().getPassenger().getLastName());
        }

        response.setRequestedFirstName(request.getRequestedFirstName());
        response.setRequestedLastName(request.getRequestedLastName());
        response.setRequestedVehicleBrand(request.getRequestedVehicleBrand());
        response.setRequestedVehicleModel(request.getRequestedVehicleModel());
        response.setRequestedVehicleColor(request.getRequestedVehicleColor());
        response.setRequestedVehicleRegistrationCode(request.getRequestedVehicleRegistrationCode());
        response.setRequestedProductionYear(request.getRequestedProductionYear());
        response.setRequestedVehicleType(request.getRequestedVehicleType());

        response.setRequestedCinRectoUrl(ConvertToURL.convert(request.getRequestedCinRecto()));
        response.setRequestedCinVersoUrl(ConvertToURL.convert(request.getRequestedCinVerso()));
        response.setRequestedSelfieUrl(ConvertToURL.convert(request.getRequestedSelfie()));
        response.setRequestedVehiclePictureUrl(ConvertToURL.convert(request.getRequestedVehiclePicture()));
        response.setRequestedVehicleRegistrationRectoUrl(
                ConvertToURL.convert(request.getRequestedVehicleRegistrationRecto()));
        response.setRequestedVehicleRegistrationVersoUrl(
                ConvertToURL.convert(request.getRequestedVehicleRegistrationVerso()));

        return response;
    }
}
