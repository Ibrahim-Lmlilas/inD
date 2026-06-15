// Wallet Service
//
// Handles wallet operations:
// - Driver wallet data
// - Passenger wallet data
// - Transaction history

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class WalletService {
  final ApiInterceptor _interceptor;

  WalletService(this._interceptor);

  // ===========================================================================
  // MARK: - Wallet Operations
  // ===========================================================================

  // Get driver wallet data
  // Backend: GET /wallet/driver
  //
  // Returns wallet balance and transaction history for authenticated driver
  // Requires authentication as a driver (passenger with driver profile)
  Future<Map<String, dynamic>> getDriverWalletData() async {
    try {
      final response = await _interceptor.get(
        'wallet/driver',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }

        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          return {'success': true, 'wallet': data};
        } catch (parseError) {
          logError('[WalletService]', 'JSON parse error: $parseError');
          return {'success': false, 'message': 'Erreur de format de données'};
        }
      } else {
        // Handle error responses
        String errorMessage = 'Erreur lors du chargement du portefeuille';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }

        logError(
          '[WalletService]',
          'Error response: ${response.statusCode} - $errorMessage',
        );

        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      logError('[WalletService]', 'Failed to get driver wallet - $e');
      logError('[WalletService]', 'Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur lors du chargement du portefeuille',
      };
    }
  }
}
