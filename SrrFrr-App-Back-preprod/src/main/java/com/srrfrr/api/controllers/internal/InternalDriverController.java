package com.srrfrr.api.controllers.internal;

import com.srrfrr.api.dto.driver.DriverDocumentsResponse;
import com.srrfrr.api.dto.driver.UpdateApprovalDriverRequest;
import com.srrfrr.api.services.internal.InternalDriverService;
import com.srrfrr.api.services.user.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/internal")
public class InternalDriverController {

    private final InternalDriverService internalDriverService;
    private final UserProfileService userProfileService;

    public InternalDriverController(final InternalDriverService internalDriverService, final UserProfileService userProfileService) {
        this.internalDriverService = internalDriverService;
        this.userProfileService = userProfileService;
    }

    @PreAuthorize("hasRole('SERVICE')")
    @PatchMapping(value = "/passenger/{id}/profile-picture", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Void> updatePassengerProfilePicture(
            @PathVariable final UUID id,
            @RequestParam("file") final MultipartFile file) {

        userProfileService.updateProfilePicture(id, file);
        return ResponseEntity.ok().build();
    }

    @PreAuthorize("isAuthenticated()")
    @PatchMapping("/driver/{id}/approval")
    public ResponseEntity<Void> updateDriverStatus(
            @PathVariable final UUID id,
            @Valid @RequestBody final UpdateApprovalDriverRequest request) {

        final boolean updated = internalDriverService.updateUserApproval(id, request);

        if (!updated) {
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
        }

        return ResponseEntity.ok().build();
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/driver/{id}/documents")
    public ResponseEntity<DriverDocumentsResponse> getDriverDocuments(@PathVariable final UUID id) {
        final DriverDocumentsResponse response = internalDriverService.getDriverDocuments(id);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("isAuthenticated()")
    @PatchMapping(value = "/driver/{id}/documents/{documentType}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Void> updateDriverDocument(
            @PathVariable final UUID id,
            @PathVariable final String documentType,
            @RequestParam("file") final MultipartFile file) throws IOException {

        internalDriverService.updateDriverDocument(id, documentType, file);
        return ResponseEntity.ok().build();
    }

    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/driver/{id}/documents/{documentType}")
    public ResponseEntity<Void> deleteDriverDocument(
            @PathVariable final UUID id,
            @PathVariable final String documentType) throws IOException {

        internalDriverService.deleteDriverDocument(id, documentType);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/driver/{id}/documents")
    public ResponseEntity<Void> deleteAllDriverDocuments(@PathVariable final UUID id) throws IOException {
        internalDriverService.deleteAllDriverDocuments(id);
        return ResponseEntity.noContent().build();
    }
}