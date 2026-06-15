// Rating Service
//
// Handles rating and review operations:
// - Get rating values/options
// - Submit ratings
// - Get ride rating status
// - Get user ratings and averages

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';

class RatingService {
  final ApiInterceptor _interceptor;

  RatingService(this._interceptor);

  // ===========================================================================
  // MARK: - Rating Values
  // ===========================================================================

  // Get rating values grouped by level (1-5 stars)
  //
  // Backend: GET /ratings/rating-values
  // Optional query param: level (1-5)
  //
  // Returns rating options for a specific star level or all levels
  Future<Map<String, dynamic>> getRatingValues({int? level}) async {
    try {
      final endpoint = level != null
          ? 'ratings/rating-values?level=$level'
          : 'ratings/rating-values';

      debugPrint(
        '[RatingService] Getting rating values${level != null ? ' for level $level' : ''}',
      );

      final response = await _interceptor.get(endpoint, requiresAuth: true);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          debugPrint('[RatingService] Empty response body');
          return {'success': true, 'values': []};
        }

        try {
          // Parse response - backend returns List directly
          final data = jsonDecode(response.body);

          debugPrint('[RatingService] Decoded data type: ${data.runtimeType}');

          if (data is List) {
            debugPrint(
              '[RatingService] Successfully parsed ${data.length} rating value groups',
            );

            // Empty list is valid - means no rating values in database
            if (data.isEmpty) {
              debugPrint('[RatingService] No rating values found in database');
              return {'success': true, 'values': []};
            }

            if (level != null) {
              // Find the specific level in the response
              final levelData = data.firstWhere(
                (v) => v['ratingLevel'] == level,
                orElse: () => {'ratingLevel': level, 'options': []},
              );

              return {'success': true, 'values': levelData['options'] ?? []};
            } else {
              // Return all levels grouped
              return {'success': true, 'values': data};
            }
          } else if (data is Map) {
            debugPrint('[RatingService] Unexpected Map response');
            // Fallback for unexpected format
            if (data['values'] is List) {
              return {'success': true, 'values': data['values']};
            }
            return {'success': true, 'values': []};
          } else {
            debugPrint(
              '[RatingService] Unexpected data type: ${data.runtimeType}',
            );
            return {'success': true, 'values': []};
          }
        } catch (parseError) {
          debugPrint('[RatingService] JSON parse error: $parseError');
          return {'success': false, 'message': 'Erreur de format de données'};
        }
      } else {
        debugPrint('[RatingService] Error response: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Erreur lors du chargement des options de notation',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('[RatingService] Failed to get rating values - $e');
      debugPrint('[RatingService] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur lors du chargement des options de notation',
      };
    }
  }

  // ===========================================================================
  // MARK: - Submit Rating
  // ===========================================================================

  // Submit a rating for a ride
  //
  // Backend: POST /ratings/{rideId}
  // Request body: { "id": "rating_value_uuid" }
  //
  // Backend automatically:
  // - Determines rating type based on authenticated user's role in ride
  // - Validates ride status (ACCEPTED or COMPLETED)
  // - Prevents duplicate ratings
  // - Updates receiver's average rating
  Future<Map<String, dynamic>> submitRating({
    required String rideId,
    required String ratingValueId,
  }) async {
    try {
      debugPrint('[RatingService] Submitting rating for ride $rideId');
      debugPrint('[RatingService] Rating Value ID: $ratingValueId');

      final response = await _interceptor.post(
        'ratings/$rideId',
        body: {
          'id': ratingValueId, // Backend expects 'id' field
        },
        requiresAuth: true, // Requires authentication
      );

      final data = await _handleResponse(response, 'ratings/$rideId');

      return {
        'success': true,
        'rating': data, // RatingResponse object
        'message': 'Notation soumise avec succès',
      };
    } catch (e) {
      debugPrint('[RatingService] Failed to submit rating - $e');

      // Parse specific error messages
      String errorMessage = 'Erreur lors de la soumission de la notation';

      if (e.toString().contains('already rated')) {
        errorMessage = 'Vous avez déjà noté ce trajet';
      } else if (e.toString().contains('not part of this ride')) {
        errorMessage = 'Vous ne faites pas partie de ce trajet';
      } else if (e.toString().contains('only rate rides that are')) {
        errorMessage = 'Vous ne pouvez noter que les trajets terminés';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  // ===========================================================================
  // MARK: - Rating Status & Queries
  // ===========================================================================

  // Get rating status for a ride
  //
  // Backend: GET /ratings/ride/{rideId}/status
  //
  // Returns whether current user can rate the ride and existing ratings
  Future<Map<String, dynamic>> getRideRatingStatus(String rideId) async {
    try {
      debugPrint('[RatingService] Getting rating status for ride $rideId');

      final response = await _interceptor.get(
        'ratings/ride/$rideId/status',
        requiresAuth: true,
      );

      final data = await _handleResponse(
        response,
        'ratings/ride/$rideId/status',
      );

      return {
        'success': true,
        'status': data, // RideRatingStatusResponse
      };
    } catch (e) {
      debugPrint('[RatingService] Failed to get rating status - $e');
      return {
        'success': false,
        'message': 'Erreur lors du chargement du statut de notation',
      };
    }
  }

  // Get average rating for a user
  //
  // Backend: GET /ratings/user/{userId}/average
  //
  // Returns user's average rating and total number of ratings received
  Future<Map<String, dynamic>> getUserAverageRating(String userId) async {
    try {
      debugPrint('[RatingService] Getting average rating for user $userId');

      final response = await _interceptor.get(
        'ratings/user/$userId/average',
        requiresAuth: false, // Public endpoint
      );

      final data = await _handleResponse(
        response,
        'ratings/user/$userId/average',
      );

      return {
        'success': true,
        'averageRating': data['averageRating'],
        'totalRatings': data['totalRatings'],
      };
    } catch (e) {
      debugPrint('[RatingService] Failed to get user rating - $e');
      return {
        'success': false,
        'message': 'Erreur lors du chargement de la note moyenne',
      };
    }
  }

  // Get paginated ratings received by a user
  //
  // Backend: GET /ratings/user/{userId}?page=0&size=20
  //
  // Returns Page<RatingResponse> with ratings received by user
  Future<Map<String, dynamic>> getUserRatings(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      debugPrint(
        '[RatingService] Getting ratings for user $userId (page: $page, size: $size)',
      );

      final response = await _interceptor.get(
        'ratings/user/$userId?page=$page&size=$size',
        requiresAuth: false, // Public endpoint
      );

      final data = await _handleResponse(response, 'ratings/user/$userId');

      return {
        'success': true,
        'ratings': data['content'] ?? [],
        'totalElements': data['totalElements'] ?? 0,
        'totalPages': data['totalPages'] ?? 0,
        'currentPage': data['number'] ?? page,
      };
    } catch (e) {
      debugPrint('[RatingService] Failed to get user ratings - $e');
      return {
        'success': false,
        'message': 'Erreur lors du chargement des notations',
        'ratings': [],
      };
    }
  }

  // Get paginated ratings given by current authenticated user
  //
  // Backend: GET /ratings/my-ratings?page=0&size=20
  //
  // Returns Page<RatingResponse> with ratings given by current user
  Future<Map<String, dynamic>> getMyRatings({
    int page = 0,
    int size = 20,
  }) async {
    try {
      debugPrint(
        '[RatingService] Getting my ratings (page: $page, size: $size)',
      );

      final response = await _interceptor.get(
        'ratings/my-ratings?page=$page&size=$size',
        requiresAuth: true,
      );

      final data = await _handleResponse(response, 'ratings/my-ratings');

      return {
        'success': true,
        'ratings': data['content'] ?? [],
        'totalElements': data['totalElements'] ?? 0,
        'totalPages': data['totalPages'] ?? 0,
        'currentPage': data['number'] ?? page,
      };
    } catch (e) {
      debugPrint('[RatingService] Failed to get my ratings - $e');
      return {
        'success': false,
        'message': 'Erreur lors du chargement de vos notations',
        'ratings': [],
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
