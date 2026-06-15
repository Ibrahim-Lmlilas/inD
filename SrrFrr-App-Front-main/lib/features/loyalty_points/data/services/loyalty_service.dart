// Loyalty Service - Updated with Pagination
//
// Backend endpoints:
// - GET /loyalty?page=0&size=20 - Get loyalty points with paginated transactions
// - GET /loyalty/rewards - Get available rewards

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class LoyaltyService {
  final ApiInterceptor _interceptor;

  LoyaltyService(this._interceptor);

  // ===========================================================================
  // MARK: - Loyalty Points with Pagination
  // ===========================================================================

  // Get user's loyalty points and paginated transaction history
  // Backend: GET /loyalty?page={page}&size={size}
  Future<Map<String, dynamic>> getLoyaltyPoints({
    int page = 0,
    int size = 20,
  }) async {
    try {
      logInfo(
        '[LoyaltyService]',
        'Fetching loyalty points (page: $page, size: $size)',
      );

      final endpoint = 'loyalty?page=$page&size=$size';
      final response = await _interceptor.get(endpoint, requiresAuth: true);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'success': true,
            'points': 0,
            'transactions': [],
            'totalElements': 0,
            'totalPages': 0,
            'currentPage': 0,
            'hasNext': false,
            'hasPrevious': false,
          };
        }

        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          // Backend returns paginated response
          return {
            'success': true,
            'points': data['points'] ?? 0,
            'transactions': data['transactions'] ?? [],
            'totalElements': data['totalElements'] ?? 0,
            'totalPages': data['totalPages'] ?? 0,
            'currentPage': data['currentPage'] ?? 0,
            'pageSize': data['pageSize'] ?? size,
            'hasNext': data['hasNext'] ?? false,
            'hasPrevious': data['hasPrevious'] ?? false,
          };
        } else {
          return {
            'success': false,
            'message': 'Format de réponse inattendu',
            'points': 0,
            'transactions': [],
          };
        }
      } else {
        throw _ApiException(
          statusCode: response.statusCode,
          message: 'Erreur lors de la récupération des points',
          endpoint: endpoint,
        );
      }
    } catch (e) {
      logError('[LoyaltyService]', 'Get Loyalty Points Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la récupération des points',
      };
    }
  }

  // ===========================================================================
  // MARK: - Loyalty Rewards
  // ===========================================================================

  // Get available loyalty rewards (ways to earn points)
  // Backend: GET /loyalty/rewards
  Future<Map<String, dynamic>> getLoyaltyRewards() async {
    try {
      logInfo('[LoyaltyService]', 'Fetching loyalty rewards');

      final response = await _interceptor.get(
        'loyalty/rewards',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true, 'rewards': []};
        }

        final data = jsonDecode(response.body);

        if (data is List) {
          return {'success': true, 'rewards': data};
        } else {
          return {
            'success': false,
            'message': 'Format de réponse inattendu',
            'rewards': [],
          };
        }
      } else {
        throw _ApiException(
          statusCode: response.statusCode,
          message: 'Erreur lors de la récupération des récompenses',
          endpoint: 'loyalty/rewards',
        );
      }
    } catch (e) {
      logError('[LoyaltyService]', 'Get Loyalty Rewards Error: $e');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors de la récupération des récompenses',
      };
    }
  }

    // ===========================================================================
  // MARK: - Invitations/Referrals
  // ===========================================================================

  // Send an invitation to a phone number
  // Backend: POST /invite/{phoneNumber}
  // Sends an invitation to the specified phone number
  // Returns success status and message
  // Requires authentication
  Future<Map<String, dynamic>> sendInvitation({
    required String phoneNumber,
  }) async {
    try {
      final response = await _interceptor.post(
        'invite/$phoneNumber',
        body: {},
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Invitation envoyÃ©e avec succÃ¨s'};
      } else {
        String errorMessage = 'Erreur lors de l\'envoi de l\'invitation';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }

        logError(
          '[SupportService]',
          'Error: ${response.statusCode} - $errorMessage',
        );

        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      logError('[SupportService]', 'Failed to send invitation - $e');
      logError('[SupportService]', 'Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi de l\'invitation',
      };
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
