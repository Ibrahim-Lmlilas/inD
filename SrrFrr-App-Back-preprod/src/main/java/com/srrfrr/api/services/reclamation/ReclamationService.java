package com.srrfrr.api.services.reclamation;

import com.srrfrr.api.dto.ReclamationRequest;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.Reclamation;
import com.srrfrr.api.entities.main.Ride;
import com.srrfrr.api.enums.Reclamation.CategoryReclamation;
import com.srrfrr.api.repositories.main.ReclamationRepository;
import com.srrfrr.api.repositories.main.RideRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReclamationService {

    private final ReclamationRepository reclamationRepository;
    private final RideRepository rideRepository;

    public ReclamationService(final ReclamationRepository reclamationRepository,
                              final RideRepository rideRepository) {
        this.reclamationRepository = reclamationRepository;
        this.rideRepository = rideRepository;
    }

    @Transactional
    public void createReclamation(final ReclamationRequest request, final Passenger passenger) {
        // Validate ride reference for RIDE category
        if (request.getCategory() == CategoryReclamation.RIDE) {
            if (request.getRideId() == null) {
                throw new IllegalArgumentException("Ride ID must be provided for Ride category");
            }

            final Ride ride = rideRepository.findById(request.getRideId())
                    .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + request.getRideId()));


            final Reclamation reclamation = new Reclamation();
            reclamation.setContent(request.getContent());
            reclamation.setCategory(CategoryReclamation.RIDE);
            reclamation.setPassenger(passenger);
            reclamation.setRide(ride);

            reclamationRepository.save(reclamation);
            
            return;
        }

        // Create general reclamation (no ride reference)
        final Reclamation reclamation = new Reclamation();
        reclamation.setContent(request.getContent());
        reclamation.setCategory(request.getCategory());
        reclamation.setPassenger(passenger);
        reclamation.setRide(null);

        reclamationRepository.save(reclamation);
    }
}

