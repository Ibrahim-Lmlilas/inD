/// Authentication Provider
///
/// Manages authentication state and coordinates with repository
/// Path: lib/features/auth/presentation/providers/auth_provider.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/fcm_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/features/auth/data/models/auth_models.dart';
import 'package:srrfrr_app_front/features/auth/data/repositories/auth_repository.dart';
import 'dart:io';

import 'package:srrfrr_app_front/features/auth/data/services/auth_service.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

/// Registration step enumeration
enum RegistrationStep {
  kycInput,
  otpVerification,
  registrationSuccess,
  completed,
}

/// Temporary registration data holder
class TempRegistrationData {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final Gender gender;
  final String password;
  final InterfaceType interfaceType;
  final String? email;
  final String? profilePhotoPath;
  final bool termsAccepted;

  const TempRegistrationData({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.password,
    required this.interfaceType,
    this.email,
    this.profilePhotoPath,
    required this.termsAccepted,
  });
}

/// Authentication provider for managing auth state
class AuthProvider extends DisposableProvider {
  final AuthRepository _repository;
  final FCMService _fcmService;
  final LanguageProvider _languageProvider;
  final UserProvider _userProvider;

  AuthProvider({
    AuthRepository? repository,
    FCMService? fcmService,
    required LanguageProvider languageProvider,
    required UserProvider userProvider,
  }) : _repository =
            repository ?? AuthRepository(AuthService(ApiInterceptor())),
        _fcmService = fcmService ?? FCMService(),
        _languageProvider = languageProvider,
        _userProvider = userProvider;
  // State
  RegistrationStep _currentStep = RegistrationStep.kycInput;
  TempRegistrationData? _tempData;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  RegistrationStep get currentRegistrationStep => _currentStep;
  TempRegistrationData? get tempRegistrationData => _tempData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Registration progress
  int get currentStepNumber => _currentStep.index + 1;
  int get totalRegistrationSteps => 2;

  // Temp data convenience getters
  String? get tempPhoneNumber => _tempData?.phoneNumber;
  String? get tempFirstName => _tempData?.firstName;
  String? get tempLastName => _tempData?.lastName;
  Gender? get tempGender => _tempData?.gender;
  String? get tempEmail => _tempData?.email;
  InterfaceType? get tempInterfaceType => _tempData?.interfaceType;

  // ============================================================================
  // LOGIN
  // ============================================================================

  /// Login user and return tokens
  Future<LoginResponse?> login(String phoneNumber, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final cleanPhone = _repository.normalizePhoneNumber(phoneNumber);
      final deviceId = await _getDeviceId();
      final fcmToken = await _getFcmToken();

      final credentials = LoginCredentials(
        phoneNumber: cleanPhone,
        password: password,
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      final result = await _repository.login(credentials);

      if (result.success && result.data != null) {
        _setLoading(false);
        logSuccess('[AuthProvider]', '✅ Login successful');
        return result.data;
      } else {
        _setError(result.error ?? 'Échec de la connexion');
        return null;
      }
    } catch (e) {
      _setError('Erreur lors de la connexion');
      logError('[AuthProvider]', '❌ Login error: $e');
      return null;
    }
  }

  // ============================================================================
  // LOGOUT
  // ============================================================================

  /// Logout user
  Future<bool> logout(String password) async {
    try {
      _setLoading(true);

      final result = await _repository.logout(password);

      _setLoading(false);

      if (result.success) {
        logSuccess('[AuthProvider]', '✅ Logout successful');
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors de la déconnexion');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la déconnexion');
      logError('[AuthProvider]', '❌ Logout error: $e');
      return false;
    }
  }

  // ============================================================================
  // REGISTRATION FLOW
  // ============================================================================

  /// Set KYC information for registration
  void setKycInformation({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required String password,
    String? email,
    String? profilePhotoPath,
    bool termsAccepted = false,
    InterfaceType? interfaceType,
  }) {
    _tempData = TempRegistrationData(
      phoneNumber: _repository.normalizePhoneNumber(phoneNumber),
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      password: password,
      interfaceType:
          interfaceType ??
          (gender == Gender.female
              ? InterfaceType.regular
              : InterfaceType.regular),
      email: email,
      profilePhotoPath: profilePhotoPath,
      termsAccepted: termsAccepted,
    );
    safeNotify();
  }

  /// Update interface type for female users
  void setUserInterfaceType(InterfaceType interfaceType) {
    if (_tempData != null) {
      _tempData = TempRegistrationData(
        phoneNumber: _tempData!.phoneNumber,
        firstName: _tempData!.firstName,
        lastName: _tempData!.lastName,
        gender: _tempData!.gender,
        password: _tempData!.password,
        interfaceType: interfaceType,
        email: _tempData!.email,
        profilePhotoPath: _tempData!.profilePhotoPath,
        termsAccepted: _tempData!.termsAccepted,
      );
      safeNotify();
    }
  }

  /// Proceed from KYC step - send OTP
  Future<bool> proceedFromKyc() async {
    if (_tempData == null) {
      _setError('Données manquantes');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final language = _languageProvider.currentLanguage ?? Language.french;
      final result = await _repository.sendOtp(
        _tempData!.phoneNumber,
        language,
      );

      // User can still use previously sent OTP or retry from OTP screen
      _currentStep = RegistrationStep.otpVerification;
      _setLoading(false);

      if (result.success && result.data != null) {
        if (result.data!.success) {
          // OTP sent successfully
          return true;
        } else {
          // OTP send failed but we still proceed to OTP screen
          _setError(result.data!.message ?? 'Erreur lors de l\'envoi du code');
          return false;
        }
      } else {
        // OTP send failed but we still proceed to OTP screen
        _setError(result.error ?? 'Erreur lors de l\'envoi du code');
        return false;
      }
    } catch (e) {
      _currentStep = RegistrationStep.otpVerification;
      _setError('Erreur lors de l\'envoi du code');
      _setLoading(false);
      logError('[AuthProvider]', '❌ OTP send error: $e');
      return false;
    }
  }

  /// Verify OTP and complete registration
  Future<bool> verifyOtpAndRegister(String otpCode) async {
    if (_tempData == null) {
      _setError('Données manquantes');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final deviceId = await _getDeviceId();
      final fcmToken = await _getFcmToken();
      final language = _languageProvider.currentLanguage ?? Language.french;

      final registrationData = RegistrationData(
        phoneNumber: _tempData!.phoneNumber,
        firstName: _tempData!.firstName,
        lastName: _tempData!.lastName,
        gender: _tempData!.gender.toBackend(),
        password: _tempData!.password,
        language: language.toBackend(),
        interfaceType: _tempData!.interfaceType.toBackend(),
        email: _tempData!.email,
        profilePhotoPath: _tempData!.profilePhotoPath,
        termsAccepted: _tempData!.termsAccepted,
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      final result = await _repository.register(
        data: registrationData,
        otpCode: otpCode,
      );

      if (result.success && result.data != null) {
        final authenticated = await _userProvider.completeRegistration(
          accessToken: result.data!.accessToken!,
          refreshToken: result.data!.refreshToken!,
          userId: result.data!.userId!,
        );

        if (authenticated) {
          _currentStep = RegistrationStep.registrationSuccess;
          _setLoading(false);
          return true;
        } else {
          _setError('Failed to authenticate user');
          _setLoading(false);
          return false;
        }
      } else {
        _setError(result.error ?? 'Erreur lors de l\'inscription');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de l\'inscription');
      logError('[AuthProvider]', '❌ Registration error: $e');
      return false;
    }
  }

  /// Resend OTP code
  Future<bool> resendOtp() async {
    if (_tempData == null) {
      _setError('Aucun numéro de téléphone trouvé');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final language = _languageProvider.currentLanguage ?? Language.french;
      final result = await _repository.sendOtp(_tempData!.phoneNumber, language);

      _setLoading(false);

      if (result.success && result.data != null) {
        return result.data!.success;
      } else {
        _setError(result.error ?? 'Erreur lors du renvoi');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors du renvoi');
      logError('[AuthProvider]', '❌ Resend OTP error: $e');
      return false;
    }
  }

  /// Complete registration flow
  void completeRegistrationFlow() {
    _currentStep = RegistrationStep.completed;
    _tempData = null;
    safeNotify();
  }

  /// Go to previous step
  void goToPreviousStep() {
    switch (_currentStep) {
      case RegistrationStep.otpVerification:
        _currentStep = RegistrationStep.kycInput;
        break;
      default:
        break;
    }
    safeNotify();
  }

  /// Reset registration state
  void resetRegistration() {
    _tempData = null;
    _currentStep = RegistrationStep.kycInput;
    _clearError();
    safeNotify();
  }

  // ============================================================================
  // PASSWORD RESET
  // ============================================================================

  /// Send OTP for password reset
  Future<OtpResponse?> sendPasswordResetOtp(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final cleanPhone = _repository.normalizePhoneNumber(phoneNumber);
      final language = _languageProvider.currentLanguage ?? Language.french;
      final result = await _repository.sendOtp(
        cleanPhone,
        language
      );

      _setLoading(false);

      if (result.success && result.data != null) {
        return result.data;
      } else {
        _setError(result.error ?? 'Erreur lors de l\'envoi du code');
        return null;
      }
    } catch (e) {
      _setError('Erreur lors de l\'envoi du code');
      logError('[AuthProvider]', '❌ Send reset OTP error: $e');
      return null;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cleanPhone = _repository.normalizePhoneNumber(phoneNumber);

      final request = PasswordResetRequest(
        phoneNumber: cleanPhone,
        otp: otp,
        newPassword: newPassword,
      );

      final result = await _repository.resetPassword(request);

      _setLoading(false);

      if (result.success) {
        logSuccess('[AuthProvider]', '✅ Password reset successful');
        return true;
      } else {
        _setError(result.error ?? 'Code OTP invalide ou expiré');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la réinitialisation');
      logError('[AuthProvider]', '❌ Reset password error: $e');
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

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

  @override
  void dispose() {
    logDebug('[AuthProvider]', '🗑️ Disposing AuthProvider');
    _tempData = null;
    _clearError();
    super.dispose();
  }
}
