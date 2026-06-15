package com.srrfrr.api.constants;

/**
 * Storage path constants for organizing files in S3/local storage.
 * Structure:
 * - public/{userId}/profile_picture_{timestamp}.ext
 * - public/{userId}/vehicle_{timestamp}.ext
 * - private/drivers/{driverId}/{documentType}_{timestamp}.ext
 */
public final class StoragePaths {

	private StoragePaths() {
		throw new UnsupportedOperationException("Utility class");
	}

	private static final String PUBLIC_ROOT = "public";
	private static final String PRIVATE_DRIVERS_ROOT = "private/drivers";

	/**
	 * Get public folder path for a user.
	 * 
	 * @param userId the user ID
	 * @return path like "public/uuid-1234"
	 */
	public static String getPublicUserFolder(String userId) {
		return PUBLIC_ROOT + "/" + userId;
	}

	/**
	 * Get private folder path for a driver.
	 * 
	 * @param driverId the driver ID
	 * @return path like "private/drivers/uuid-1234"
	 */
	public static String getPrivateDriverFolder(String driverId) {
		return PRIVATE_DRIVERS_ROOT + "/" + driverId;
	}

	/**
	 * Build filename with timestamp.
	 * 
	 * @param prefix    file prefix (e.g., "profile_picture", "cin_recto")
	 * @param extension file extension
	 * @return filename like "profile_picture_1234567890.png"
	 */
	public static String buildFilename(String prefix, String extension) {
		long timestamp = System.currentTimeMillis();
		return String.format("%s_%d.%s", prefix, timestamp, extension);
	}

	/**
	 * Check if path is private.
	 */
	public static boolean isPrivatePath(String path) {
		return path != null && path.startsWith("private/");
	}
}