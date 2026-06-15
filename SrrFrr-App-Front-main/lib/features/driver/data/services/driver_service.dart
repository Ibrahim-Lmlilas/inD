
import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';

class DriverService {
  final ApiInterceptor _interceptor;

  DriverService(this._interceptor);

  // ===========================================================================
  // MARK: - Driver Related Services
  // ===========================================================================

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

        return {
          'success': true,
          'message': data['message'] ?? 'Demande soumise avec succès',
          'driverId': data['id'],
          'status': data['status'], // PENDING, VALIDATED, REJECTED
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;

        throw _DriverServiceException(
          message:
              errorData['message'] ??
              'Échec de la création du compte conducteur',
        );
      }
    } catch (e) {

      return {
        'success': false,
        'message': 'Erreur lors de la création du compte conducteur',
      };
    }
  }

}

class _DriverServiceException implements Exception {
  final String message;

  _DriverServiceException({required this.message});

  @override
  String toString() => 'DriverServiceException: $message';
}