/// Chat Service
///
/// Handles chat-related operations:
/// - Message retrieval with pagination
/// - Ride-specific chat management

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class ChatService {
  final ApiInterceptor _interceptor;

  ChatService(this._interceptor);

  // ===========================================================================
  // MARK: - Chat Messages
  // ===========================================================================

  /// Get messages for a specific ride with pagination
  /// Backend: GET /chat/messages/{rideId}?page=0&size=20
  Future<Map<String, dynamic>> getRideMessages(
    String rideId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _interceptor.get(
        'chat/messages/$rideId?page=$page&size=$size',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true, 'messages': [], 'totalPages': 0};
        }

        try {
          final apiResponse = jsonDecode(response.body);

          if (apiResponse['success'] == true && apiResponse['data'] != null) {
            final pageData = apiResponse['data'];
            logDebug('Chat Service', 'Display Response Data: $apiResponse');

            return {
              'success': true,
              'messages': pageData['messages'] ?? [],
              'totalPages': pageData['totalPages'] ?? 0,
              'totalElements': pageData['totalElements'] ?? 0,
              'currentPage': pageData['currentPage'] ?? page,
            };
          } else {
            return {
              'success': false,
              'message': apiResponse['message'] ?? 'Failed to load messages',
              'messages': [],
            };
          }
        } catch (parseError) {
          logError('[ChatService]', 'JSON parse error: $parseError');
          return {
            'success': false,
            'message': 'Erreur de format de données',
            'messages': [],
          };
        }
      } else {
        logError('[ChatService]', 'Error response: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Erreur lors du chargement des messages',
          'messages': [],
        };
      }
    } catch (e, stackTrace) {
      logError('[ChatService]', 'Failed to get ride messages - $e');
      logError('[ChatService]', 'Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur lors du chargement des messages',
        'messages': [],
      };
    }
  }

  // ===========================================================================
  // MARK: - Chat Session Management (Future Extensions)
  // ===========================================================================

  /// Initialize chat session for a ride
  /// Can be extended for future WebSocket integration
  Future<Map<String, dynamic>> initializeChatSession(String rideId) async {
    // Placeholder for future implementation
    // Would connect to WebSocket, get channel ID, etc.
    return {'success': true, 'rideId': rideId, 'sessionReady': true};
  }

  /// Close chat session
  /// Can be extended for future WebSocket integration
  Future<void> closeChatSession(String rideId) async {
    // Placeholder for future implementation
    // Would disconnect WebSocket, cleanup resources
    logDebug('[ChatService]', 'Closing chat session for ride: $rideId');
  }
}