// Support Service
//
// Handles support and engagement operations:
// - Send reports/reclamations
// - Send invitations (referral program)

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class SupportService {
  final ApiInterceptor _interceptor;

  SupportService(this._interceptor);

  // ===========================================================================
  // MARK: - Reports/Reclamations
  // ===========================================================================

  // Send a report/reclamation
  // Backend: POST /reclamations
  // Request body: { "content": string, "category": string, "rideId": string }
  Future<Map<String, dynamic>> sendReport({
    required String content,
    required String rideId,
    required String categorie,
  }) async {
    try {
      final response = await _interceptor.post(
        'reclamations',
        body: {'content': content, 'category': categorie, 'rideId': rideId},
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'RÃ©clamation envoyÃ©e avec succÃ¨s',
        };
      } else {
        // Handle error responses
        String errorMessage = 'Erreur lors de l\'envoi de la rÃ©clamation.';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }

        logError(
          '[SupportService]',
          'Error response: ${response.statusCode} - $errorMessage',
        );

        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      logError('[SupportService]', 'Failed to send report - $e');
      logError('[SupportService]', 'Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi de la rÃ©clamation.',
      };
    }
  }
}
