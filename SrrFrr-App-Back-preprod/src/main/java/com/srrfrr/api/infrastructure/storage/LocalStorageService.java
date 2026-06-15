package com.srrfrr.api.infrastructure.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/**
 * Local file storage implementation for development environment.
 */
@Slf4j
@Service
@Profile({"dev", "test"})
public class LocalStorageService implements IStorageService {

	@Value("${file.upload.directory}")
	private String baseDirectory;

	@Override
	public String uploadFile(MultipartFile file, String folderPath, String fileName) throws IOException {
		log.info("Uploading file to local storage: folder={}, file={}", folderPath, fileName);

		// Create full directory path
		File dir = new File(baseDirectory, folderPath);
		if (!dir.exists() && !dir.mkdirs()) {
			throw new IOException("Failed to create directory: " + dir.getAbsolutePath());
		}

		// Save file
		File destination = new File(dir, fileName);
		file.transferTo(destination);

		// Return relative path from base directory
		String relativePath = folderPath + "/" + fileName;
		log.info("File uploaded successfully to local storage: {}", destination.getAbsolutePath());

		return relativePath;
	}

	@Override
	public String getFileUrl(String key) {
		log.debug("Getting file URL for key: {}", key);

		// Exclude files marked as old (soft deleted)
		if (key != null && key.contains("/old_")) {
			log.debug("Skipping old file: {}", key);
			return null;
		}

		// In dev, return the absolute path
		File file = new File(baseDirectory, key);
		if (!file.exists()) {
			log.warn("File not found: {}", file.getAbsolutePath());
			return null;
		}

		return file.getAbsolutePath();
	}

	@Override
	public void deleteFile(String key) throws IOException {
		if (key == null || key.isEmpty()) {
			return;
		}

		log.info("Soft deleting file by marking as old: {}", key);
		File file = new File(baseDirectory, key);

		if (!file.exists() || !file.isFile()) {
			log.warn("File not found for deletion: {}", file.getAbsolutePath());
			return;
		}

		try {
			File oldFile = new File(baseDirectory, getOldFileKey(key));

			// Create parent directory if needed
			File oldFileDir = oldFile.getParentFile();
			if (!oldFileDir.exists() && !oldFileDir.mkdirs()) {
				throw new IOException("Failed to create directory: " + oldFileDir.getAbsolutePath());
			}

			// Copy file to old_ version
			Files.copy(file.toPath(), oldFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

			// Delete original file
			if (!file.delete()) {
				log.warn("Failed to delete original file after marking as old: {}", file.getAbsolutePath());
			}

			log.info("File marked as old successfully: {} -> {}", key, oldFile.getName());
		} catch (IOException e) {
			log.error("Failed to mark file as old: {}", key, e);
			throw new IOException("Failed to delete file", e);
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