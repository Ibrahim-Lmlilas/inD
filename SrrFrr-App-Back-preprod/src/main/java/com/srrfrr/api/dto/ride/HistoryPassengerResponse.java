package com.srrfrr.api.dto.ride;

import lombok.*;

import java.util.UUID;

import com.srrfrr.api.enums.user.InterfaceType;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HistoryPassengerResponse {
    private UUID id;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String profilePicture;
    private InterfaceType interfaceType;
    private int points;
    private double rating;
    private int totalRides;
}
