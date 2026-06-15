package com.srrfrr.api.mapper;

import com.srrfrr.api.dto.ride.HistoryDriverResponse;
import com.srrfrr.api.entities.main.Driver;
import com.srrfrr.api.entities.main.Passenger;
import com.srrfrr.api.utils.ConvertToURL;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class DriverMapper {

    public static HistoryDriverResponse toDriverDTO(final Driver driver) {
        if (driver == null) {
            return null;
        }

        Passenger passengerProfile = driver.getPassenger(); // Profil lié au driver (hérité de Passenger)

        return HistoryDriverResponse.builder()
                .id(driver.getId())

                //Infos personnelles (du Passenger lié)
                .firstName(passengerProfile != null ? passengerProfile.getFirstName() : "")
                .lastName(passengerProfile != null ? passengerProfile.getLastName() : "")
                .phoneNumber(passengerProfile != null ? passengerProfile.getPhoneNumber() : "")
                .profilePicture(passengerProfile != null ? ConvertToURL.convert(passengerProfile.getProfilePicture()) : "")
                .vehicleBrand(driver.getVehicleBrand() != null ? driver.getVehicleBrand() : "")
                .vehicleModel(driver.getVehicleModel() != null ? driver.getVehicleModel() : "")
                .vehicleColor(driver.getVehicleColor() != null ? driver.getVehicleColor() : "")
                .vehicleRegistrationCode(driver.getVehicleRegistrationCode() != null ? driver.getVehicleRegistrationCode() : "")
                .rating(driver.getRating())
                .totalRides(driver.getTotalRides())
                .build();
    }
}