// Ride Configuration Provider
//
// features:
// - Only CASH and FREERIDE payment options
// - Free ride requires full points (1pt = 1DH)
// - No loyalty discount system
// - Points fetched from UserProvider

import 'package:srrfrr_app_front/core/services/pricing_service.dart';
import 'package:srrfrr_app_front/shared/models/vehicle_type.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

enum PaymentType { cash, freeRide }

class RideConfigProvider extends DisposableProvider {
  final UserProvider _userProvider;

  RideConfigProvider(this._userProvider);

  // Ride Configuration State
  String? _selectedRideType;
  String? _autoDetectedRideType;
  int _offerPrice = 20;
  int _selectedSeats = 1;
  VehicleType _selectedVehicleType = VehicleType.car;
  PaymentType _selectedPaymentType = PaymentType.cash;

  // Distance for fare calculation
  double? _distance;

  // Cache for expensive calculations
  int? _cachedMinimumFare;
  double? _cachedDistanceForFare;
  String? _cachedRideTypeForFare;
  int? _cachedSeatsForFare;

  // Getters
  String? get selectedRideType => _selectedRideType;
  String? get autoDetectedRideType => _autoDetectedRideType;
  int get offerPrice => _offerPrice;
  int get selectedSeats => _selectedSeats;
  VehicleType get selectedVehicleType => _selectedVehicleType;
  PaymentType get selectedPaymentType => _selectedPaymentType;

  // Get available points from UserProvider
  int get availablePoints => _userProvider.points;

  // Get minimum fare with caching
  int get minimumFare {
    if (_cachedMinimumFare != null &&
        _cachedDistanceForFare == _distance &&
        _cachedRideTypeForFare == _selectedRideType &&
        _cachedSeatsForFare == _selectedSeats) {
      return _cachedMinimumFare!;
    }

    // Calculate and cache
    _cachedMinimumFare = _calculateMinimumFare();
    _cachedDistanceForFare = _distance;
    _cachedRideTypeForFare = _selectedRideType;
    _cachedSeatsForFare = _selectedSeats;
    return _cachedMinimumFare!;
  }

  // Check if user can use free ride (1pt = 1DH)
  bool canUseFreeRide() {
    return availablePoints >= _offerPrice;
  }

  // ============================================================================
  // MARK: - Ride Type Detection
  // ============================================================================

  void detectRideType(String? pickupCity, String? destinationCity) {
    if (isDisposed) return;

    String? newAutoDetected;
    String? newSelected;

    if (pickupCity != null && destinationCity != null) {
      if (pickupCity.toLowerCase() == destinationCity.toLowerCase()) {
        newAutoDetected = 'in_city';
        newSelected = 'in_city';
      } else {
        newAutoDetected = 'city_to_city';
        newSelected = 'city_to_city';
      }
    }

    // Only notify if something changed
    if (newAutoDetected != _autoDetectedRideType ||
        newSelected != _selectedRideType) {
      _autoDetectedRideType = newAutoDetected;
      _selectedRideType = newSelected;
      _cachedMinimumFare = null;

      safeNotify();
    }
  }

  void setSelectedRideType(String? rideType) {
    if (isDisposed || _selectedRideType == rideType) return;

    _selectedRideType = rideType;
    _cachedMinimumFare = null;

    safeNotify();
  }

  // ============================================================================
  // MARK: - Pricing Management
  // ============================================================================

  void updateDistance(double? distance) {
    if (isDisposed || _distance == distance) return;

    _distance = distance;

    // Invalidate cache
    _cachedMinimumFare = null;
    _cachedDistanceForFare = null;

    // Auto-adjust price to minimum fare if below it
    final minFare = minimumFare;
    final needsPriceAdjustment = _offerPrice < minFare;

    if (needsPriceAdjustment) {
      _offerPrice = minFare;
    }

    // Single notify call
    safeNotify();
  }

  int _calculateMinimumFare() {
    if (_distance == null || _selectedRideType == null) {
      return 10;
    }

    return PricingService.calculateMinimumFare(
      distance: _distance!,
      seats: _selectedSeats,
      rideType: _selectedRideType!,
    );
  }

  void setOfferPrice(int price) {
    if (isDisposed) return;

    final minFare = minimumFare;
    final newPrice = price < minFare ? minFare : price;

    if (newPrice == _offerPrice) return;

    _offerPrice = newPrice;
    safeNotify();
  }

  void increasePrice() {
    if (isDisposed) return;

    _offerPrice += 1;
    safeNotify();
  }

  void decreasePrice() {
    if (isDisposed) return;

    final minFare = minimumFare;
    if (_offerPrice > minFare) {
      _offerPrice -= 1;
      safeNotify();
    }
  }

  // ============================================================================
  // MARK: - Seat Selection
  // ============================================================================

  void setSelectedSeats(int seats) {
    if (isDisposed || _selectedSeats == seats) return;

    if (seats >= 1 && seats <= 4) {
      _selectedSeats = seats;
      _cachedMinimumFare = null;

      safeNotify();
    }
  }

  void increaseSeats() {
    if (isDisposed || _selectedSeats >= 4) return;

    _selectedSeats++;
    _cachedMinimumFare = null;

    safeNotify();
  }

  void decreaseSeats() {
    if (isDisposed || _selectedSeats <= 1) return;

    _selectedSeats--;
    _cachedMinimumFare = null;

    safeNotify();
  }

  // ============================================================================
  // MARK: - Vehicle Selection
  // ============================================================================

  void setVehicleType(VehicleType vehicleType) {
    if (isDisposed || _selectedVehicleType == vehicleType) return;

    _selectedVehicleType = vehicleType;
    safeNotify();
  }

  String getVehicleTypeString() {
    return _selectedVehicleType.backendValue;
  }

  // ============================================================================
  // MARK: - Payment Method
  // ============================================================================

  void setPaymentType(PaymentType type) {
    if (isDisposed) return;

    _selectedPaymentType = type;
    safeNotify();
  }

  String getPaymentTypeString() {
    switch (_selectedPaymentType) {
      case PaymentType.cash:
        return 'CASH';
      case PaymentType.freeRide:
        return 'FREERIDE';
    }
  }

  // ============================================================================
  // MARK: - Validation
  // ============================================================================

  bool isConfigurationComplete() {
    // Basic validation
    if (_selectedRideType == null ||
        _offerPrice < minimumFare ||
        _selectedSeats < 1 ||
        _selectedSeats > 4) {
      return false;
    }

    // If free ride selected, check points
    if (_selectedPaymentType == PaymentType.freeRide) {
      return canUseFreeRide();
    }

    return true;
  }

  // ============================================================================
  // MARK: - Reset
  // ============================================================================

  void reset() {
    if (isDisposed) return;

    _selectedRideType = null;
    _autoDetectedRideType = null;
    _offerPrice = 20;
    _selectedSeats = 1;
    _selectedVehicleType = VehicleType.car;
    _selectedPaymentType = PaymentType.cash;
    _distance = null;
    _cachedMinimumFare = null;
    _cachedDistanceForFare = null;
    _cachedRideTypeForFare = null;
    _cachedSeatsForFare = null;

    safeNotify();
  }

  // ============================================================================
  // MARK: - Batch Updates
  // ============================================================================

  void updateConfiguration({
    String? rideType,
    int? price,
    int? seats,
    VehicleType? vehicleType,
  }) {
    if (isDisposed) return;

    bool hasChanges = false;
    bool invalidateCache = false;

    if (rideType != null && rideType != _selectedRideType) {
      _selectedRideType = rideType;
      hasChanges = true;
      invalidateCache = true;
    }

    if (price != null) {
      final minFare = minimumFare;
      final newPrice = price < minFare ? minFare : price;
      if (newPrice != _offerPrice) {
        _offerPrice = newPrice;
        hasChanges = true;
      }
    }

    if (seats != null && seats >= 1 && seats <= 4 && seats != _selectedSeats) {
      _selectedSeats = seats;
      hasChanges = true;
      invalidateCache = true;
    }

    if (vehicleType != null && vehicleType != _selectedVehicleType) {
      _selectedVehicleType = vehicleType;
      hasChanges = true;
    }

    if (invalidateCache) {
      _cachedMinimumFare = null;
    }

    // Single notify for all changes
    if (hasChanges) {
      safeNotify();
    }
  }
}
