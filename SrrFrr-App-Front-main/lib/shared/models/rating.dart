// Rating Models
//
// Data structures for the rating system supporting both
// passenger-to-driver and driver-to-passenger ratings.
//
// Aligns with backend entities:
// - Rating.java
// - RatingValues.java
// - RatingType.java

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

// Rating type enum matching backend RatingType
enum RatingType {
  passengerToDriver('PASSENGER_TO_DRIVER'),
  driverToPassenger('DRIVER_TO_PASSENGER');

  final String value;
  const RatingType(this.value);

  static RatingType fromString(String value) {
    return RatingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RatingType.passengerToDriver,
    );
  }
}

// Rating value option model
// Maps to backend RatingValues entity
class RatingValueOption {
  final String id;
  final int ratingLevel; // 1-5 stars
  final String labelAR;
  final String labelFR;
  final String labelEN;
  final String? order;

  const RatingValueOption({
    required this.id,
    required this.ratingLevel,
    required this.labelAR,
    required this.labelFR,
    required this.labelEN,
    this.order,
  });

  // Factory constructor with explicit ratingLevel parameter
  // because the backend returns ratingLevel at parent level, not in each option
  factory RatingValueOption.fromJson(
    Map<String, dynamic> json, {
    int? parentRatingLevel, // Pass from parent object
  }) {
    return RatingValueOption(
      id: json['id'] as String? ?? '',
      ratingLevel: parentRatingLevel ?? (json['ratingLevel'] as int? ?? 0),
      labelAR: json['labelAR'] as String? ?? '',
      labelFR: json['labelFR'] as String? ?? '',
      labelEN: json['labelEN'] as String? ?? '',
      order: json['order'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratingLevel': ratingLevel,
      'labelAR': labelAR,
      'labelFR': labelFR,
      'labelEN': labelEN,
      if (order != null) 'order': order,
    };
  }

  // Get label in current language (defaults to French)
  String getLabel(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final language = userProvider.currentUser?.language ?? Language.french;

      switch (language) {
        case Language.arabic:
          return labelAR.isNotEmpty ? labelAR : labelFR;
        case Language.english:
          return labelEN.isNotEmpty ? labelEN : labelFR;
        case Language.french:
        default:
          return labelFR;
      }
    } catch (e) {
      // Fallback if context is not available
      return labelFR;
    }
  }

  // Get order as integer for sorting (0 if null)
  int get orderInt {
    if (order == null) return 0;
    return int.tryParse(order!) ?? 0;
  }
}

// Rating submission request
class RatingSubmission {
  final String rideId;
  final String senderId;
  final String receiverId;
  final String ratingValueId; // ID from RatingValues
  final RatingType ratingType;
  final String? comment; // Optional comment

  const RatingSubmission({
    required this.rideId,
    required this.senderId,
    required this.receiverId,
    required this.ratingValueId,
    required this.ratingType,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'senderId': senderId,
      'receiverId': receiverId,
      'ratingValueId': ratingValueId,
      'ratingType': ratingType.value,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}

// Rating response model
// Maps to backend RatingResponse
class Rating {
  final String id;
  final DateTime createdAt;
  final String rideId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final RatingType ratingType;
  final RatingValueOption ratingValue;

  const Rating({
    required this.id,
    required this.createdAt,
    required this.rideId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.ratingType,
    required this.ratingValue,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rideId: json['rideId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      ratingType: RatingType.fromString(json['ratingType'] as String),
      ratingValue: RatingValueOption.fromJson(
        json['ratingValue'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'rideId': rideId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'ratingType': ratingType.value,
      'ratingValue': ratingValue.toJson(),
    };
  }

  // Get star rating (1-5)
  int get stars => ratingValue.ratingLevel;
}

// Rating values response grouped by level
// Maps to backend RatingValuesResponse
class RatingValuesResponse {
  final int ratingLevel;
  final List<RatingValueOption> options;

  const RatingValuesResponse({
    required this.ratingLevel,
    required this.options,
  });

  // Pass ratingLevel to each option
  factory RatingValuesResponse.fromJson(Map<String, dynamic> json) {
    final ratingLevel = json['ratingLevel'] as int;
    return RatingValuesResponse(
      ratingLevel: ratingLevel,
      options: (json['options'] as List<dynamic>)
          .map(
            (opt) => RatingValueOption.fromJson(
              opt as Map<String, dynamic>,
              parentRatingLevel: ratingLevel, // Pass parent level
            ),
          )
          .toList(),
    );
  }
}

// Check if ride can be rated
class RideRatingStatus {
  final String rideId;
  final bool canRateAsPassenger;
  final bool canRateAsDriver;
  final bool hasPassengerRating;
  final bool hasDriverRating;
  final Rating? passengerRating;
  final Rating? driverRating;

  const RideRatingStatus({
    required this.rideId,
    required this.canRateAsPassenger,
    required this.canRateAsDriver,
    required this.hasPassengerRating,
    required this.hasDriverRating,
    this.passengerRating,
    this.driverRating,
  });

  factory RideRatingStatus.fromJson(Map<String, dynamic> json) {
    return RideRatingStatus(
      rideId: json['rideId'] as String,
      canRateAsPassenger: json['canRateAsPassenger'] as bool,
      canRateAsDriver: json['canRateAsDriver'] as bool,
      hasPassengerRating: json['hasPassengerRating'] as bool,
      hasDriverRating: json['hasDriverRating'] as bool,
      passengerRating: json['passengerRating'] != null
          ? Rating.fromJson(json['passengerRating'] as Map<String, dynamic>)
          : null,
      driverRating: json['driverRating'] != null
          ? Rating.fromJson(json['driverRating'] as Map<String, dynamic>)
          : null,
    );
  }

  // Check if any rating is pending
  bool get hasPendingRatings => canRateAsPassenger || canRateAsDriver;

  // Check if all possible ratings are complete
  bool get isFullyRated => hasPassengerRating && hasDriverRating;
}
