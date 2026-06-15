package com.srrfrr.api.infrastructure.google;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GoogleMapsService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String getDistanceMatrix(final String origins,final String destinations) {
        final String url = "https://maps.googleapis.com/maps/api/distancematrix/json"
                + "?origins=" + origins
                + "&destinations=" + destinations
                + "&mode=driving&departure_time=now&traffic_model=best_guess"
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

    public String getDirections(final String origin,final String destination) {
        final String url = "https://maps.googleapis.com/maps/api/directions/json"
                + "?origin=" + origin
                + "&destination=" + destination
                + "&mode=driving&departure_time=now&traffic_model=best_guess"
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

    public String reverseGeocode(final String latlng) {
        final String url = "https://maps.googleapis.com/maps/api/geocode/json"
                + "?latlng=" + latlng
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

    public String textSearch(final String query) {
        final String url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
                + "?query=" + query
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

    public String nearbySearch(final String location,final int radius) {
        final String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
                + "?location=" + location
                + "&radius=" + radius
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

    public String placeDetails(final String placeId) {
        final String url = "https://maps.googleapis.com/maps/api/place/details/json"
                + "?place_id=" + placeId
                + "&key=" + apiKey;

        return restTemplate.getForObject(url, String.class);
    }

}
