// Notification Service
//
// Handles notification operations:
// - Get passenger/driver notifications
// - Mark notifications as read
// - Delete notifications
// - Clear all notifications

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class NotificationApiService {
  final ApiInterceptor _interceptor;

  NotificationApiService(this._interceptor);

  // ===========================================================================
  // MARK: - Get Notifications
  // ===========================================================================

  // Get notification settings for current passenger with pagination
  // Backend: GET /notifications/passenger?page=0&size=20
  Future<Map<String, dynamic>> getPassengerNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _interceptor.get(
        'notifications/passenger?page=$page&size=$size',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);

        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          final pageData = apiResponse['data'] as Map<String, dynamic>;

          return {
            'success': true,
            'data': {
              'notifications': pageData['content'] ?? [],
              'pagination': {
                'totalPages': pageData['totalPages'] ?? 0,
                'totalElements': pageData['totalElements'] ?? 0,
                'currentPage': pageData['number'] ?? page,
                'hasNext': !(pageData['last'] ?? true),
              },
            },
          };
        }
      }

      return {
        'success': false,
        'data': {
          'notifications': [],
          'pagination': {
            'totalPages': 0,
            'totalElements': 0,
            'currentPage': 0,
            'hasNext': false,
          },
        },
      };
    } catch (e) {
      logError(
        '[NotificationApiService]',
        'Get passenger notifications failed: $e',
      );
      return {
        'success': false,
        'data': {
          'notifications': [],
          'pagination': {
            'totalPages': 0,
            'totalElements': 0,
            'currentPage': 0,
            'hasNext': false,
          },
        },
      };
    }
  }

  // Get notification settings for current driver with pagination
  // Backend: GET /notifications/driver?page=0&size=20
  Future<Map<String, dynamic>> getDriverNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _interceptor.get(
        'notifications/driver?page=$page&size=$size',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);

        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          final pageData = apiResponse['data'] as Map<String, dynamic>;

          return {
            'success': true,
            'data': {
              'notifications': pageData['content'] ?? [],
              'pagination': {
                'totalPages': pageData['totalPages'] ?? 0,
                'totalElements': pageData['totalElements'] ?? 0,
                'currentPage': pageData['number'] ?? page,
                'hasNext': !(pageData['last'] ?? true),
              },
            },
          };
        }
      }

      return {
        'success': false,
        'data': {
          'notifications': [],
          'pagination': {
            'totalPages': 0,
            'totalElements': 0,
            'currentPage': 0,
            'hasNext': false,
          },
        },
      };
    } catch (e) {
      logError(
        '[NotificationApiService]',
        'Get driver notifications failed: $e',
      );
      return {
        'success': false,
        'data': {
          'notifications': [],
          'pagination': {
            'totalPages': 0,
            'totalElements': 0,
            'currentPage': 0,
            'hasNext': false,
          },
        },
      };
    }
  }
  // ===========================================================================
  // MARK: - Mark as Read
  // ===========================================================================

  // Mark a specific notification as read
  // Backend: PUT /notifications/read/{id}
  // Returns the updated notification
  Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
  }) async {
    try {
      final response = await _interceptor.request(
        method: 'PUT',
        endpoint: 'notifications/read/$notificationId',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final apiResponse = jsonDecode(response.body);

        return {
          'success': apiResponse['success'] ?? true,
          'notification': apiResponse['data'],
          'message': apiResponse['message'] ?? 'Notification marquée comme lue',
        };
      } else {
        String errorMessage = 'Erreur lors du marquage de la notification';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        throw _ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
          endpoint: 'notifications/read/$notificationId',
        );
      }
    } catch (e) {
      logError(
        '[NotificationService]',
        'Failed to mark notification as read - $e',
      );

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors du marquage de la notification',
      };
    }
  }

  // Mark all notifications as read for current user
  // Backend: PUT /notifications/read-all
  // Returns success status
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await _interceptor.request(
        method: 'PUT',
        endpoint: 'notifications/read-all',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        logSuccess(
          '[NotificationService]',
          'All notifications marked as read successfully',
        );

        return {
          'success': true,
          'message': 'Toutes les notifications marquées comme lues',
        };
      } else {
        // Handle error responses
        String errorMessage = 'Erreur lors du marquage des notifications';

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }

        logError(
          '[NotificationService]',
          'Error response: ${response.statusCode} - $errorMessage',
        );

        throw _ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
          endpoint: 'notifications/read-all',
        );
      }
    } catch (e, stackTrace) {
      logError(
        '[NotificationService]',
        'Failed to mark all notifications as read - $e',
      );
      logError('[NotificationService]', 'Stack trace: $stackTrace');

      if (e is _ApiException) {
        return {'success': false, 'message': e.message};
      }

      return {
        'success': false,
        'message': 'Erreur lors du marquage des notifications',
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
