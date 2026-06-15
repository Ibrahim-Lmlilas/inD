// features/ride_tracking/models/ride_tracking_state.dart

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
class RideTrackingState {
  final String? rideId;
  final bool isPassengerMode;
  final String? driverName;
  final String? passengerName;
  final String? driverProfilePicture;
  final String? passengerProfilePicture;
  final double? driverRating;
  final bool? driverIsValidated;
  final double? passengerRating;
  final String? driverPhone;
  final String? passengerPhone;
  final String? driverId;
  final String? passengerId;
  final int? etaMinutes;
  final double? distanceKm;
  final Map<String, dynamic>? departure;
  final Map<String, dynamic>? destination;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isLoading;
  final bool driverHasArrived;
  final bool passengerIsComing;
  final bool rideHasStarted;
  final int? driverTotalRides;
  final int? passengerTotalRides;

  const RideTrackingState({
    this.rideId,
    required this.isPassengerMode,
    this.driverIsValidated,
    this.driverName,
    this.passengerName,
    this.driverProfilePicture,
    this.passengerProfilePicture,
    this.driverRating,
    this.passengerRating,
    this.driverPhone,
    this.passengerPhone,
    this.driverId,
    this.passengerId,
    this.etaMinutes,
    this.distanceKm,
    this.departure,
    this.destination,
    this.driverTotalRides,
    this.passengerTotalRides,
    required this.markers,
    required this.polylines,
    required this.isLoading,
    required this.driverHasArrived,
    required this.passengerIsComing,
    required this.rideHasStarted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideTrackingState &&
          rideId == other.rideId &&
          isPassengerMode == other.isPassengerMode &&
          etaMinutes == other.etaMinutes &&
          distanceKm == other.distanceKm &&
          isLoading == other.isLoading &&
          driverHasArrived == other.driverHasArrived &&
          passengerIsComing == other.passengerIsComing &&
          rideHasStarted == other.rideHasStarted &&
          _markersEqual(markers, other.markers) &&
          _polylinesEqual(polylines, other.polylines);

  static bool _markersEqual(Set<Marker> a, Set<Marker> b) {
    if (a.length != b.length) return false;
    return a.every((m) => b.any((m2) => m.markerId == m2.markerId));
  }

  static bool _polylinesEqual(Set<Polyline> a, Set<Polyline> b) {
    if (a.length != b.length) return false;
    return a.every((p) => b.any((p2) => p.polylineId == p2.polylineId));
  }

  @override
  int get hashCode => Object.hash(
    rideId,
    isPassengerMode,
    etaMinutes,
    distanceKm,
    isLoading,
    driverHasArrived,
    passengerIsComing,
    rideHasStarted,
  );
}
