package com.srrfrr.api.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.srrfrr.api.infrastructure.google.GoogleMapsService;

@RestController
@RequestMapping("/maps")
public class GoogleMapsController {
    private final GoogleMapsService googleMapsService;


    public GoogleMapsController(final GoogleMapsService googleMapsService) {
        this.googleMapsService = googleMapsService;
    }

    @GetMapping("/distance")
    public String distance(
            @RequestParam final String origins,
            @RequestParam final String destinations) {

        return googleMapsService.getDistanceMatrix(origins, destinations);
    }

    @GetMapping("/directions")
    public String directions(
            @RequestParam final String origin,
            @RequestParam final String destination) {

        return googleMapsService.getDirections(origin, destination);
    }

    @GetMapping("/geocode")
    public String geocode(@RequestParam final String latlng) {
        return googleMapsService.reverseGeocode(latlng);
    }

    @GetMapping("/places/textsearch")
    public String textSearch(@RequestParam final String query) {
        return googleMapsService.textSearch(query);
    }

    @GetMapping("/places/nearby")
    public String nearbySearch(
            @RequestParam final String location,
            @RequestParam final int radius) {

        return googleMapsService.nearbySearch(location, radius);
    }

    @GetMapping("/places/details")
    public String placeDetails(@RequestParam final String placeId) {
        return googleMapsService.placeDetails(placeId);
    }

}
