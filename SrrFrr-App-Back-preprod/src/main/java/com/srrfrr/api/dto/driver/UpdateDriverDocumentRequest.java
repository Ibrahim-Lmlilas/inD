package com.srrfrr.api.dto.driver;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class UpdateDriverDocumentRequest {
	private MultipartFile cinRecto;
	private MultipartFile cinVerso;
	private MultipartFile selfie;
	private MultipartFile vehiclePicture;
	private MultipartFile vehicleRegistrationRecto;
	private MultipartFile vehicleRegistrationVerso;
}