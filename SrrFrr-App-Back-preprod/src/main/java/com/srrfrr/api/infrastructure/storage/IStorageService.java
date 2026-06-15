package com.srrfrr.api.infrastructure.storage;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

/**
 * Storage service interface for file operations.
 */
public interface IStorageService {

	/**
	 * Upload a new file.
	 * 
	 * @param file       the file to upload
	 * @param folderPath folder path (e.g., "public/123" or "private/drivers/456")
	 * @param fileName   filename with extension (e.g., "profile_1234.png")
	 * @return storage key of uploaded file
	 */
	String uploadFile(MultipartFile file, String folderPath, String fileName) throws IOException;

	/**
	 * Get public URL for a file.
	 * Files with "old_" prefix are excluded (soft deleted).
	 * 
	 * @param key storage key
	 * @return full URL to access the file, null if file is marked as old
	 */
	String getFileUrl(String key);

	/**
	 * Delete a file by marking it with "old_" prefix.
	 * File stays in storage but won't be fetched via getFileUrl().
	 * 
	 * @param key storage key
	 */
	void deleteFile(String key) throws IOException;
}