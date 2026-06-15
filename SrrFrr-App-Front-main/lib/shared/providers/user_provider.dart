import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/fcm_service.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/features/auth/data/services/auth_service.dart';
import 'package:srrfrr_app_front/features/notifications/data/services/notification_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/notifications/data/models/notification.dart';
import 'package:srrfrr_app_front/features/profile/data/services/profile_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/user.dart';

enum UserMode { passenger, driver }

class UserProvider extends DisposableProvider {
  final NotificationService _notificationService = NotificationService();
  final ProfileService _profileService = ProfileService(ApiInterceptor());
  final AuthService authService = AuthService(ApiInterceptor());
  final FCMService _fcmService = FCMService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LanguageProvider _languageProvider;

  UserProvider({required LanguageProvider languageProvider})
    : _languageProvider = languageProvider;

  // Storage keys
  static const String _userDataKey = 'user_data';
  static const String _userModeKey = 'user_mode';
  static const String _isAuthenticatedKey = 'is_authenticated';

  // State
  User? _currentUser;
  UserMode _currentMode = UserMode.passenger;
  Map<String, dynamic>? _driverProfile;
  Map<String, dynamic>? _activeRideData;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  UserMode get currentMode => _currentMode;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isPassengerMode => _currentMode == UserMode.passenger;
  bool get isDriverMode => _currentMode == UserMode.driver;

  // Passenger data
  double get passengerWallet => _currentUser?.wallet ?? 0.0;
  int get points => _currentUser?.points ?? 0;
  double get passengerRating => _currentUser?.rating ?? 0.0;
  int get passengerTotalRides => _currentUser?.totalRides ?? 0;
  String? get passengerProfilePicture => _currentUser?.profilePhotoPath;

  // Driver data
  Map<String, dynamic>? get driverProfile => _driverProfile;
  String? get driverApprovalStatus => _driverProfile?['approval'];
  double get driverWallet =>
      (_driverProfile?['wallet'] as num?)?.toDouble() ?? 0.0;
  double get driverRating {
    final rating = _driverProfile?['rating'];
    if (rating == null) return 0.0;
    if (rating is num) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  int get driverTotalRides => _driverProfile?['totalRides'] as int? ?? 0;
  bool get driverVerified => _driverProfile?['verified'] as bool? ?? false;
  bool get driverOnline => _driverProfile?['online'] as bool? ?? false;
  String? get driverProfilePicture => _driverProfile?['profilePicture'];

  // Vehicle info
  String? get vehicleType => _driverProfile?['vehicleType'];
  String? get vehicleRegistrationCode =>
      _driverProfile?['vehicleRegistrationCode'];
  String? get vehicleBrand => _driverProfile?['vehicleBrand'];
  String? get vehicleModel => _driverProfile?['vehicleModel'];
  String? get vehicleColor => _driverProfile?['vehicleColor'];
  String? get productionYear => _driverProfile?['productionYear'];
  String? get vehiclePicture => _driverProfile?['vehiclePicture'];

  // Driver status checks
  bool get hasDriverProfile => _driverProfile != null;
  bool get isDriverRegistered => _driverProfile != null;
  bool get isDriverPending => driverApprovalStatus == 'PENDING';
  bool get isDriverValidated => driverApprovalStatus == 'VALIDATED';
  bool get isDriverRejected => driverApprovalStatus == 'REJECTED';

  // Other
  bool get hasProfilePicture =>
      _currentUser?.profilePhotoPath?.isNotEmpty ?? false;
  Map<String, dynamic>? get activeRideData => _activeRideData;
  Stream<AppNotification> get notifications =>
      _notificationService.notifications;

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) {
      logDebug('[UserProvider]', '⚠️ Already initialized');
      return;
    }

    try {
      _setLoading(true);
      logDebug('[UserProvider]', '🚀 Initializing...');

      final wasAuthenticated = await _checkAuthenticationStatus();

      if (wasAuthenticated) {
        logDebug('[UserProvider]', '🔍 Previous session found, restoring...');

        await _loadUserMode();
        await _loadSavedUserData();

        if (_currentUser != null) {
          final isValid = await _validateSession();

          if (isValid) {
            await _initializeNotifications();
            logSuccess(
              '[UserProvider]',
              '✅ Session restored - Mode: ${_currentMode.name}',
            );
          } else {
            logWarning('[UserProvider]', '⚠️ Session expired, clearing data');
            await _clearSession();
          }
        } else {
          logWarning(
            '[UserProvider]',
            '⚠️ No user data found, clearing session',
          );
          await _clearSession();
        }
      } else {
        logDebug('[UserProvider]', 'ℹ️ No previous session found');
      }

      _isInitialized = true;
      _setLoading(false);
      logSuccess('[UserProvider]', '✅ UserProvider initialized');
    } catch (e) {
      _isInitialized = true;
      _setLoading(false);
      logError('[UserProvider]', '❌ Initialization error: $e');
    }
  }

  // Session validation
  Future<bool> _checkAuthenticationStatus() async {
    try {
      final status = await _secureStorage.read(key: _isAuthenticatedKey);
      return status == 'true';
    } catch (e) {
      logError('[UserProvider]', '❌ Error checking auth status: $e');
      return false;
    }
  }

  Future<void> _markAsAuthenticated() async {
    try {
      await _secureStorage.write(key: _isAuthenticatedKey, value: 'true');
      logDebug('[UserProvider]', '✅ Marked as authenticated');
    } catch (e) {
      logError('[UserProvider]', '❌ Error marking authenticated: $e');
    }
  }

  Future<bool> _validateSession() async {
    try {
      logDebug('[UserProvider]', '🔍 Validating session...');

      final response = await _profileService.getPassengerProfile();

      if (response['success'] == true) {
        _currentUser = User.fromJson(response['user']);
        await _saveUserData(_currentUser!);

        if (_currentMode == UserMode.driver) {
          await fetchDriverProfile();
        }

        logSuccess('[UserProvider]', '✅ Session valid and refreshed');
        safeNotify();
        return true;
      }

      return false;
    } catch (e) {
      logError('[UserProvider]', '❌ Session validation failed: $e');
      return false;
    }
  }

  // User data persistence
  Future<void> _saveUserData(User user) async {
    try {
      final userData = jsonEncode(user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userData);
      logSuccess('[UserProvider]', '✅ User data saved to cache');
    } catch (e) {
      logError('[UserProvider]', '❌ Error saving user data: $e');
    }
  }

  Future<void> _loadSavedUserData() async {
    try {
      final userDataString = await _secureStorage.read(key: _userDataKey);
      if (userDataString != null) {
        final userJson = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = User.fromJson(userJson);
        logSuccess(
          '[UserProvider]',
          '✅ Cached user data loaded: ${_currentUser?.fullName}',
        );
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Error loading user data: $e');
    }
  }

  // Mode management
  Future<void> switchMode(UserMode newMode) async {
    if (_currentMode == newMode) return;

    try {
      logDebug(
        '[UserProvider]',
        '🔄 Switching mode: ${_currentMode.name} → ${newMode.name}',
      );

      await _notificationService.switchMode(
        isPassengerMode: newMode == UserMode.passenger,
      );

      _currentMode = newMode;
      await _saveUserMode(newMode);

      if (newMode == UserMode.driver) {
        await fetchDriverProfile();
      } else {
        await refreshPassengerProfile();
      }

      safeNotify();
      logSuccess('[UserProvider]', '✅ Mode switched: ${newMode.name}');
    } catch (e) {
      logError('[UserProvider]', '❌ Mode switch error: $e');
    }
  }

  Future<void> _saveUserMode(UserMode mode) async {
    try {
      await _secureStorage.write(key: _userModeKey, value: mode.name);
    } catch (e) {
      logError('[UserProvider]', '❌ Error saving mode: $e');
    }
  }

  Future<void> _loadUserMode() async {
    try {
      final modeString = await _secureStorage.read(key: _userModeKey);
      if (modeString != null) {
        _currentMode = UserMode.values.firstWhere(
          (mode) => mode.name == modeString,
          orElse: () => UserMode.passenger,
        );
        logDebug('[UserProvider]', '✅ Mode loaded: ${_currentMode.name}');
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Error loading mode: $e');
      _currentMode = UserMode.passenger;
    }
  }

  // Profile picture helpers
  static bool isValidProfilePicture(String? path) {
    if (path == null || path.isEmpty) return false;
    if (path == 'null' || path == 'undefined') return false;
    return true;
  }

  static String? getProfilePictureUrl(String? path) {
    if (!isValidProfilePicture(path)) return null;

    if (path!.contains('localhost')) {
      return path.replaceAll('localhost', '192.168.100.197');
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return 'http://192.168.100.197:8080/api/$path';
  }

  String? getCurrentUserProfilePictureUrl() {
    return getProfilePictureUrl(_currentUser?.profilePhotoPath);
  }

  String? getDriverProfilePictureUrl() {
    return getProfilePictureUrl(_driverProfile?['profilePicture']);
  }

  static String getInitial(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  Future<bool> completeRegistration({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    try {
      _setLoading(true);
      logDebug(
        '[UserProvider]',
        '🎉 Completing registration for user: $userId',
      );

      // Tokens are already saved by AuthService, just fetch the profile
      final profileResponse = await _profileService.getPassengerProfile();

      if (profileResponse['success'] == true &&
          profileResponse['user'] != null) {
        _currentUser = User.fromJson(profileResponse['user']);
        _currentMode = UserMode.passenger;

        await _saveUserData(_currentUser!);
        await _markAsAuthenticated();
        await _saveUserMode(_currentMode);
        await _initializeNotifications();

        _setLoading(false);
        logSuccess(
          '[UserProvider]',
          '✅ Registration completed - User authenticated',
        );
        return true;
      } else {
        _setError('Failed to load user profile');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error completing registration');
      logError('[UserProvider]', '❌ Registration completion error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Language sync
  Future<void> syncLanguageWithBackend(Language language) async {
    if (!isAuthenticated) return;

    try {
      logDebug(
        '[UserProvider]',
        '🔄 Syncing language with backend: ${language.toBackend()}',
      );

      final response = await _profileService.updateLanguage(
        language: language.toBackend(),
      );

      if (response['success'] == true) {
        _currentUser = _currentUser!.copyWith(language: language);
        await _saveUserData(_currentUser!);
        logSuccess('[UserProvider]', '✅ Language synced with backend');
        safeNotify();
      } else {
        logError('[UserProvider]', '❌ Failed to sync language with backend');
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Error syncing language: $e');
    }
  }

  // Passenger profile methods
  Future<void> refreshPassengerProfile() async {
    if (!isAuthenticated) return;

    try {
      logDebug('[UserProvider]', '🔄 Refreshing passenger profile...');

      final response = await _profileService.getPassengerProfile();

      if (response['success'] == true && response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        await _saveUserData(_currentUser!);

        if (_currentUser!.language != _languageProvider.currentLanguage) {
          await _languageProvider.changeLanguage(_currentUser!.language);
        }

        safeNotify();
        logSuccess('[UserProvider]', '✅ Profile refreshed');
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Refresh error: $e');
    }
  }

  Future<void> fetchPassengerProfile() async {
    await refreshPassengerProfile();
  }

  // Driver profile methods
  Future<void> fetchDriverProfile() async {
    if (!isAuthenticated) return;

    try {
      logDebug('[UserProvider]', '🚗 Fetching driver profile...');

      final response = await _profileService.getDriverProfile();

      if (response['success'] == true && response['driver'] != null) {
        _driverProfile = response['driver'];
        safeNotify();
        logSuccess('[UserProvider]', '✅ Driver profile loaded');
      } else {
        _driverProfile = null;
        safeNotify();
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Driver profile error: $e');
      _driverProfile = null;
    }
  }

  void clearDriverProfile() {
    _driverProfile = null;
    safeNotify();
  }

  // Login - delegates to AuthProvider
  Future<bool> login(
    String phoneNumber,
    String password, {
    UserMode? mode,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final cleanPhone = _normalizePhoneNumber(phoneNumber);
      final deviceId = await _getDeviceId();
      final fcmToken = await _getFcmToken();

      final response = await authService.login(
        cleanPhone,
        password,
        fcmToken,
        deviceId,
      );

      if (response['success'] == true) {
        final profileResponse = await _profileService.getPassengerProfile();

        if (profileResponse['success'] == true) {
          _currentUser = User.fromJson(profileResponse['user']);
          _currentMode = mode ?? UserMode.passenger;

          await _saveUserData(_currentUser!);
          await _markAsAuthenticated();
          await _saveUserMode(_currentMode);
          await _initializeNotifications();

          _setLoading(false);
          logSuccess('[UserProvider]', '✅ Login successful');
          return true;
        }
      }

      _setError(response['message'] ?? 'Login failed');
      return false;
    } catch (e) {
      _setError('Connection error');
      logError('[UserProvider]', '❌ Login error: $e');
      return false;
    }
  }

  // Logout
Future<void> logout(String password) async {
    try {
      _setLoading(true);
      logDebug('[UserProvider]', '🚪 Attempting logout...');

      final response = await authService.logout(password);

      if (response['success'] != true) {
        final errorMsg = response['message'] ?? 'Logout failed';
        _setError(errorMsg);
        _setLoading(false);
        logError('[UserProvider]', '❌ Logout failed: $errorMsg');
        return; // Don't throw, just return
      }

      // Only clear session if logout was successful
      await _notificationService.disconnect();
      await _fcmService.deleteToken();
      await _clearSession();

      _setLoading(false);
      logSuccess('[UserProvider]', '✅ Logout successful');
    } catch (e) {
      _setError('Connection error');
      logError('[UserProvider]', '❌ Logout error: $e');
      _setLoading(false);
    }
  }

  // Cleanup
  Future<void> _clearSession() async {
    _currentUser = null;
    _currentMode = UserMode.passenger;
    _driverProfile = null;
    _activeRideData = null;
    _clearError();

    await _secureStorage.delete(key: _userDataKey);
    await _secureStorage.delete(key: _userModeKey);
    await _secureStorage.delete(key: _isAuthenticatedKey);

    safeNotify();
  }

  Future<void> _cleanupSessionLocally() async {
    try {
      logDebug('[UserProvider]', 'Cleaning up session locally...');

      await _notificationService.disconnect();
      await _fcmService.deleteToken();

      _currentUser = null;
      _currentMode = UserMode.passenger;
      _driverProfile = null;
      _activeRideData = null;
      _clearError();

      await _secureStorage.deleteAll();

      logSuccess('[UserProvider]', '✅ Local cleanup completed');
      safeNotify();
    } catch (e) {
      logError('[UserProvider]', '❌ Local cleanup error: $e');
    }
  }

  // Notification initialization
  Future<void> _initializeNotifications() async {
    if (_currentUser == null) return;

    try {
      await _notificationService.initialize(_currentUser!.id);

      if (_currentMode == UserMode.passenger) {
        await _notificationService.subscribeToPassengerTopics();
      } else {
        await _notificationService.subscribeToDriverTopics();
      }

      logSuccess('[UserProvider]', '✅ Notifications initialized');
    } catch (e) {
      logError('[UserProvider]', '❌ Notification init error: $e');
    }
  }

  // Profile updates
  Future<bool> updateInterfaceType(InterfaceType newType) async {
    if (!isAuthenticated || _currentUser == null) {
      logError(
        '[UserProvider]',
        '❌ Cannot update interface - not authenticated',
      );
      return false;
    }

    try {
      logDebug(
        '[UserProvider]',
        '🔄 Updating interface type to: ${newType.name}',
      );

      final interfaceType = newType == InterfaceType.ladies
          ? 'LADIES'
          : 'REGULAR';

      final response = await _profileService.updateInterfaceType(
        interfaceType: interfaceType,
      );

      if (response['success'] == true) {
        _currentUser = _currentUser!.copyWith(interfaceType: newType);
        await _saveUserData(_currentUser!);

        logSuccess(
          '[UserProvider]',
          '✅ Interface type updated: ${newType.name}',
        );
        safeNotify();
        return true;
      } else {
        logError(
          '[UserProvider]',
          '❌ Failed to update interface type in backend',
        );
        return false;
      }
    } catch (e) {
      logError('[UserProvider]', '❌ Error updating interface type: $e');
      return false;
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    try {
      logInfo('[UserProvider]', 'Updating profile picture');

      _isLoading = true;
      safeNotify();

      final response = await _profileService.updateProfilePicture(
        imagePath: imagePath,
      );

      if (response['success'] == true) {
        logSuccess('[UserProvider]', 'Profile picture updated successfully');

        await fetchPassengerProfile();

        _isLoading = false;
        safeNotify();

        return true;
      } else {
        logError(
          '[UserProvider]',
          'Failed to update profile picture: ${response['message']}',
        );
        _errorMessage = response['message'] ?? 'Échec de la mise à jour';

        _isLoading = false;
        safeNotify();

        return false;
      }
    } catch (e) {
      logError('[UserProvider]', 'Error updating profile picture: $e');
      _errorMessage = 'Erreur lors de la mise à jour de la photo';

      _isLoading = false;
      safeNotify();

      return false;
    }
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String password,
    required String reason,
    required bool confirmed,
  }) async {
    try {
      final result = await _profileService.deleteUserAccount(
        password: password,
        reason: reason,
        confirmed: confirmed,
      );

      if (result['success'] == true) {
        await _cleanupSessionLocally();
        logSuccess('[UserProvider]', '✅ Account deleted and cleaned up');
      }

      return result;
    } catch (e) {
      logError('[UserProvider]', 'Delete account error: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la suppression du compte',
      };
    }
  }

  // Navigation
  String getInitialRoute() {
    if (!isAuthenticated) return '/auth';

    switch (_currentMode) {
      case UserMode.passenger:
        return '/home';
      case UserMode.driver:
        return getDriverRoute();
    }
  }

  String getDriverRoute() {
    if (!hasDriverProfile) return '/driver-registration';

    switch (driverApprovalStatus) {
      case 'PENDING':
      case 'REJECTED':
        return '/driver-status';
      case 'VALIDATED':
        return '/driver-home';
      default:
        return '/driver-registration';
    }
  }

  Future<String?> checkForActiveRide() async {
    if (!isAuthenticated || _currentUser == null) {
      return null;
    }

    try {
      logDebug('[UserProvider]', '🔍 Checking for active ride...');

      final response = _currentMode == UserMode.driver
          ? await _profileService.getDriverProfile()
          : await _profileService.getPassengerProfile();

      if (response['success'] != true) {
        logWarning('[UserProvider]', '⚠️ Failed to check for active ride');
        return null;
      }

      final userData = _currentMode == UserMode.driver
          ? response['driver']
          : response['user'];

      final currentRide = userData?['currentRide'] as Map<String, dynamic>?;

      if (currentRide != null) {
        logSuccess(
          '[UserProvider]',
          '✅ Active ride found: ${currentRide['id']}',
        );

        _activeRideData = currentRide;

        return '/ride-tracking';
      }

      logDebug('[UserProvider]', 'ℹ️ No active ride found');
      return null;
    } catch (e) {
      logError('[UserProvider]', '❌ Error checking for active ride: $e');
      return null;
    }
  }

  void clearActiveRideData() {
    _activeRideData = null;
    safeNotify();
  }

  Future<void> refreshUserProfile() async {
    if (!isAuthenticated) {
      logWarning('[UserProvider]', '⚠️ Cannot refresh - not authenticated');
      return;
    }

    if (_currentMode == UserMode.passenger) {
      await refreshPassengerProfile();
    } else {
      await fetchDriverProfile();
    }
  }

  // Helper methods
  String _normalizePhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('212')) cleaned = cleaned.substring(3);
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    return '+212$cleaned';
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      return 'unknown_device';
    } catch (e) {
      return 'unknown_device';
    }
  }

  Future<String> _getFcmToken() async {
    try {
      return _fcmService.fcmToken ??
          'fcm_fallback_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'fcm_fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    safeNotify();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    safeNotify();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      safeNotify();
    }
  }
}
