// Authentication Service
//
// Handles all authentication-related operations:
// - Login/Logout
// - OTP (send, validate)
// - Password reset

import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'dart:convert';

import 'package:srrfrr_app_front/features/auth/data/models/registration_data.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

class AuthService {
  final ApiInterceptor _interceptor;

  AuthService(this._interceptor);

  // ===========================================================================
  // MARK: - Authentication
  // ===========================================================================

  // Login user with credentials
  // Backend: POST /auth/login
  Future<Map<String, dynamic>> login(
    String phoneNumber,
    String password,
    String fcmToken,
    String deviceId,
  ) async {
    try {
      final response = await _interceptor.post(
        'auth/login',
        body: {
          'phoneNumber': phoneNumber,
          'password': password,
          'fcmToken': fcmToken,
          'deviceId': deviceId,
        },
        requiresAuth: false,
      );

      final data = await _handleResponse(response, 'auth/login');

      // Save tokens using interceptor
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        await _interceptor.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
      }

      return {
        'success': true,
        'message': data['message'] ?? 'Connexion réussie',
        'userId': data['id'],
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
      };
    } catch (e) {
      logError('[AuthService]', 'Login Error: $e');

      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {'success': false, 'message': 'Échec de la connexion'};
    }
  }

  // Logout user
  // Backend: POST /auth/logout
  Future<Map<String, dynamic>> logout(String password) async {
    try {
      debugPrint('[AuthService] Logging out user');

      final response = await _interceptor.post(
        'auth/logout',
        body: {'password': password},
        requiresAuth: true,
      );

      final data = await _handleResponse(response, 'auth/logout');

      // Clear tokens
      await _interceptor.clearTokens();

      return {
        'success': true,
        'message': data['message'] ?? 'Déconnexion réussie',
      };
    } catch (e) {
      debugPrint('[AuthService] Logout Error: $e');

      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {'success': false, 'message': 'Erreur lors de la déconnexion'};
    }
  }

// registration
  // Backend: POST auth/passenger/create
  Future<Map<String, dynamic>> register({
    required RegistrationData registrationData,
    required String otpCode,
  }) async {
    try {
      debugPrint('[AuthService] Registering new account');

      final fields = {
        'firstName': registrationData.firstName,
        'lastName': registrationData.lastName,
        'phoneNumber': registrationData.phoneNumber,
        'password': registrationData.password,
        'otpCode': otpCode,
        'gender': registrationData.gender,
        'language': registrationData.language.toUpperCase(),
        'interfaceType': registrationData.interfaceType,
        'termsAccepted': registrationData.termsAccepted.toString(),
        'fcmToken': registrationData.fcmToken,
        'deviceId': registrationData.deviceId,
      };

      // Add email only if provided
      if (registrationData.email != null &&
          registrationData.email!.isNotEmpty) {
        fields['email'] = registrationData.email!;
      }

      // Add profile picture file if provided
      final files = <String, String>{};
      if (registrationData.profilePhotoPath != null &&
          registrationData.profilePhotoPath!.isNotEmpty) {
        files[registrationData.profilePhotoPath!] = 'profilePicture';
      }

      final response = await _interceptor.multipartRequest(
        method: 'POST',
        endpoint: 'auth/passenger/create',
        fields: fields,
        files: files,
        requiresAuth: false,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('[AuthService] Registration successful');

        // Save tokens using interceptor
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await _interceptor.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
          );
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Successfully registered',
          'userId': data['id'],
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint(
          '[AuthService] Registration failed: ${errorData['message']}',
        );

        throw ApiException(
          statusCode: response.statusCode,
          message: errorData['message'] ?? 'Échec de l\'inscription',
          endpoint: 'auth/passenger/create',
        );
      }
    } catch (e) {
      debugPrint('[AuthService] Registration Error: $e');

      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {'success': false, 'message': 'Erreur lors de l\'inscription'};
    }
  }
  
  // ===========================================================================
  // MARK: - OTP
  // ===========================================================================

  // Send OTP to phone number
  // Backend: POST /otp/send
  Future<Map<String, dynamic>> sendOtp(
    String phoneNumber,
    Language language,
  ) async {
    try {
      final response = await _interceptor.post(
        'otp/send',
        body: {
          'phoneNumber': phoneNumber,
          'language': (language).toBackend(),
        },
        requiresAuth: false,
      );

      final data = await _handleResponse(response, 'otp/send');
      return {'success': true, 'message': data['message']};
    } catch (e) {
      if (e is ApiException) {
        // Parse retry time from message if 429
        if (e.statusCode == 429) {
          return {
            'success': false,
            'message': e.message,
            'errorCode': 'RATE_LIMIT',
          };
        }
        // Return the backend error message directly
        return {
          'success': false,
          'message': e.message,
          'errorCode': e.statusCode,
        };
      }
      // Network or unknown errors
      return {
        'success': false,
        'message': 'Erreur de connexion. Vérifiez votre internet',
        'errorCode': 'NETWORK_ERROR',
      };
    }
  }

  // Validate OTP (optional pre-validation)
  // Backend: POST /otp/validate
  Future<Map<String, dynamic>> validateOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      debugPrint('[AuthService] Validating OTP for $phoneNumber');

      final response = await _interceptor.post(
        'otp/validate',
        body: {'phoneNumber': phoneNumber, 'otp': otp},
        requiresAuth: false,
      );

      final data = await _handleResponse(response, 'otp/validate');

      return {'success': true, 'message': data['message'] ?? 'OTP valide'};
    } catch (e) {
      debugPrint('[AuthService] Validate OTP Error: $e');

      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {'success': false, 'message': 'Code OTP invalide'};
    }
  }

  // ===========================================================================
  // MARK: - Password Reset
  // ===========================================================================

  // Reset user password using OTP
  // Backend: POST /auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      debugPrint('[AuthService] Resetting password for $phoneNumber');

      final response = await _interceptor.post(
        'auth/reset-password',
        body: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      debugPrint(
        '[AuthService] Reset password response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'success': true,
            'message': 'Mot de passe réinitialisé avec succès',
          };
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return {
          'success': true,
          'message': data['message'] ?? 'Mot de passe réinitialisé avec succès',
        };
      } else {
        // Handle error responses
        String errorMessage = 'Code OTP invalide ou expiré';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }

        debugPrint('[AuthService] Reset password failed: $errorMessage');

        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
          endpoint: 'auth/reset-password',
        );
      }
    } catch (e) {
      debugPrint('[AuthService] Reset Password Error: $e');

      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la réinitialisation du mot de passe',
      };
    }
  }

  // ===========================================================================
  // MARK: - Response Handling
  // ===========================================================================

  // Handle HTTP response with optimized JSON parsing
  Future<Map<String, dynamic>> _handleResponse(
    response,
    String endpoint,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      String errorMessage = 'Request failed';

      try {
        final errorJson = jsonDecode(response.body);
        errorMessage =
            errorJson['message'] ?? errorJson['error'] ?? response.body;
      } catch (_) {
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Request failed';
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        endpoint: endpoint,
      );
    }
  }
}

// ===========================================================================
// MARK: - API Exception
// ===========================================================================

// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String endpoint;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.endpoint,
  });

  @override
  String toString() => 'ApiException($statusCode) [$endpoint]: $message';
}
