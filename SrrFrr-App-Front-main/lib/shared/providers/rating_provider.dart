// Rating Provider - FIXED VERSION with Better Caching
//
// Manages rating state including:
// - Loading rating values from backend
// - Submitting ratings
// - Checking rating status for rides
// - Caching rating data

library;

import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/rating_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/shared/models/rating.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class RatingProvider extends DisposableProvider {
  final RatingService _apiService = RatingService(ApiInterceptor());
  final UserProvider _userProvider;

  // State
  List<RatingValueOption> _ratingOptions = [];
  final Map<int, List<RatingValueOption>> _optionsByLevel = {};
  final Map<String, RideRatingStatus> _rideRatingStatuses = {};

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _allLevelsLoaded = false;
  String? _errorMessage;

  RatingProvider(this._userProvider);

  // Getters
  List<RatingValueOption> get ratingOptions => _ratingOptions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Get rating options for a specific level
  List<RatingValueOption> getOptionsForLevel(int level) {
    logDebug('RatingProvider', 'Getting options for level $level');
    final options = _optionsByLevel[level] ?? [];
    logDebug(
      'RatingProvider',
      'Found ${options.length} options for level $level',
    );
    return options;
  }

  // Get rating status for a ride
  RideRatingStatus? getRideRatingStatus(String rideId) {
    return _rideRatingStatuses[rideId];
  }

  // Check if user can rate a ride
  bool canRateRide(String rideId, {required bool asPassenger}) {
    final status = _rideRatingStatuses[rideId];
    if (status == null) return false;

    return asPassenger ? status.canRateAsPassenger : status.canRateAsDriver;
  }

  // =========================================================================
  // Load Rating Values
  // =========================================================================

  // Load all rating values or for a specific level
  Future<void> loadRatingValues({int? level}) async {
    if (isDisposed) return;

    // If all levels are already loaded and we're requesting a specific level
    // just use the cache instead of making a new API call
    if (level != null && _allLevelsLoaded) {
      // logInfo('RatingProvider', 'Using cached options for level $level');
      _ratingOptions = _optionsByLevel[level] ?? [];

      if (_ratingOptions.isEmpty) {
        // logWarning('RatingProvider', 'No cached options for level $level');
      } else {
        logSuccess(
          'RatingProvider',
          'Loaded ${_ratingOptions.length} cached options for level $level',
        );
      }

      safeNotify();
      return;
    }

    // If requesting a specific level and it's already cached, use it
    if (level != null && _optionsByLevel.containsKey(level)) {
      // logInfo('RatingProvider', 'Using cached options for level $level');
      _ratingOptions = _optionsByLevel[level]!;
      // logSuccess(
      //   'RatingProvider',
      //   'Loaded ${_ratingOptions.length} cached options for level $level',
      // );
      safeNotify();
      return;
    }

    _isLoading = true;
    _clearError();
    safeNotify();

    try {
      // logInfo(
      //   'RatingProvider',
      //   'Loading rating values from API${level != null ? ' for level $level' : ' (all levels)'}',
      // );

      final response = await _apiService.getRatingValues(level: level);

      // logDebug('RatingProvider', 'API Response received');
      // logDebug('RatingProvider', 'Success: ${response['success']}');

      if (response['success'] == true) {
        final values = response['values'];

        // logDebug('RatingProvider', 'Values type: ${values.runtimeType}');
        // logDebug(
        //   'RatingProvider',
        //   'Values length: ${values is List ? values.length : 'N/A'}',
        // );

        // Handle empty response
        if (values == null || (values is List && values.isEmpty)) {
          logWarning('RatingProvider', 'No rating values found in database');
          _setError(
            'Aucune option de notation disponible. Veuillez contacter le support.',
          );
          _isLoading = false;
          safeNotify();
          return;
        }

        if (level != null) {
          // Load for specific level
          if (values is List) {
            // logDebug(
            //   'RatingProvider',
            //   'Searching for level $level in ${values.length} items',
            // );

            // Find the level data in the response
            final levelData = values.firstWhere(
              (item) => item['ratingLevel'] == level,
              orElse: () => null,
            );

            if (levelData != null) {
              final ratingLevel = levelData['ratingLevel'] as int;
              final optionsList = levelData['options'] as List<dynamic>;

              // logDebug(
              //   'RatingProvider',
              //   'Found level $ratingLevel with ${optionsList.length} options',
              // );

              _ratingOptions = optionsList
                  .map(
                    (o) => RatingValueOption.fromJson(
                      o as Map<String, dynamic>,
                      parentRatingLevel: ratingLevel,
                    ),
                  )
                  .toList();

              _optionsByLevel[level] = _ratingOptions;

              // logSuccess(
              //   'RatingProvider',
              //   'Cached ${_ratingOptions.length} options for level $level',
              // );
            } else {
              // logWarning(
              //   'RatingProvider',
              //   'Level $level not found in response',
              // );
              _ratingOptions = [];
              _optionsByLevel[level] = [];
            }
          } else {
            logError(
              'RatingProvider',
              'Values is not a List: ${values.runtimeType}',
            );
            _ratingOptions = [];
            _optionsByLevel[level] = [];
          }
        } else {
          // Load ALL levels and cache them
          if (values is List) {
            // logInfo(
            //   'RatingProvider',
            //   'Processing ${values.length} rating levels',
            // );

            for (final levelData in values) {
              final ratingLevel = levelData['ratingLevel'] as int;
              final optionsList = levelData['options'] as List<dynamic>;

              // logDebug(
              //   'RatingProvider',
              //   'Processing level $ratingLevel with ${optionsList.length} options',
              // );

              final options = optionsList
                  .map(
                    (o) => RatingValueOption.fromJson(
                      o as Map<String, dynamic>,
                      parentRatingLevel: ratingLevel,
                    ),
                  )
                  .toList();

              _optionsByLevel[ratingLevel] = options;

              // logDebug(
              //   'RatingProvider',
              //   'Cached ${options.length} options for level $ratingLevel',
              // );
            }

            _allLevelsLoaded = true; // Mark all levels as loaded

            // Set current options to level 5 by default
            _ratingOptions = _optionsByLevel[5] ?? [];

            // logSuccess(
            //   'RatingProvider',
            //   'All levels cached. Levels available: ${_optionsByLevel.keys.toList()}',
            // );
            // logInfo(
            //   'RatingProvider',
            //   'Default options set to level 5: ${_ratingOptions.length} options',
            // );
          }
        }

        // Log final state
        // logSuccess(
        //   'RatingProvider',
        //   'Rating values loaded: ${_ratingOptions.length} options for display',
        // );
        // logDebug(
        //   'RatingProvider',
        //   'Total cached levels: ${_optionsByLevel.length}',
        // );
      } else {
        logError(
          'RatingProvider',
          'API returned error: ${response['message']}',
        );
        _setError(response['message'] ?? 'Erreur de chargement');
      }
    } catch (e, stackTrace) {
      logError('RatingProvider', 'Error loading rating values: $e');
      logDebug('RatingProvider', 'Stack trace: $stackTrace');
      _setError('Erreur de connexion');
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  // =========================================================================
  // Submit Rating
  // =========================================================================

  // Submit a rating for a ride
  Future<bool> submitRating({
    required String rideId,
    required String receiverId,
    required String ratingValueId,
    required RatingType ratingType,
    String? comment,
  }) async {
    if (isDisposed) return false;

    final senderId = _userProvider.currentUser?.id;
    if (senderId == null) {
      _setError('Utilisateur non authentifié');
      return false;
    }

    _isSubmitting = true;
    _clearError();
    safeNotify();

    try {
      // logInfo('RatingProvider', 'Submitting rating for ride $rideId');
      // logDebug('RatingProvider', 'Rating value ID: $ratingValueId');
      // logDebug('RatingProvider', 'Rating type: ${ratingType.value}');

      final response = await _apiService.submitRating(
        rideId: rideId,
        ratingValueId: ratingValueId,
      );

      // logDebug('RatingProvider', 'Submit response: ${response['success']}');

      if (response['success'] == true) {
        logSuccess('RatingProvider', 'Rating submitted successfully');

        // Invalidate cached status for this ride
        _rideRatingStatuses.remove(rideId);

        _isSubmitting = false;
        safeNotify();
        return true;
      } else {
        logError('RatingProvider', 'Submission failed: ${response['message']}');
        _setError(response['message'] ?? 'Erreur de soumission');
        _isSubmitting = false;
        safeNotify();
        return false;
      }
    } catch (e, stackTrace) {
      logError('RatingProvider', 'Error submitting rating: $e');
      logDebug('RatingProvider', 'Stack trace: $stackTrace');
      _setError('Erreur de connexion');
      _isSubmitting = false;
      safeNotify();
      return false;
    }
  }

  // =========================================================================
  // User Ratings
  // =========================================================================

  // Get average rating for a user
  Future<Map<String, dynamic>?> getUserAverageRating(String userId) async {
    if (isDisposed) return null;

    try {
      // logInfo('RatingProvider', 'Loading average rating for user $userId');

      final response = await _apiService.getUserAverageRating(userId);

      if (response['success'] == true) {
        return {
          'averageRating': response['averageRating'],
          'totalRatings': response['totalRatings'],
        };
      }

      return null;
    } catch (e) {
      logError('RatingProvider', 'Error loading user average rating: $e');
      return null;
    }
  }

  // =========================================================================
  // Error Handling
  // =========================================================================

  void _setError(String error) {
    _errorMessage = error;
    logError('RatingProvider', error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    safeNotify();
  }

  // =========================================================================
  // Cache Management
  // =========================================================================

  // Clear cached rating status for a ride
  void clearRideRatingStatus(String rideId) {
    _rideRatingStatuses.remove(rideId);
    safeNotify();
  }

  // Clear all cached data
  void clearCache() {
    logInfo('RatingProvider', 'Clearing all cached data');
    _ratingOptions.clear();
    _optionsByLevel.clear();
    _rideRatingStatuses.clear();
    _allLevelsLoaded = false;
    _clearError();
    safeNotify();
  }

  // =========================================================================
  // Debug Helpers
  // =========================================================================

  // Print current cache state (for debugging)
  void debugPrintCacheState() {
    logDebug('RatingProvider', '=== CACHE STATE ===');
    logDebug('RatingProvider', 'All levels loaded: $_allLevelsLoaded');
    logDebug(
      'RatingProvider',
      'Cached levels: ${_optionsByLevel.keys.toList()}',
    );
    for (final level in _optionsByLevel.keys) {
      logDebug(
        'RatingProvider',
        'Level $level: ${_optionsByLevel[level]!.length} options',
      );
    }
    logDebug(
      'RatingProvider',
      'Current display options: ${_ratingOptions.length}',
    );
    logDebug('RatingProvider', '==================');
  }
}
