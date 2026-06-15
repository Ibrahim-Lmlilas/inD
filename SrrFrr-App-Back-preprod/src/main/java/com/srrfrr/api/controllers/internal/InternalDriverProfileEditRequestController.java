package com.srrfrr.api.controllers.internal;

import com.srrfrr.api.dto.SuccessResponse;
import com.srrfrr.api.dto.driver.DriverProfileEditRequestResponse;
import com.srrfrr.api.enums.user.Approval;
import com.srrfrr.api.services.profile.DriverProfileEditRequestService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/driver/profile-edit-requests")
public class InternalDriverProfileEditRequestController {

    private final DriverProfileEditRequestService service;

    public InternalDriverProfileEditRequestController(final DriverProfileEditRequestService service) {
        this.service = service;
    }

    @PreAuthorize("hasRole('SERVICE')")
    @GetMapping
    public ResponseEntity<List<DriverProfileEditRequestResponse>> listRequests(
            @RequestParam(name = "status", required = false) final Approval status) {

        return ResponseEntity.ok(service.listByStatus(status));
    }

    @PreAuthorize("hasRole('SERVICE')")
    @GetMapping("/{id}")
    public ResponseEntity<DriverProfileEditRequestResponse> getRequest(@PathVariable final UUID id) {
        return ResponseEntity.ok(service.getRequest(id));
    }

    @PreAuthorize("hasRole('SERVICE')")
    @PatchMapping("/{id}/approve")
    public ResponseEntity<SuccessResponse> approve(@PathVariable final UUID id) {
        service.approveRequest(id);
        return ResponseEntity.ok(new SuccessResponse("Profile edit request approved.", 200));
    }

    @PreAuthorize("hasRole('SERVICE')")
    @PatchMapping("/{id}/reject")
    public ResponseEntity<SuccessResponse> reject(@PathVariable final UUID id) {
        service.rejectRequest(id);
        return ResponseEntity.ok(new SuccessResponse("Profile edit request rejected.", 200));
    }
}
