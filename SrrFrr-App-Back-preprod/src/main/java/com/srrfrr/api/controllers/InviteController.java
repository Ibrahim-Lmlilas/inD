package com.srrfrr.api.controllers;

import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.referral.InviteService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/invite")
public class InviteController {

    private final InviteService inviteService;

    public InviteController(final InviteService inviteService) {
        this.inviteService = inviteService;
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/{phoneNumber}")
    public ResponseEntity<String> createNewInvitation(
            @AuthenticationPrincipal final Passenger passenger,
            @PathVariable final String phoneNumber) {

        inviteService.createNewInvite(passenger, phoneNumber);
        return ResponseEntity.ok("Referral processed successfully !");
    }

}