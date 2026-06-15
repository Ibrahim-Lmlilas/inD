package com.srrfrr.api.services.rating;

import com.srrfrr.api.dto.RatingResponse;
import com.srrfrr.api.dto.RatingValuesResponse;
import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.enums.RatingType;
import com.srrfrr.api.enums.Ride.RideStatus;
import com.srrfrr.api.repositories.main.RideRepository;
import com.srrfrr.api.repositories.main.rating.RatingRepository;
import com.srrfrr.api.repositories.main.rating.RatingValuesRepository;
import com.srrfrr.api.repositories.main.user.DriverRepository;
import com.srrfrr.api.repositories.main.user.PassengerRepository;
import com.srrfrr.api.services.loyalty.LoyaltyService;

import jakarta.persistence.EntityNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
public class RatingService {

    private final RatingRepository ratingRepository;
    private final PassengerRepository passengerRepository;
    private final DriverRepository driverRepository;
    private final RideRepository rideRepository;
    private final RatingValuesRepository ratingValuesRepository;
    private final LoyaltyService loyaltyService;


    public RatingService(final RatingRepository ratingRepository,
                         final RideRepository rideRepository,
                         final PassengerRepository passengerRepository,
                         final DriverRepository driverRepository,
                         final LoyaltyService loyaltyService,
                         final RatingValuesRepository ratingValuesRepository) {
        this.ratingRepository = ratingRepository;
        this.rideRepository = rideRepository;
        this.passengerRepository = passengerRepository;
        this.driverRepository = driverRepository;
        this.ratingValuesRepository = ratingValuesRepository;
        this.loyaltyService = loyaltyService;
    }

    @Transactional
    public RatingResponse createRating(Passenger currentUser, UUID rideId, RatingValues request) {

        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new EntityNotFoundException("Ride not found"));

        if (!(ride.getStatus() == RideStatus.STARTED || ride.getStatus() == RideStatus.COMPLETED)) {
            throw new IllegalStateException("You can only rate rides that are STARTED or COMPLETED");
        }

        if (ratingRepository.existsByRideAndSender(ride, currentUser)) {
            throw new IllegalStateException("You have already rated this ride.");
        }

        RatingValues ratingValues = ratingValuesRepository.findById(request.getId())
                .orElseThrow(() -> new EntityNotFoundException("Rating value not found"));

        Passenger ridePassenger = passengerRepository.findById(ride.getPassengerId())
                .orElseThrow(() -> new EntityNotFoundException("Passenger not found"));

        Driver driver = null;
        Passenger driverPassenger = null;

        if (ride.getDriverId() != null) {
            driver = driverRepository.findById(ride.getDriverId())
                    .orElseThrow(() -> new EntityNotFoundException("Driver not found"));
            driverPassenger = driver.getPassenger();
        }

        Rating rating = new Rating();
        rating.setRide(ride);
        rating.setRatingValues(ratingValues);

        Passenger receiver;

        // Passenger rates driver
        if (ridePassenger.getId().equals(currentUser.getId())) {
            if (driverPassenger == null) {
                throw new IllegalStateException("Ride has no driver to rate");
            }
            rating.setSender(currentUser);
            receiver = driverPassenger;
            rating.setReceiver(receiver);
            rating.setRatingType(RatingType.PASSENGER_TO_DRIVER);

            // Driver rates passenger
        } else if (driverPassenger != null && driverPassenger.getId().equals(currentUser.getId())) {
            rating.setSender(currentUser);
            receiver = ridePassenger;
            rating.setReceiver(receiver);
            rating.setRatingType(RatingType.DRIVER_TO_PASSENGER);

        } else {
            throw new IllegalStateException("You are not part of this ride");
        }

        rating = ratingRepository.save(rating);

        // Update rating based on type
        if (rating.getRatingType() == RatingType.PASSENGER_TO_DRIVER) {

            long ratedCount = ratingRepository.countByReceiverId(driver.getId());
            double newAverage = calculateNewAverage(
                    ratedCount,
                    driver.getRating(),
                    ratingValues.getRatingLevel());

            driver.setRating(newAverage);
            driverRepository.save(driver);

        } else if (rating.getRatingType() == RatingType.DRIVER_TO_PASSENGER) {

            long ratedCount = ratingRepository.countByReceiverId(receiver.getId());
            double newAverage = calculateNewAverage(
                    ratedCount,
                    receiver.getRating(),
                    ratingValues.getRatingLevel());

            receiver.setRating(newAverage);
            passengerRepository.save(receiver);
        }

        // Loyalty points only for passenger
        loyaltyService.awardPoints(receiver, 2, LoyaltyTransactionType.RATING);

        return new RatingResponse(
                rating.getId(),
                rating.getCreatedAt(),
                rating.getRide().getId(),
                rating.getSender().getId(),
                rating.getSender().getFirstName() + " " + rating.getSender().getLastName(),
                rating.getReceiver().getId(),
                rating.getReceiver().getFirstName() + " " + rating.getReceiver().getLastName(),
                rating.getRatingType().name());
    }
    
    private double calculateNewAverage(long ratedCount, double currentAverage, int newValue) {
        double newTotal = currentAverage * (ratedCount - 1) + newValue;
        return newTotal / ratedCount;
    }

    public List<RatingValuesResponse> getGroupedAndSortedRatingValues() {
        final List<RatingValues> ratingValuesList = ratingValuesRepository.findAll();
        final ModelMapper modelMapper = new ModelMapper();

        final Map<Integer, List<RatingValues>> grpdByRatLevel = ratingValuesList.stream()
                .collect(Collectors.groupingBy(RatingValues::getRatingLevel));

        final Map<Integer, List<RatingValues>> sorGrpdByRatLev = new TreeMap<>();
        for (final Map.Entry<Integer, List<RatingValues>> entry : grpdByRatLevel.entrySet()) {
            final List<RatingValues> sortedList = entry.getValue().stream()
                    .sorted(Comparator.comparingInt(rv -> Integer.parseInt(rv.getOrder())))
                    .collect(Collectors.toList());
            sorGrpdByRatLev.put(entry.getKey(), sortedList);
        }

        final List<RatingValuesResponse> responseList = new ArrayList<>();
        for (final Map.Entry<Integer, List<RatingValues>> entry : sorGrpdByRatLev.entrySet()) {
            final RatingValuesResponse response = new RatingValuesResponse();
            response.setRatingLevel(entry.getKey());

            final List<RatingValuesResponse.RatingOption> options = entry.getValue().stream()
                    .map(rv -> modelMapper.map(rv, RatingValuesResponse.RatingOption.class))
                    .collect(Collectors.toList());

            response.setOptions(options);
            responseList.add(response);
        }

        return responseList;
    }

}