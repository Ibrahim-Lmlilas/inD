// Driver Provider
//
// Tracks driver offers and manages driver selection state.
// Syncs with PassengerWsProvider to display available drivers.

library;

import 'dart:async';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/features/passenger/data/models/driver_offer.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/passenger_ws_provider.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

// Represents a driver with their details and offer information
class Driver {
  final String id;
  final String name;
  final double rating;
  final Map<String, dynamic> vehicle;
  final int suggestedPrice;
  final double distanceKm;
  final bool isCounterOffer;
  final DateTime receivedAt;

  Driver({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.suggestedPrice,
    required this.distanceKm,
    this.isCounterOffer = false,
    required this.receivedAt,
  });

  // Creates a Driver instance from a WebSocket driver offer
  factory Driver.fromWsOffer(DriverOffer offer) {
    return Driver(
      id: offer.driverId,
      name: offer.driverName ?? 'Conducteur',
      rating: offer.rating ?? 4.5,
      vehicle:
          offer.vehicle ??
          {'model': 'Véhicule', 'color': 'N/A', 'plate': 'N/A'},
      suggestedPrice: offer.suggestedPrice.round(),
      distanceKm: offer.distanceKm ?? 0.0,
      isCounterOffer: offer.isCounterOffer,
      receivedAt: offer.receivedAt,
    );
  }

  // Returns the number of seconds since the offer was received
  int get secondsSinceReceived {
    final now = DateTime.now();
    return now.difference(receivedAt).inSeconds;
  }

  // Returns true if the driver offer is expiring (more than 50 seconds old)
  bool get isExpiring => secondsSinceReceived > 50;
}

// ============================================================================
// DRIVER PROVIDER CLASS
// ============================================================================

// Manages driver offers, selection state, and synchronization with WebSocket provider
class DriverProvider extends DisposableProvider {
  final PassengerWsProvider _wsProvider;

  // ============================================================================
  // PRIVATE PROPERTIES
  // ============================================================================

  List<Driver> _drivers = [];
  String? _requestId;
  int _passengerPrice = 0;
  Timer? _uiUpdateTimer;
  StreamSubscription? _offerSubscription;

  final Set<String> _rejectedDriverIds = {};

  // Public getters
  List<Driver> get drivers => _drivers;

  // Current ride request ID
  String? get requestId => _requestId;

  // Passenger's offered price for the ride
  int get passengerPrice => _passengerPrice;

  // Returns true if there are any available drivers
  bool get hasDrivers => _drivers.isNotEmpty;

  // ============================================================================
  // CONSTRUCTOR AND INITIALIZATION
  // ============================================================================

  DriverProvider(this._wsProvider) {
    _initialize();
  }

  // Initializes the provider by starting listeners and timers
  void _initialize() {
    _startDriverOfferListener();
    _startUiUpdateTimer();
  }

  // ============================================================================
  // STREAM LISTENERS AND TIMERS
  // ============================================================================

  // Starts listening for driver offers from WebSocket provider
  void _startDriverOfferListener() {
    _offerSubscription?.cancel();

    _offerSubscription = Stream.periodic(const Duration(milliseconds: 500)).listen((
      _,
    ) {
      if (isDisposed) return;

      final currentOffers = _wsProvider.driverOffers;
      final pendingOffer = _wsProvider.pendingCounterOffer;

      final allOffers = <DriverOffer>[
        ...currentOffers,
        if (pendingOffer != null) pendingOffer,
      ];

      final offerIds = allOffers.map((o) => o.driverId).toSet();

      // Remove drivers that are no longer available or were rejected
      _drivers.removeWhere((driver) {
        final shouldRemove =
            !offerIds.contains(driver.id) ||
            _rejectedDriverIds.contains(driver.id);

        if (shouldRemove) {
          logWarning('DriverProvider', 'Removing driver: ${driver.name}');
        }

        return shouldRemove;
      });

      // Process new and updated offers
      for (final offer in allOffers) {
        if (_rejectedDriverIds.contains(offer.driverId)) {
          continue;
        }

        final driver = Driver.fromWsOffer(offer);
        final existingIndex = _drivers.indexWhere((d) => d.id == driver.id);

        if (existingIndex >= 0) {
          _drivers[existingIndex] = driver;
        } else {
          _drivers.add(driver);
          logSuccess(
            'DriverProvider',
            '✅ New ${driver.isCounterOffer ? "counter-offer" : "offer"}: ${driver.name} - ${driver.suggestedPrice} DH',
          );
        }
      }

      safeNotify();
    });
  }

  // Starts a timer to periodically update the UI for expiring offers
  void _startUiUpdateTimer() {
    _uiUpdateTimer?.cancel();

    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isDisposed) {
        timer.cancel();
        return;
      }

      if (_drivers.isNotEmpty) {
        safeNotify();
      }
    });
  }

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  // Loads drivers for a specific ride request
  //
  // [rideId] - The unique identifier for the ride request
  // [price] - The passenger's offered price for the ride
  Future<void> loadDrivers(String rideId, int price) async {
    try {
      _requestId = rideId;
      _passengerPrice = price;
      _drivers.clear();
      _rejectedDriverIds.clear();

      logInfo(
        'DriverProvider',
        '⏳ Waiting for drivers on ride: $rideId at $price DH',
      );
      safeNotify();
    } catch (e) {
      logError('DriverProvider', 'Error loading drivers: $e');
    }
  }

  // Accepts a driver's offer for the ride
  //
  // [driverId] - The unique identifier of the driver to accept
  // [passengerId] - The unique identifier of the passenger
  // Returns true if the acceptance was successfully sent
  Future<bool> acceptDriver(String driverId, String passengerId) async {
    if (isDisposed) return false;

    try {
      logInfo('DriverProvider', '✅ Accepting driver: $driverId');

      final success = await _wsProvider.acceptDriver(driverId, passengerId);

      if (success) {
        logSuccess(
          'DriverProvider',
          '✅ Driver acceptance sent, waiting for rideConfirmed',
        );
      }

      return success;
    } catch (e) {
      logError('DriverProvider', 'Error accepting driver: $e');
      return false;
    }
  }

  // Declines a driver's offer for the ride
  //
  // [driverId] - The unique identifier of the driver to decline
  // [passengerId] - The unique identifier of the passenger
  // Returns true if the rejection was successfully sent
  Future<bool> declineDriver(String driverId, String passengerId) async {
    if (isDisposed) return false;

    try {
      logInfo('DriverProvider', '📤 Declining driver: $driverId');

      // Mark driver as rejected BEFORE sending message
      _rejectedDriverIds.add(driverId);

      // Remove from UI immediately for better UX
      _drivers.removeWhere((d) => d.id == driverId);
      safeNotify();

      logInfo('DriverProvider', '🗑️ Driver removed from UI');

      // Send rejectDriver message to backend
      // Backend will send offerRejected to driver
      final success = await _wsProvider.rejectDriver(driverId, passengerId);

      if (!success) {
        // If rejection failed, remove from rejected list so driver can try again
        _rejectedDriverIds.remove(driverId);
        logWarning(
          'DriverProvider',
          '⚠️ Failed to reject driver, allowing retry',
        );
      } else {
        logSuccess('DriverProvider', '✅ Driver rejection sent to backend');
      }

      return success;
    } catch (e) {
      logError('DriverProvider', '❌ Error declining driver: $e');
      _rejectedDriverIds.remove(driverId);
      return false;
    }
  }

  // Cancels the current ride request
  //
  // [passengerId] - The unique identifier of the passenger
  // Returns true if the cancellation was successfully sent
  Future<bool> cancelRequest(String passengerId) async {
    if (isDisposed) return false;

    try {
      logInfo('DriverProvider', '📤 Cancelling ride request');

      // Send cancelRide event
      final success = await _wsProvider.cancelRide(
        passengerId,
        'user_cancelled',
      );

      if (success) {
        logSuccess('DriverProvider', '✅ Cancellation sent to backend');
        _cleanup();
      } else {
        logError('DriverProvider', '❌ Failed to send cancellation');
      }

      return success;
    } catch (e) {
      logError('DriverProvider', '❌ Error canceling request: $e');
      return false;
    }
  }

  // ============================================================================
  // CLEANUP AND DISPOSAL
  // ============================================================================

  // Cleans up internal state and resets the provider
  void _cleanup() {
    logInfo('DriverProvider', '🧹 Cleaning up state');

    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = null;
    _requestId = null;
    _drivers.clear();
    _rejectedDriverIds.clear();
    _passengerPrice = 0;

    safeNotify();

    logSuccess('DriverProvider', '✅ State cleaned up');
  }

  // Disposes of the provider and cleans up resources
  @override
  void dispose() {
    logInfo('DriverProvider', '🗑️ Disposing DriverProvider');

    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = null;
    _offerSubscription?.cancel();

    super.dispose();

    logSuccess('DriverProvider', '✅ DriverProvider disposed');
  }
}
