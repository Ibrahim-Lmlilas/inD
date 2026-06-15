package com.srrfrr.api.controllers;

import com.srrfrr.api.dto.RatingResponse;
import com.srrfrr.api.dto.RatingValuesResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.entities.main.RatingValues;
import com.srrfrr.api.services.rating.RatingService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/ratings")
public class RatingController {
    private final RatingService ratingService;
    public RatingController(final RatingService ratingService){
        this.ratingService=ratingService;

    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/{rideId}")
    public ResponseEntity<?> createRating(
            @AuthenticationPrincipal final Passenger passenger,
            @PathVariable final UUID rideId,
            @RequestBody final RatingValues ratingRequest) {

        final RatingResponse response = ratingService.createRating(passenger, rideId, ratingRequest);
        return ResponseEntity.ok(response);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/rating-values")
    public List<RatingValuesResponse> getRatingValuesGroupedAndSorted() {
        return ratingService.getGroupedAndSortedRatingValues();
    }
}
