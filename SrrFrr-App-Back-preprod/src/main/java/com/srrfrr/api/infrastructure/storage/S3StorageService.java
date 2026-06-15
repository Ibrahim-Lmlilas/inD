package com.srrfrr.api.infrastructure.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.io.IOException;
import java.util.List;

/**
 * AWS S3 storage implementation for production environment.
 * Handles both public and private file storage with CloudFront CDN.
 */
@Slf4j
@Service
@Profile({"prod", "preprod"})
public class S3StorageService implements IStorageService {

	private final S3Client s3Client;

	@Value("${data.bucket.name}")
	private String bucketName;

	@Value("${cloudfront.domain}")
	private String cloudFrontDomain;

	public S3StorageService(S3Client s3Client) {
		this.s3Client = s3Client;
	}

	@Override
	public String uploadFile(MultipartFile file, String folderPath, String fileName) throws IOException {
		String key = folderPath + "/" + fileName;
		log.info("[S3] Uploading file: bucket={}, key={}", bucketName, key);

		try {
			PutObjectRequest putObjectRequest = PutObjectRequest.builder()
					.bucket(bucketName)
					.key(key)
					.contentType(file.getContentType())
					.contentLength(file.getSize())
					.build();

			s3Client.putObject(putObjectRequest, RequestBody.fromBytes(file.getBytes()));
			log.info("[S3] File uploaded successfully: {}", key);

			return key;
		} catch (Exception e) {
			log.error("[S3] Failed to upload file: {}", key, e);
			throw new IOException("Failed to upload file to S3", e);
		}
	}

	@Override
	public String getFileUrl(String key) {
		// Skip files marked as old
		if (key != null && key.contains("/old_")) {
			log.debug("Skipping old file: {}", key);
			return null;
		}
		return cloudFrontDomain + "/" + key;
	}

	@Override
	public void deleteFile(String key) throws IOException {
		if (key == null || key.isEmpty()) {
			return;
		}

		log.info("[S3] Marking file as old: {}", key);

		try {
			String oldKey = getOldFileKey(key);

			// Copy the existing file to old_ version
			CopyObjectRequest copyRequest = CopyObjectRequest.builder()
					.sourceBucket(bucketName)
					.sourceKey(key)
					.destinationBucket(bucketName)
					.destinationKey(oldKey)
					.build();

			s3Client.copyObject(copyRequest);

			log.info("[S3] File copied to old version: {} -> {}", key, oldKey);
		} catch (Exception e) {
			log.warn("[S3] Failed to mark file as old (continuing anyway): {}", key, e);
			// Don't throw - this is a soft delete, failure is not critical
		}
	}

	/**
	 * Generate key for old file by adding "old_" prefix to filename.
	 * Example: "public/123/profile_123.png" -> "public/123/old_profile_123.png"
	 */
	private String getOldFileKey(String key) {
		int lastSlash = key.lastIndexOf('/');
		if (lastSlash == -1) {
			return "old_" + key;
		}
		String folder = key.substring(0, lastSlash);
		String filename = key.substring(lastSlash + 1);
		return folder + "/old_" + filename;
	}
}