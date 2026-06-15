// Profile Service
//
// Handles passenger and driver profile operations:
// - Passenger registration & profile management
// - Driver registration & profile management
// - Profile updates (password, phone, interface type, picture)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/auth/data/services/auth_service.dart';

class ProfileService {
  final ApiInterceptor _interceptor;

  ProfileService(this._interceptor);

  // ===========================================================================
  // MARK: - Passenger Registration & Profile
  // ===========================================================================

  // Get current passenger profile
  // Backend: GET /user/profile/passenger
  Future<Map<String, dynamic>> getPassengerProfile() async {
    try {
      debugPrint('[ProfileService] Fetching passenger profile');

      final response = await _interceptor.get(
        'user/profile/passenger', // Updated endpoint
        requiresAuth: true,
      );

      final apiResponse = await _handleResponse(
        response,
        'user/profile/passenger',
      );

      if (apiResponse['success'] == true) {
        return {'success': true, 'user': apiResponse['data']};
      } else {
        return {
          'success': false,
          'message': apiResponse['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      debugPrint('[ProfileService] Get Passenger Profile Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la récupération du profil',
      };
    }
  }

  Future<Map<String, dynamic>> updateLanguage({
    required String language,
  }) async {
    try {
      final lang = language.toUpperCase();
      final response = await _interceptor.request(
        method: 'PATCH',
        endpoint: 'user/update/language?language=$lang',
        requiresAuth: true,
      );

      final data = await _handleResponse(response, 'user/update/language');

      return {
        'success': true,
        'message': data['message'] ?? 'Langue mise à jour',
      };
    } catch (e) {
      if (e is ApiException) {
        return {'success': false, 'message': e.message};
      }
      return {'success': false, 'message': 'Erreur lors de la mise à jour'};
    }
  }

  // ===========================================================================
  // MARK: - Profile Updates
  // ===========================================================================

  // Update user password
  // Backend: PUT /user/update/password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      debugPrint('[ProfileService] Updating password');

      final response = await _interceptor.request(
        method: 'PUT',
        endpoint: 'user/update/password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        requiresAuth: true,
      );

      final data = await _handleResponse(response, 'user/update/password');

      return {
        'success': true,
        'message': data['message'] ?? 'Mot de passe modifié avec succès',
      };
    } catch (e) {
      debugPrint('[ProfileService] Update Password Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la modification du mot de passe',
      };
    }
  }

  // Request phone number update (Step 1)
  // Backend: POST /user/update/phone
  // Sends OTP to new phone number
  Future<Map<String, dynamic>> updatePhoneRequest({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      debugPrint('[ProfileService] Requesting phone update to $phoneNumber');

      final response = await _interceptor.request(
        method: 'POST',
        endpoint: 'user/update/phone', // Updated endpoint
        body: {'phoneNumber': phoneNumber, 'password': password},
        requiresAuth: true,
      );

      final apiResponse = await _handleResponse(response, 'user/update/phone');

      return {
        'success': apiResponse['success'] ?? true,
        'message':
            apiResponse['data']?['message'] ??
            apiResponse['message'] ??
            'Code OTP envoyé',
      };
    } catch (e) {
      debugPrint('[ProfileService] Update Phone Request Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la demande de modification',
      };
    }
  }

  // Confirm phone number update (Step 2)
  // Backend: POST /user/update/phone/confirm
  // Verifies OTP and updates phone number
  Future<Map<String, dynamic>> confirmUpdatePhone({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      debugPrint('[ProfileService] Confirming phone update with OTP');

      final response = await _interceptor.request(
        method: 'POST',
        endpoint: 'user/update/phone/confirm', // Updated endpoint
        body: {'phoneNumber': phoneNumber, 'otp': otp},
        requiresAuth: true,
      );

      final apiResponse = await _handleResponse(
        response,
        'user/update/phone/confirm',
      );

      return {
        'success': apiResponse['success'] ?? true,
        'message':
            apiResponse['data']?['message'] ??
            apiResponse['message'] ??
            'Numéro modifié avec succès',
      };
    } catch (e) {
      debugPrint('[ProfileService] Confirm Phone Update Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {'success': false, 'message': 'Code OTP invalide ou expiré'};
    }
  }

  // Update passenger interface type (REGULAR or LADIES)
  // Backend: PUT /user/update/interface-type?interfaceType={interfaceType}
  Future<Map<String, dynamic>> updateInterfaceType({
    required String interfaceType,
  }) async {
    try {
      debugPrint('[ProfileService] Updating interface type to $interfaceType');

      if (interfaceType != 'REGULAR' && interfaceType != 'LADIES') {
        return {
          'success': false,
          'message': 'Type d\'interface invalide. Utilisez REGULAR ou LADIES.',
        };
      }

      final endpoint =
          'user/update/interface-type?interfaceType=$interfaceType';

      final response = await _interceptor.request(
        method: 'PATCH',
        endpoint: endpoint,
        requiresAuth: true,
      );

      final apiResponse = await _handleResponse(response, endpoint);

      return {
        'success': apiResponse['success'] ?? true,
        'message':
            apiResponse['message'] ??
            'Type d\'interface mis à jour avec succès',
        'interfaceType': interfaceType,
      };
    } catch (e) {
      debugPrint('[ProfileService] Update Interface Type Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du type d\'interface',
      };
    }
  }

  // Update passenger profile picture (selfie)
  // Backend: PUT /user/update/picture
  Future<Map<String, dynamic>> updateProfilePicture({
    required String imagePath,
  }) async {
    try {
      debugPrint('[ProfileService] Updating profile picture');

      final response = await _interceptor.multipartRequest(
        method: 'PUT',
        endpoint: 'user/update/picture',
        fields: {},
        files: {imagePath: 'file'},
        requiresAuth: true,
      );

      logCritical(
        'Profile Picture',
        'Update Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);

        return {
          'success': true,
          'message': 'Photo de profil mise à jour avec succès',
          'profilePictureUrl': apiResponse['data']?['profilePictureUrl'],
        };
      } else {
        String errorMessage = 'Échec de la mise à jour de la photo';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        throw _ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
          endpoint: 'user/update/picture',
        );
      }
    } catch (e) {
      debugPrint('[ProfileService] Update Profile Picture Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour de la photo: ${e.toString()}',
      };
    }
  }

  // Delete User profile
  // Backend: DELETE /user/delete
  Future<Map<String, dynamic>> deleteUserAccount({
    required String password,
    required String reason,
    required bool confirmed,
  }) async {
    try {
      final response = await _interceptor.request(
        method: 'POST',
        endpoint: 'user/delete',
        body: {'password': password, 'reason': reason, 'confirmed': confirmed},
        requiresAuth: true,
      );

      final data = await _handleResponse(response, 'user/delete');

      return {
        'success': true,
        'message': data['message'] ?? 'Account deleted succesfully',
      };
    } catch (e) {
      debugPrint('[ProfileService] Account deletion Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la suppression du compte',
      };
    }
  }

  // ===========================================================================
  // MARK: - Driver Registration & Profile
  // ===========================================================================

  // Get current driver profile (if exists)
  // Backend: GET /user/profile/driver
  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      debugPrint('[ProfileService] Fetching driver profile');

      final response = await _interceptor.get(
        'user/profile/driver',
        requiresAuth: true,
      );

      final apiResponse = await _handleResponse(
        response,
        'user/profile/driver',
      );

      if (apiResponse['success'] == true) {
        return {'success': true, 'driver': apiResponse['data']};
      } else {
        return {
          'success': false,
          'message': apiResponse['message'] ?? 'Failed to load driver profile',
        };
      }
    } catch (e) {
      debugPrint('[ProfileService] Get Driver Profile Error: $e');

      if (e is _ApiException) {
        // 404 means no driver profile exists
        if (e.statusCode == 404) {
          return {
            'success': false,
            'driver': null,
            'message': 'No driver profile',
          };
        }

        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la récupération du profil conducteur',
      };
    }
  }

  // Create driver account with multipart/form-data
  // Backend: POST /driver/create
  Future<Map<String, dynamic>> createDriverAccount({
    required String cinRecto,
    required String cinVerso,
    required String cinCode,
    required String selfie,
    required String expirationDate, // ISO format: YYYY-MM-DD
    required String vehicleType,
    required String vehiclePicture,
    required String vehicleRegistrationRecto,
    required String vehicleRegistrationVerso,
    required String vehicleRegistrationCode,
    required String vehicleBrand,
    required String vehicleModel,
    required String vehicleColor,
    required String productionYear,
  }) async {
    try {
      debugPrint('[ProfileService] Creating driver account');

      final fields = {
        'cinCode': cinCode,
        'expirationDate': expirationDate,
        'vehicleType': vehicleType,
        'vehicleRegistrationCode': vehicleRegistrationCode,
        'vehicleBrand': vehicleBrand,
        'vehicleModel': vehicleModel,
        'vehicleColor': vehicleColor,
        'productionYear': productionYear,
      };

      final files = {
        cinRecto: 'cinRecto',
        cinVerso: 'cinVerso',
        selfie: 'selfie',
        vehiclePicture: 'vehiclePicture',
        vehicleRegistrationRecto: 'vehicleRegistrationRecto',
        vehicleRegistrationVerso: 'vehicleRegistrationVerso',
      };

      final response = await _interceptor.multipartRequest(
        method: 'POST',
        endpoint: 'auth/driver/create',
        fields: fields,
        files: files,
        requiresAuth: true,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('[ProfileService] Driver account created successfully');

        return {
          'success': true,
          'message': data['message'] ?? 'Demande soumise avec succès',
          'driverId': data['id'],
          'status': data['status'], // PENDING, VALIDATED, REJECTED
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint(
          '[ProfileService] Failed to create driver account: ${errorData['message']}',
        );

        throw _ApiException(
          statusCode: response.statusCode,
          message:
              errorData['message'] ??
              'Échec de la création du compte conducteur',
          endpoint: 'driver/create',
        );
      }
    } catch (e) {
      debugPrint('[ProfileService] Create Driver Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message':
            'Erreur lors de la création du compte conducteur: ${e.toString()}',
      };
    }
  }

  // ===========================================================================
  // MARK: - Response Handling
  // ===========================================================================

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

      throw _ApiException(
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

class _ApiException implements Exception {
  final int statusCode;
  final String message;
  final String endpoint;

  _ApiException({
    required this.statusCode,
    required this.message,
    required this.endpoint,
  });

  @override
  String toString() => '_ApiException($statusCode) [$endpoint]: $message';
}
