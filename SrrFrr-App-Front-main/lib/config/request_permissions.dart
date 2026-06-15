import 'package:location/location.dart' as location_pkg;
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class RequestPermissions {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';

  // ============================================================================
  // Location Permissions
  // ============================================================================

  static Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled;
      location_pkg.PermissionStatus permissionGranted;
      final location_pkg.Location location = location_pkg.Location();

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          logWarning('RequestPermissions', 'Location service not enabled');
          return false;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == location_pkg.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_pkg.PermissionStatus.granted) {
          logWarning('RequestPermissions', 'Location permission denied');
          return false;
        }
      }

      logSuccess('RequestPermissions', 'Location permission granted');
      return true;
    } catch (e) {
      logError('RequestPermissions', 'Error requesting location permission: $e');
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    try {
      final location_pkg.Location location = location_pkg.Location();
      return await location.serviceEnabled();
    } catch (e) {
      logError('RequestPermissions', 'Error checking location service: $e');
      return false;
    }
  }

  // ============================================================================
  // Camera Permissions
  // ============================================================================

  static Future<bool> requestCameraPermission() async {
    try {
      logInfo('RequestPermissions', 'Requesting camera permission');

      final status = await permission_handler.Permission.camera.request();

      if (status.isGranted) {
        logSuccess('RequestPermissions', 'Camera permission granted');
        return true;
      } else if (status.isDenied) {
        logWarning('RequestPermissions', 'Camera permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logWarning('RequestPermissions', 'Camera permission permanently denied');
        return false;
      }

      return false;
    } catch (e) {
      logError('RequestPermissions', 'Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> hasCameraPermission() async {
    try {
      final status = await permission_handler.Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      logError('RequestPermissions', 'Error checking camera permission: $e');
      return false;
    }
  }

  // ============================================================================
  // Storage/Photos Permissions
  // ============================================================================

  static Future<bool> requestStoragePermission() async {
    try {
      logInfo('RequestPermissions', 'Checking storage permission');

      // Check current status first
      final currentStatus = await permission_handler.Permission.photos.status;
      
      // If already granted or limited, return true without requesting
      if (currentStatus.isGranted || currentStatus.isLimited) {
        logSuccess('RequestPermissions', 'Storage permission already granted');
        return true;
      }

      // If permanently denied, guide user to settings
      if (currentStatus.isPermanentlyDenied) {
        logWarning('RequestPermissions', 'Storage permission permanently denied - open settings');
        return false;
      }

      // Only request if denied (first time)
      logInfo('RequestPermissions', 'Requesting storage permission');
      final status = await permission_handler.Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        logSuccess('RequestPermissions', 'Storage permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        logWarning('RequestPermissions', 'Storage permission permanently denied');
        return false;
      } else {
        logWarning('RequestPermissions', 'Storage permission denied');
        return false;
      }
    } catch (e) {
      logError('RequestPermissions', 'Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> hasStoragePermission() async {
    try {
      final status = await permission_handler.Permission.photos.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      logError('RequestPermissions', 'Error checking storage permission: $e');
      return false;
    }
  }

  // ============================================================================
  // System Notification Permissions (OS Level)
  // ============================================================================

  static Future<bool> requestNotificationPermission() async {
    try {
      logInfo('RequestPermissions', 'Requesting notification permission');

      final status = await permission_handler.Permission.notification.request();

      if (status.isGranted) {
        logSuccess('RequestPermissions', 'Notification permission granted');
        await setNotificationsEnabled(true);
        return true;
      } else if (status.isDenied) {
        logWarning('RequestPermissions', 'Notification permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logWarning(
          'RequestPermissions',
          'Notification permission permanently denied',
        );
        return false;
      }

      return false;
    } catch (e) {
      logError(
        'RequestPermissions',
        'Error requesting notification permission: $e',
      );
      return false;
    }
  }

  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await permission_handler.Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      logError(
        'RequestPermissions',
        'Error checking notification permission: $e',
      );
      return false;
    }
  }

  // ============================================================================
  // App-Level Notification Settings
  // ============================================================================

  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final systemEnabled = await hasNotificationPermission();
      final appEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;

      return systemEnabled && appEnabled;
    } catch (e) {
      logError(
        'RequestPermissions',
        'Error checking notifications enabled: $e',
      );
      return false;
    }
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      logInfo(
        'RequestPermissions',
        'Notifications ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      logError('RequestPermissions', 'Error setting notifications: $e');
    }
  }

  static Future<bool> isSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_soundEnabledKey) ?? true;
    } catch (e) {
      logError('RequestPermissions', 'Error checking sound enabled: $e');
      return true;
    }
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, enabled);

      logInfo(
        'RequestPermissions',
        'Notification sound ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      logError('RequestPermissions', 'Error setting sound: $e');
    }
  }

  static Future<bool> isVibrationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_vibrationEnabledKey) ?? true;
    } catch (e) {
      logError('RequestPermissions', 'Error checking vibration enabled: $e');
      return true;
    }
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vibrationEnabledKey, enabled);

      logInfo(
        'RequestPermissions',
        'Notification vibration ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      logError('RequestPermissions', 'Error setting vibration: $e');
    }
  }

  // ============================================================================
  // Notification Settings Check
  // ============================================================================

  static Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final systemEnabled = await hasNotificationPermission();
      final appEnabled = await areNotificationsEnabled();
      final soundEnabled = await isSoundEnabled();
      final vibrationEnabled = await isVibrationEnabled();

      return {
        'systemEnabled': systemEnabled,
        'appEnabled': appEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'fullyEnabled': systemEnabled && appEnabled,
      };
    } catch (e) {
      logError(
        'RequestPermissions',
        'Error getting notification settings: $e',
      );
      return {
        'systemEnabled': false,
        'appEnabled': false,
        'soundEnabled': false,
        'vibrationEnabled': false,
        'fullyEnabled': false,
      };
    }
  }

  // ============================================================================
  // Permission Status Check
  // ============================================================================

  static Future<Map<String, bool>> getAllPermissionsStatus() async {
    try {
      return {
        'location': await requestLocationPermission(),
        'camera': await hasCameraPermission(),
        'storage': await hasStoragePermission(),
        'notification': await hasNotificationPermission(),
      };
    } catch (e) {
      logError('RequestPermissions', 'Error getting permissions status: $e');
      return {
        'location': false,
        'camera': false,
        'storage': false,
        'notification': false,
      };
    }
  }

  // ============================================================================
  // Settings Navigation
  // ============================================================================

  static Future<void> openAppSettings() async {
    try {
      await permission_handler.openAppSettings();
      logInfo('RequestPermissions', 'Opened app settings');
    } catch (e) {
      logError('RequestPermissions', 'Error opening app settings: $e');
    }
  }

  // ============================================================================
  // Permission Explanation
  // ============================================================================

  static String getPermissionExplanation(String permissionType) {
    switch (permissionType.toLowerCase()) {
      case 'location':
        return 'L\'accès à la localisation est nécessaire pour trouver des trajets à proximité et naviguer vers votre destination.';
      case 'camera':
        return 'L\'accès à la caméra est nécessaire pour prendre une photo de profil.';
      case 'storage':
        return 'L\'accès aux photos est nécessaire pour sélectionner une photo de profil.';
      case 'notification':
        return 'Les notifications vous permettent de recevoir des alertes importantes sur vos trajets.';
      default:
        return 'Cette permission est nécessaire pour le bon fonctionnement de l\'application.';
    }
  }
}