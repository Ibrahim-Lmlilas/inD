package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.WalletDTO;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.services.payment.WalletService;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/wallet")
public class WalletController {
    private final WalletService walletService;

    public WalletController(final WalletService walletService) {
        this.walletService = walletService;
    }

    /**
     * Get driver wallet for the authenticated user
     * Note: The driver wallet belongs to the same passenger but with
     * UserType.DRIVER
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/driver")
    public ResponseEntity<WalletDTO> getDriverWallet(@AuthenticationPrincipal final Passenger passenger) {
        if (passenger == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        final Driver driver = passenger.getDriverProfile();
        if (driver == null) {
            throw new EntityNotFoundException("Driver profile not found for this passenger");
        }

        final WalletDTO walletDTO = walletService.getWalletWithTransactions(driver.getId());

        return ResponseEntity.ok(walletDTO);
    }
}