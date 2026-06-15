// Authentication Repository
//
// Handles all authentication business logic and data access
// Path: lib/features/auth/data/repositories/auth_repository.dart

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/auth/data/models/auth_models.dart';
import 'package:srrfrr_app_front/features/auth/data/services/auth_service.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

/// Authentication repository handling business logic
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // ============================================================================
  // LOGIN
  // ============================================================================

  /// Login user with credentials
  Future<AuthResult<LoginResponse>> login(LoginCredentials credentials) async {
    try {
      logDebug('[AuthRepository]', '🔐 Attempting login...');

      final response = await _authService.login(
        credentials.phoneNumber,
        credentials.password,
        credentials.fcmToken,
        credentials.deviceId,
      );

      if (response['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response);

        logSuccess(
          '[AuthRepository]',
          '✅ Login successful - User: ${loginResponse.userId}',
        );

        return AuthResult.success(loginResponse);
      } else {
        final errorMsg = response['message'] ?? 'Échec de la connexion';
        logError('[AuthRepository]', '❌ Login failed: $errorMsg');
        return AuthResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[AuthRepository]', '❌ Login exception: $e');
      logError('[AuthRepository]', 'Stack: $stackTrace');
      return AuthResult.failure('Erreur lors de la connexion');
    }
  }

  // ============================================================================
  // LOGOUT
  // ============================================================================

  /// Logout user
  Future<AuthResult<void>> logout(String password) async {
    try {
      logDebug('[AuthRepository]', '🚪 Attempting logout...');

      final response = await _authService.logout(password);

      if (response['success'] == true) {
        logSuccess('[AuthRepository]', '✅ Logout successful');
        return AuthResult.success(null);
      } else {
        final errorMsg = response['message'] ?? 'Erreur lors de la déconnexion';
        logError('[AuthRepository]', '❌ Logout failed: $errorMsg');
        return AuthResult.failure(errorMsg);
      }
    } catch (e) {
      logError('[AuthRepository]', '❌ Logout exception: $e');
      return AuthResult.failure('Erreur lors de la déconnexion');
    }
  }

  // ============================================================================
  // OTP OPERATIONS
  // ============================================================================

  /// Send OTP to phone number
  Future<AuthResult<OtpResponse>> sendOtp(
    String phoneNumber,
    Language language,
  ) async {
    try {
      logDebug('[AuthRepository]', '📱 Sending OTP to: $phoneNumber');

      final response = await _authService.sendOtp(phoneNumber, language);

      final otpResponse = OtpResponse.fromJson(response);

      if (otpResponse.success) {
        logSuccess('[AuthRepository]', '✅ OTP sent successfully');
      } else {
        logError(
          '[AuthRepository]',
          '❌ OTP send failed: ${otpResponse.message}',
        );
      }

      return AuthResult.success(otpResponse);
    } catch (e) {
      logError('[AuthRepository]', '❌ Send OTP exception: $e');
      return AuthResult.failure('Erreur lors de l\'envoi du code');
    }
  }

  /// Validate OTP code
  Future<AuthResult<void>> validateOtp(OtpRequest request) async {
    try {
      logDebug('[AuthRepository]', '🔐 Validating OTP...');

      final response = await _authService.validateOtp(
        request.phoneNumber,
        request.otp!,
      );

      if (response['success'] == true) {
        logSuccess('[AuthRepository]', '✅ OTP valid');
        return AuthResult.success(null);
      } else {
        final errorMsg = response['message'] ?? 'Code OTP invalide';
        logError('[AuthRepository]', '❌ OTP validation failed: $errorMsg');
        return AuthResult.failure(errorMsg);
      }
    } catch (e) {
      logError('[AuthRepository]', '❌ Validate OTP exception: $e');
      return AuthResult.failure('Code OTP invalide');
    }
  }

  // ============================================================================
  // PASSWORD RESET
  // ============================================================================

  /// Reset password using OTP
  Future<AuthResult<void>> resetPassword(PasswordResetRequest request) async {
    try {
      logDebug('[AuthRepository]', '🔑 Resetting password...');

      final response = await _authService.resetPassword(
        phoneNumber: request.phoneNumber,
        otp: request.otp,
        newPassword: request.newPassword,
      );

      if (response['success'] == true) {
        logSuccess('[AuthRepository]', '✅ Password reset successful');
        return AuthResult.success(null);
      } else {
        final errorMsg = response['message'] ?? 'Code OTP invalide ou expiré';
        logError('[AuthRepository]', '❌ Password reset failed: $errorMsg');
        return AuthResult.failure(errorMsg);
      }
    } catch (e) {
      logError('[AuthRepository]', '❌ Reset password exception: $e');
      return AuthResult.failure('Erreur lors de la réinitialisation');
    }
  }

  // ============================================================================
  // REGISTRATION
  // ============================================================================

  /// Register new passenger account
  Future<AuthResult<LoginResponse>> register({
    required RegistrationData data,
    required String otpCode,
  }) async {
    try {
      logDebug('[AuthRepository]', '🆕 Registering new user...');

      final response = await _authService.register(
        registrationData: data,
        otpCode: otpCode,
      );

      if (response['success'] == true) {
        final loginResponse = LoginResponse.fromJson(response);

        logSuccess(
          '[AuthRepository]',
          '✅ Registration successful - User: ${loginResponse.userId}',
        );

        return AuthResult.success(loginResponse);
      } else {
        final errorMsg = response['message'] ?? 'Échec de l\'inscription';
        logError('[AuthRepository]', '❌ Registration failed: $errorMsg');
        return AuthResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[AuthRepository]', '❌ Registration exception: $e');
      logError('[AuthRepository]', 'Stack: $stackTrace');
      return AuthResult.failure('Erreur lors de l\'inscription');
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Normalize phone number to international format
  String normalizePhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('212')) cleaned = cleaned.substring(3);
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    return '+212$cleaned';
  }

  /// Extract retry time from rate limit error message
  int? extractRetryTime(String message) {
    final match = RegExp(r'(\d+)\s*seconds?').firstMatch(message.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Get user-friendly error message
  String getUserFriendlyError(String? errorMessage) {
    if (errorMessage == null) return 'Une erreur est survenue';

    final lower = errorMessage.toLowerCase();

    // Rate limit errors
    if (lower.contains('blocked') || lower.contains('temporarily')) {
      return 'Trop de tentatives. Veuillez patienter';
    }

    // Invalid credentials
    if (lower.contains('invalid') && lower.contains('credentials')) {
      return 'Identifiants incorrects';
    }

    // Network errors
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Erreur de connexion. Vérifiez votre internet';
    }

    return errorMessage;
  }
}