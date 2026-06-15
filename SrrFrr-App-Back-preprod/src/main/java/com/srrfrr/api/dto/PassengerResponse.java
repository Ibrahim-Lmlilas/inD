package com.srrfrr.api.dto;

import com.fasterxml.jackson.databind.node.ObjectNode;
import com.srrfrr.api.enums.user.GenderLabel;
import com.srrfrr.api.enums.user.Language;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PassengerResponse {
    private UUID id;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String profilePicture;
    private String interfaceType;
    private GenderLabel gender;
    private Language language;
    private int points;
    private double rating;
    private int totalRides;
    private ObjectNode currentRide;
}