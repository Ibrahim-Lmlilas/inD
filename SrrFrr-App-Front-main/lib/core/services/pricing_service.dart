// Pricing Service
//
// Centralized pricing calculations for ride fares.
// Implements the business logic for minimum fare calculation,
// dynamic pricing, and price breakdowns.
//
// This can be used by RideConfigProvider or directly by other services.

import 'dart:math';

class PricingService {
  PricingService._();

  // Base pricing constants
  static const double baseMinPrice = 1.0;
  static const double absoluteMinimumFare = 10.0;

  // Distance-based multipliers
  static const double shortDistanceRate = 0.8; // 0-3 km
  static const double mediumDistanceRate = 0.5; // 3-10 km
  static const double longDistanceRate = 0.3; // 10+ km

  // Ride type multipliers
  static const double cityRideMultiplier = 1.0;
  static const double intercityMultiplier = 1.2;

  // Calculate minimum fare using piecewise linear formula
  //
  // Formula breakdown:
  // - Distance 0-3 km: rate = 0.8 DH/km
  // - Distance 3-10 km: rate = 0.5 DH/km
  // - Distance 10+ km: rate = 0.3 DH/km
  // - Base minimum: 10 DH
  //
  // Example calculations:
  // - 2 km, in-city, 1 seat: 2 * (0.8 + 1.0) * 1.0 = 3.6 → 10 DH (minimum)
  // - 5 km, in-city, 1 seat: 5 * (0.5 + 1.0) * 1.0 = 7.5 → 10 DH (minimum)
  // - 15 km, in-city, 1 seat: 15 * (0.3 + 1.0) * 1.0 = 19.5 → 20 DH
  // - 15 km, intercity, 1 seat: 15 * (0.3 + 1.0) * 1.2 = 23.4 → 23 DH
  static int calculateMinimumFare({
    required double distance,
    required int seats,
    required String rideType,
  }) {
    // Determine distance rate based on range
    double distanceRate;
    if (distance <= 3) {
      distanceRate = shortDistanceRate;
    } else if (distance <= 10) {
      distanceRate = mediumDistanceRate;
    } else {
      distanceRate = longDistanceRate;
    }

    // Calculate base fare from distance
    final distanceFare = distance * (distanceRate + baseMinPrice);

    // Apply ride type multiplier
    final rideTypeMultiplier = rideType == 'in_city'
        ? cityRideMultiplier
        : intercityMultiplier;

    final totalFare = distanceFare * rideTypeMultiplier;

    // Ensure minimum fare
    return max(totalFare, absoluteMinimumFare).round();
  }

  // Calculate suggested passenger price (what passenger should offer)
  //
  // This adds a small buffer above minimum fare to attract drivers
  static int calculateSuggestedPassengerPrice({
    required double distance,
    required int seats,
    required String rideType,
  }) {
    final minimumFare = calculateMinimumFare(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );

    // Add 20% buffer for passenger offer
    final suggestedPrice = (minimumFare * 1.2).round();

    return suggestedPrice;
  }

  // Calculate driver's expected minimum (what driver will accept)
  //
  // This is typically the strict minimum fare
  static int calculateDriverMinimum({
    required double distance,
    required int seats,
    required String rideType,
  }) {
    return calculateMinimumFare(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );
  }

  // Get price breakdown for transparency
  //
  // Returns detailed breakdown of how the price was calculated
  static PriceBreakdown getBreakdown({
    required double distance,
    required int seats,
    required String rideType,
    required int finalPrice,
  }) {
    final minimumFare = calculateMinimumFare(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );

    // Determine which distance rate applies
    double distanceRate;
    String distanceCategory;

    if (distance <= 3) {
      distanceRate = shortDistanceRate;
      distanceCategory = 'courte';
    } else if (distance <= 10) {
      distanceRate = mediumDistanceRate;
      distanceCategory = 'moyenne';
    } else {
      distanceRate = longDistanceRate;
      distanceCategory = 'longue';
    }

    final baseFare = distance * (distanceRate + baseMinPrice);
    final rideTypeMultiplier = rideType == 'in_city'
        ? cityRideMultiplier
        : intercityMultiplier;

    final calculated = (baseFare * rideTypeMultiplier).round();
    final isAboveMinimum = finalPrice >= minimumFare;

    return PriceBreakdown(
      distance: distance,
      distanceCategory: distanceCategory,
      distanceRate: distanceRate,
      baseFare: baseFare.round(),
      rideType: rideType,
      rideTypeMultiplier: rideTypeMultiplier,
      minimumFare: minimumFare,
      calculatedFare: calculated,
      finalPrice: finalPrice,
      isAboveMinimum: isAboveMinimum,
    );
  }

  // Validate if a price is acceptable for the given parameters
  static bool isValidPrice({
    required int offeredPrice,
    required double distance,
    required int seats,
    required String rideType,
  }) {
    final minimum = calculateMinimumFare(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );

    return offeredPrice >= minimum;
  }

  // Get price range recommendation
  //
  // Returns min-max range for a given ride
  static PriceRange getPriceRange({
    required double distance,
    required int seats,
    required String rideType,
  }) {
    final minimum = calculateMinimumFare(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );

    final suggested = calculateSuggestedPassengerPrice(
      distance: distance,
      seats: seats,
      rideType: rideType,
    );

    // Maximum is typically 2x minimum
    final maximum = minimum * 2;

    return PriceRange(minimum: minimum, suggested: suggested, maximum: maximum);
  }
}

// Price breakdown for transparency
class PriceBreakdown {
  final double distance;
  final String distanceCategory;
  final double distanceRate;
  final int baseFare;
  final String rideType;
  final double rideTypeMultiplier;
  final int minimumFare;
  final int calculatedFare;
  final int finalPrice;
  final bool isAboveMinimum;

  PriceBreakdown({
    required this.distance,
    required this.distanceCategory,
    required this.distanceRate,
    required this.baseFare,
    required this.rideType,
    required this.rideTypeMultiplier,
    required this.minimumFare,
    required this.calculatedFare,
    required this.finalPrice,
    required this.isAboveMinimum,
  });

  // Get human-readable explanation
  String getExplanation() {
    final buffer = StringBuffer();

    buffer.writeln(
      'Distance: ${distance.toStringAsFixed(1)} km (distance $distanceCategory)',
    );
    buffer.writeln('Tarif de base: $baseFare DH');

    if (rideTypeMultiplier != 1.0) {
      buffer.writeln(
        'Type de trajet: ${rideType == "in_city" ? "En ville" : "Ville à ville"}',
      );
      buffer.writeln(
        'Multiplicateur: x${rideTypeMultiplier.toStringAsFixed(1)}',
      );
    }

    buffer.writeln('Prix minimum: $minimumFare DH');
    buffer.writeln('Prix proposé: $finalPrice DH');

    if (!isAboveMinimum) {
      buffer.writeln('⚠️ Prix en dessous du minimum');
    }

    return buffer.toString();
  }

  @override
  String toString() => getExplanation();
}

// Price range recommendation
class PriceRange {
  final int minimum;
  final int suggested;
  final int maximum;

  PriceRange({
    required this.minimum,
    required this.suggested,
    required this.maximum,
  });

  @override
  String toString() => '$minimum - $maximum DH (suggéré: $suggested DH)';
}
