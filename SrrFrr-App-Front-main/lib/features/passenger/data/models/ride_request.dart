/// Ride Request Model
///
/// Encapsulates all ride request data for passenger journey.

library;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Location data for ride request
class LocationData {
  final String address;
  final LatLng coordinates;
  final String? city;

  const LocationData({
    required this.address,
    required this.coordinates,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'city': city ?? '',
    };
  }

  @override
  String toString() => 'LocationData($address, ${city ?? "unknown city"})';
}

/// Complete ride request data
class RideRequest {
  final String passengerId;
  final LocationData departure;
  final LocationData destination;
  final int price;
  final String rideType;
  final String vehicleType;
  final int seats;
  final double distanceKm;
  final String estimatedTime;
  final String paymentType;
  final DateTime timestamp;

  const RideRequest({
    required this.passengerId,
    required this.departure,
    required this.destination,
    required this.price,
    required this.rideType,
    required this.vehicleType,
    required this.seats,
    required this.distanceKm,
    required this.estimatedTime,
    required this.paymentType,
    required this.timestamp,
  });

  /// Convert to WebSocket message format
  Map<String, dynamic> toWsMessage() {
    return {
      'type': 'rideRequest',
      'passengerId': passengerId,
      'departure': departure.toJson(),
      'destination': destination.toJson(),
      'price': price,
      'rideType': rideType,
      'vehicleType': vehicleType,
      'seats': seats,
      'distanceKm': distanceKm,
      'estimatedTime': estimatedTime,
      'paymentType': paymentType,
    };
  }

  /// Convert to navigation extra data
  Map<String, dynamic> toNavigationData(String? rideId) {
    return {
      'ride_id': rideId,
      'user_id': passengerId,
      'departure': departure.toJson(),
      'destination': destination.toJson(),
      'price': price,
      'ride_type': rideType,
      'vehicle_type': vehicleType,
      'seats': seats,
      'distance_km': distanceKm,
      'estimated_time': estimatedTime,
      'payment_type': paymentType,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RideRequest('
        'from: ${departure.city}, '
        'to: ${destination.city}, '
        'type: $rideType, '
        'price: ${price}DH, '
        'payment: $paymentType'
        ')';
  }
}
