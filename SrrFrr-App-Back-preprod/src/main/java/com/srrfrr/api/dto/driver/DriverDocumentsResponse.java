package com.srrfrr.api.dto.driver;

import lombok.Data;

@Data
public class DriverDocumentsResponse {
	private String cinRecto;
	private String cinVerso;
	private String selfie;
	private String vehiclePicture;
	private String vehicleRegistrationRecto;
	private String vehicleRegistrationVerso;
}