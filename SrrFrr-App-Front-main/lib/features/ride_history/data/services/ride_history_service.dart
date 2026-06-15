/// Ride History Service
///
/// Handles ride history operations for both passengers and drivers
/// Includes filtering, pagination, and ride history data retrieval

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class RideHistoryService {
  final ApiInterceptor _interceptor;

  RideHistoryService(this._interceptor);

  void _addParam(String paramName, dynamic value, List<String> queryParts) {
    if (value != null) {
      if (value is String && value.isNotEmpty) {
        queryParts.add('$paramName=${Uri.encodeComponent(value)}');
      } else if (value is DateTime) {
        final formatted = value.toUtc().toIso8601String();
        queryParts.add('$paramName=${Uri.encodeComponent(formatted)}');
      } else if (value is num) {
        queryParts.add('$paramName=$value');
      }
    }
  }

  // ===========================================================================
  // MARK: - Passenger Ride History
  // ===========================================================================

  /// Get passenger ride history with pagination and filters
  /// Backend: GET /rides/history/passenger?page=0&size=20
  Future<Map<String, dynamic>> getPassengerRideHistory({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentType,
    String? vehicleType,
    String? driverName,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParts = <String>['page=$page', 'size=$size'];

      // Add filter parameters (skip 'All' values)
      if (status != null && status.isNotEmpty && status != 'All') {
        _addParam('status', status, queryParts);
      }
      if (paymentType != null &&
          paymentType.isNotEmpty &&
          paymentType != 'All') {
        _addParam('paymentType', paymentType, queryParts);
      }
      if (vehicleType != null &&
          vehicleType.isNotEmpty &&
          vehicleType != 'All') {
        _addParam('vehicleType', vehicleType, queryParts);
      }
      if (driverName != null && driverName.isNotEmpty) {
        _addParam('driverName', driverName, queryParts);
      }
      _addParam('startDate', startDate, queryParts);
      _addParam('endDate', endDate, queryParts);
      _addParam('minPrice', minPrice, queryParts);
      _addParam('maxPrice', maxPrice, queryParts);

      // Build final query string
      final queryString = queryParts.join('&');

      final response = await _interceptor.get(
        'rides/history/passenger?$queryString',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'success': true,
            'rides': [],
            'totalPages': 0,
            'totalElements': 0,
          };
        }

        try {
          // Backend returns ApiResponse<Page<RideDTO>>
          final apiResponse = jsonDecode(response.body);

          if (apiResponse['success'] == true && apiResponse['data'] != null) {
            final pageData = apiResponse['data'];

            return {
              'success': true,
              'rides': pageData['content'] ?? [],
              'totalPages': pageData['totalPages'] ?? 0,
              'totalElements': pageData['totalElements'] ?? 0,
              'currentPage': pageData['number'] ?? page,
              'pageSize': pageData['size'] ?? size,
              'last': pageData['last'] ?? false,
              'first': pageData['first'] ?? false,
            };
          } else {
            return {
              'success': false,
              'message':
                  apiResponse['message'] ?? 'Failed to load ride history',
              'rides': [],
            };
          }
        } catch (parseError) {
          logError('[RideHistoryService]', 'JSON parse error: $parseError');
          return {
            'success': false,
            'message': 'Erreur de format de données',
            'rides': [],
          };
        }
      } else {
        logError(
          '[RideHistoryService]',
          'Error response: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Erreur lors du chargement de l\'historique',
          'rides': [],
        };
      }
    } catch (e, stackTrace) {
      logError(
        '[RideHistoryService]',
        'Failed to get passenger ride history - $e',
      );
      logError('[RideHistoryService]', 'Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur lors du chargement de l\'historique',
        'rides': [],
      };
    }
  }

  // ===========================================================================
  // MARK: - Driver Ride History
  // ===========================================================================

  /// Get driver ride history with pagination and filters
  /// Backend: GET /rides/history/driver?page=0&size=20
  Future<Map<String, dynamic>> getDriverRideHistory({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentType,
    String? vehicleType,
    String? driverName,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParts = <String>['page=$page', 'size=$size'];

      // Add filter parameters (skip 'All' values)
      if (status != null && status.isNotEmpty && status != 'All') {
        _addParam('status', status, queryParts);
      }
      if (paymentType != null &&
          paymentType.isNotEmpty &&
          paymentType != 'All') {
        _addParam('paymentType', paymentType, queryParts);
      }
      if (vehicleType != null &&
          vehicleType.isNotEmpty &&
          vehicleType != 'All') {
        _addParam('vehicleType', vehicleType, queryParts);
      }
      if (driverName != null && driverName.isNotEmpty) {
        _addParam('driverName', driverName, queryParts);
      }
      _addParam('startDate', startDate, queryParts);
      _addParam('endDate', endDate, queryParts);
      _addParam('minPrice', minPrice, queryParts);
      _addParam('maxPrice', maxPrice, queryParts);

      // Build final query string
      final queryString = queryParts.join('&');

      final response = await _interceptor.get(
        'rides/history/driver?$queryString',
        requiresAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'success': true,
            'rides': [],
            'totalPages': 0,
            'totalElements': 0,
          };
        }

        try {
          final apiResponse = jsonDecode(response.body);

          if (apiResponse['success'] == true && apiResponse['data'] != null) {
            final pageData = apiResponse['data'];

            return {
              'success': true,
              'rides': pageData['content'] ?? [],
              'totalPages': pageData['totalPages'] ?? 0,
              'totalElements': pageData['totalElements'] ?? 0,
              'currentPage': pageData['number'] ?? page,
              'pageSize': pageData['size'] ?? size,
              'last': pageData['last'] ?? false,
              'first': pageData['first'] ?? false,
            };
          } else {
            return {
              'success': false,
              'message':
                  apiResponse['message'] ?? 'Failed to load ride history',
              'rides': [],
            };
          }
        } catch (parseError) {
          logError('[RideHistoryService]', 'JSON parse error: $parseError');
          return {
            'success': false,
            'message': 'Erreur de format de données',
            'rides': [],
          };
        }
      } else {
        logError(
          '[RideHistoryService]',
          'Error response: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Erreur lors du chargement de l\'historique',
          'rides': [],
        };
      }
    } catch (e, stackTrace) {
      logError(
        '[RideHistoryService]',
        'Failed to get driver ride history - $e',
      );
      logError('[RideHistoryService]', 'Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur lors du chargement de l\'historique',
        'rides': [],
      };
    }
  }
}
