package com.srrfrr.api.mapper;

import com.srrfrr.api.dto.ride.HistoryPassengerResponse;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.utils.ConvertToURL;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class PassengerMapper {

    public static HistoryPassengerResponse toPassengerDTO(Passenger passenger) {
        if (passenger == null) return null;

        return HistoryPassengerResponse.builder()
                .id(passenger.getId())
                .firstName(passenger.getFirstName())
                .lastName(passenger.getLastName())
                .phoneNumber(passenger.getPhoneNumber())
                .rating(passenger.getRating())
                .totalRides(passenger.getTotalRides())
                .profilePicture(ConvertToURL.convert(passenger.getProfilePicture()))
                .interfaceType(passenger.getInterfaceType())
                .points(passenger.getPoints())
                .build();
    }

}