/// Ride Repository
///
/// Handles ride request validation and coordination between
/// WebSocket service and application state.

library;

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/passenger/data/models/ride_request.dart';
import 'package:srrfrr_app_front/features/passenger/data/services/passenger_ws_service.dart';

/// Result wrapper for repository operations
sealed class RideResult<T> {
  const RideResult();
}

final class RideSuccess<T> extends RideResult<T> {
  final T data;
  const RideSuccess(this.data);
}

final class RideFailure<T> extends RideResult<T> {
  final String message;
  const RideFailure(this.message);
}

/// Repository for ride operations
class RideRepository {
  final PassengerWsService _wsService;

  RideRepository(this._wsService);

  /// Validate and submit ride request
  Future<RideResult<String>> submitRideRequest(RideRequest request) async {
    try {
      // Validate request
      final validation = _validateRequest(request);
      if (validation != null) {
        return RideFailure(validation);
      }

      logInfo('[RideRepository]', '📤 Submitting ride request: $request');

      // Send via WebSocket
      final success = await _wsService.sendRideRequest(request);

      if (!success) {
        return const RideFailure('Failed to send ride request');
      }

      // Wait for ride ID confirmation
      final rideId = await _waitForRideId();

      if (rideId == null) {
        return const RideFailure('Timeout waiting for ride confirmation');
      }

      logSuccess('[RideRepository]', '✅ Ride request confirmed: $rideId');
      return RideSuccess(rideId);
    } catch (e) {
      logError('[RideRepository]', '❌ Submit failed: $e');
      return RideFailure('Error: ${e.toString()}');
    }
  }

  /// Validate ride request data
  String? _validateRequest(RideRequest request) {
    if (request.departure.address.isEmpty) {
      return 'Departure address is required';
    }

    if (request.destination.address.isEmpty) {
      return 'Destination address is required';
    }

    if (request.price <= 0) {
      return 'Price must be greater than 0';
    }

    if (request.seats < 1 || request.seats > 4) {
      return 'Seats must be between 1 and 4';
    }

    if (request.distanceKm <= 0) {
      return 'Invalid distance';
    }

    return null; // Valid
  }

  /// Wait for ride ID from WebSocket
  Future<String?> _waitForRideId() async {
    const maxWaitSeconds = 10;
    const checkIntervalMs = 100;
    final maxAttempts = (maxWaitSeconds * 1000) ~/ checkIntervalMs;

    for (var i = 0; i < maxAttempts; i++) {
      final rideId = _wsService.currentRideId;
      if (rideId != null) {
        return rideId;
      }
      await Future.delayed(const Duration(milliseconds: checkIntervalMs));
    }

    return null;
  }

  /// Accept driver offer
  Future<RideResult<void>> acceptDriver(
    String driverId,
    String passengerId,
  ) async {
    try {
      logInfo('[RideRepository]', '✅ Accepting driver: $driverId');

      final success = await _wsService.acceptDriver(driverId, passengerId);

      if (success) {
        return const RideSuccess(null);
      } else {
        return const RideFailure('Failed to accept driver');
      }
    } catch (e) {
      logError('[RideRepository]', '❌ Accept driver failed: $e');
      return RideFailure('Error: ${e.toString()}');
    }
  }

  /// Reject driver offer
  Future<RideResult<void>> rejectDriver(
    String driverId,
    String passengerId,
  ) async {
    try {
      logInfo('[RideRepository]', '🔙 Rejecting driver: $driverId');

      final success = await _wsService.rejectDriver(driverId, passengerId);

      if (success) {
        return const RideSuccess(null);
      } else {
        return const RideFailure('Failed to reject driver');
      }
    } catch (e) {
      logError('[RideRepository]', '❌ Reject driver failed: $e');
      return RideFailure('Error: ${e.toString()}');
    }
  }

  /// Cancel ride request
  Future<RideResult<void>> cancelRide(String passengerId, String reason) async {
    try {
      logInfo('[RideRepository]', '🔙 Cancelling ride: $reason');

      final success = await _wsService.cancelRide(passengerId, reason);

      if (success) {
        return const RideSuccess(null);
      } else {
        return const RideFailure('Failed to cancel ride');
      }
    } catch (e) {
      logError('[RideRepository]', '❌ Cancel ride failed: $e');
      return RideFailure('Error: ${e.toString()}');
    }
  }

  /// Send counter offer
  Future<RideResult<void>> sendCounterOffer(
    String passengerId,
    double newPrice,
    int availablePoints,
    String paymentType,
  ) async {
    try {
      // Validate free ride counter-offer
      if (paymentType == 'FREERIDE' && availablePoints < newPrice.toInt()) {
        return RideFailure(
          'Points insuffisants: ${newPrice.toInt()}pts requis, '
          'vous avez ${availablePoints}pts',
        );
      }

      logInfo('[RideRepository]', '💰 Sending counter-offer: ${newPrice}DH');

      final success = await _wsService.sendCounterOffer(passengerId, newPrice);

      if (success) {
        return const RideSuccess(null);
      } else {
        return const RideFailure('Failed to send counter-offer');
      }
    } catch (e) {
      logError('[RideRepository]', '❌ Counter-offer failed: $e');
      return RideFailure('Error: ${e.toString()}');
    }
  }
}
