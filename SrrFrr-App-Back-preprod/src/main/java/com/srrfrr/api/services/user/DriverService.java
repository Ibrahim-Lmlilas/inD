package com.srrfrr.api.services.user;

import com.srrfrr.api.dto.driver.DriverResponse;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.exceptions.user.DriverProfileNotFoundException;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.services.ride.CurrentRideService;
import com.srrfrr.api.services.subscription.SubscriptionService;
import com.srrfrr.api.utils.ConvertToURL;

import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
public class DriverService {
    private final DriverRepository driverRepository;
    private final SubscriptionService subscriptionService;
    private final CurrentRideService currentRideService;

    public DriverService(
            final DriverRepository driverRepository,
            final SubscriptionService subscriptionService,
            final CurrentRideService currentRideService) {
        this.driverRepository = driverRepository;
        this.subscriptionService = subscriptionService;
        this.currentRideService = currentRideService;
    }

    @Transactional
    public DriverResponse getDriver(final UUID passengerId) {
        // Use the existing query that fetches driver with subscription details
        final Driver driver = driverRepository.findDriverWithSubscriptionDetails(passengerId)
                .orElseThrow(() -> new DriverProfileNotFoundException("No driver profile found for this user"));

        return buildDriverResponse(driver, true);
    }

    @Transactional
    public DriverResponse getDriverBasicInfo(final UUID passengerId) {
        final Driver driver = driverRepository.findDriverWithSubscriptionDetails(passengerId)
                .orElseThrow(() -> new DriverProfileNotFoundException("No driver profile found for this user"));

        return buildDriverResponse(driver, false);
    }

    private DriverResponse buildDriverResponse(Driver driver, boolean includeDetails) {
        final Passenger passenger = driver.getPassenger();

        final DriverResponse response = new DriverResponse();

        // Basic information
        response.setId(driver.getId());
        response.setFirstName(passenger.getFirstName());
        response.setLastName(passenger.getLastName());
        response.setPhoneNumber(passenger.getPhoneNumber());
        response.setProfilePicture(ConvertToURL.convert(passenger.getProfilePicture()));
        response.setRating(driver.getRating());
        response.setTotalRides(driver.getTotalRides());
        response.setVerified(driver.isVerified());
        response.setApproval(driver.getApproval());
        response.setOnline(driver.isOnline());

        // Vehicle information
        response.setVehicleType(driver.getVehicleType());
        response.setVehiclePicture(ConvertToURL.convert(driver.getVehiclePicture()));
        response.setVehicleRegistrationCode(driver.getVehicleRegistrationCode());
        response.setVehicleBrand(driver.getVehicleBrand());
        response.setVehicleModel(driver.getVehicleModel());
        response.setVehicleColor(driver.getVehicleColor());
        response.setProductionYear(driver.getProductionYear());

        // Wallet balance
        response.setWallet(driver.getWalletBalance());

        // Optional detailed information
        if (includeDetails) {
            response.setCurrentRide(currentRideService.getCurrentRideForDriver(driver.getId()));
            response.setSubscription(subscriptionService.getActiveSubscription(driver.getId()));
        }

        return response;
    }
}