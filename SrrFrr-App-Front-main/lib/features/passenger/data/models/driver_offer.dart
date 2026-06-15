/// Driver Offer Model
///
/// Represents a driver's offer for a passenger's ride request.
/// Includes driver details, pricing, vehicle info, and offer timing.

library;

/// Driver offer received via WebSocket
class DriverOffer {
  final String driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhoto;
  final double? rating;
  final String? rideId;
  final Map<String, dynamic>? vehicle;
  final double suggestedPrice;
  final double? distanceKm;
  final bool isCounterOffer;
  final DateTime receivedAt;

  DriverOffer({
    required this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverPhoto,
    this.rating,
    this.rideId,
    this.vehicle,
    required this.suggestedPrice,
    this.distanceKm,
    this.isCounterOffer = false,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Create from WebSocket message
  factory DriverOffer.fromWsMessage(
    Map<String, dynamic> data, {
    bool isCounter = false,
  }) {
    final driverData = data['driver'] as Map<String, dynamic>?;

    String? driverName;
    double? rating;
    String? driverPhone;
    String? driverPhoto;
    Map<String, dynamic>? vehicle;

    if (driverData != null) {
      final firstName = driverData['firstName'] as String? ?? '';
      final lastName = driverData['lastName'] as String? ?? '';
      driverName = '$firstName $lastName'.trim();

      rating = (driverData['rating'] as num?)?.toDouble();
      driverPhone = driverData['phoneNumber'] as String?;
      driverPhoto = driverData['profilePicture'] as String?;

      vehicle = {
        'model':
            '${driverData['vehicleBrand'] ?? ''} ${driverData['vehicleModel'] ?? ''}'
                .trim(),
        'color': driverData['vehicleColor'] ?? 'N/A',
        'type': driverData['vehicleType'] ?? 'auto',
        'plate': 'N/A',
        'profilePicture': driverPhoto,
        'totalRides': driverData['totalRides'] ?? 0,
      };
    }

    return DriverOffer(
      driverId: data['driverId'] as String? ?? '',
      driverName: driverName,
      driverPhone: driverPhone,
      driverPhoto: driverPhoto,
      rating: rating,
      rideId: data['rideId'] as String?,
      vehicle: vehicle,
      suggestedPrice: (data['price'] ?? 0).toDouble(),
      distanceKm: (data['distance'] as num?)?.toDouble(),
      isCounterOffer: (data['offerType'] as String?) == 'counter',
    );
  }

  /// Seconds since offer was received
  int get secondsSinceReceived {
    return DateTime.now().difference(receivedAt).inSeconds;
  }

  /// Check if offer is expiring (>50 seconds old)
  bool get isExpiring => secondsSinceReceived > 50;

  /// Check if offer has expired (>60 seconds old)
  bool get isExpired => secondsSinceReceived >= 60;

  @override
  String toString() {
    return 'DriverOffer('
        'id: $driverId, '
        'name: $driverName, '
        'price: $suggestedPrice, '
        'counter: $isCounterOffer'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverOffer && other.driverId == driverId;
  }

  @override
  int get hashCode => driverId.hashCode;
}
