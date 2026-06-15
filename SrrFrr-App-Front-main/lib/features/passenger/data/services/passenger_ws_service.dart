/// Passenger WebSocket Service
///
/// Thin wrapper around PassengerWsProvider for repository pattern.
/// Provides a clean interface for ride-related WebSocket operations.

library;

import 'package:srrfrr_app_front/features/passenger/data/models/ride_request.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/passenger_ws_provider.dart';

/// Service for passenger WebSocket operations
class PassengerWsService {
  final PassengerWsProvider _provider;

  PassengerWsService(this._provider);

  /// Get current ride ID
  String? get currentRideId => _provider.currentRideId;

  /// Send ride request
  Future<bool> sendRideRequest(RideRequest request) async {
    return await _provider.sendRideRequest(
      passengerId: request.passengerId,
      departure: request.departure.toJson(),
      destination: request.destination.toJson(),
      price: request.price,
      rideType: request.rideType,
      vehicleType: request.vehicleType,
      seats: request.seats,
      distanceKm: request.distanceKm,
      estimatedTime: request.estimatedTime,
      paymentType: request.paymentType,
    );
  }

  /// Accept driver offer
  Future<bool> acceptDriver(String driverId, String passengerId) async {
    return await _provider.acceptDriver(driverId, passengerId);
  }

  /// Reject driver offer
  Future<bool> rejectDriver(String driverId, String passengerId) async {
    return await _provider.rejectDriver(driverId, passengerId);
  }

  /// Cancel ride
  Future<bool> cancelRide(String passengerId, String reason) async {
    return await _provider.cancelRide(passengerId, reason);
  }

  /// Send counter-offer
  Future<bool> sendCounterOffer(String passengerId, double newPrice) async {
    return await _provider.sendCounterOffer(
      passengerId,
      newPrice,
      0, // Not used in service layer
      '', // Not used in service layer
    );
  }
}
