// Ride Tracking Provider
// Manages UI state and delegates WebSocket operations to the service layer

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/core/utils/map_utils.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/services/ride_tracking_service.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

// Manages real-time ride tracking UI state
// Delegates WebSocket communication to RideTrackingService
class RideTrackingProvider extends DisposableProvider {
  final RideTrackingService _trackingService;
  final UserProvider _userProvider;

  // User context
  String _userMode = 'passenger';

  // Ride data
  String? _rideId;
  String? _driverId;
  String? _passengerId;
  String? _channelId;
  String? _wsToken;
  double? _price;
  String? _rideType;
  String? _vehicleType;
  int? _seats;

  // Ride status flags
  bool _driverHasArrived = false;
  bool _passengerIsComing = false;
  bool _rideHasStarted = false;

  // User info
  String? _driverName;
  String? _driverPhone;
  String? _driverProfilePicture;
  double? _driverRating;
  int? _driverTotalRides;
  bool? _driverIsVerified;
  Map<String, dynamic>? _driverVehicle;

  String? _passengerName;
  String? _passengerPhone;
  String? _passengerProfilePicture;
  double? _passengerRating;
  int? _passengerTotalRides;

  // Location state
  Map<String, dynamic>? _departure;
  Map<String, dynamic>? _destination;
  LatLng? _passengerLocation;
  LatLng? _driverLocation;
  List<LatLng> _routePoints = [];

  // Distance & time
  double? _distanceKm;
  String? _estimatedTime;
  int? _etaMinutes;

  // Map elements
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _routeRefreshTimer;
  bool _isDisposed = false;

  // Callbacks
  Function(Map<String, dynamic>)? _onRideCancelled;
  Function(Map<String, dynamic>)? _onRideCompleted;
  Function(Map<String, dynamic>)? _onApproachingDestination;

  // Public getters
  String get userMode => _userMode;
  bool get isPassengerMode => _userMode == 'passenger';
  bool get isDriverMode => _userMode == 'driver';

  String? get rideId => _rideId;
  String? get driverId => _driverId;
  String? get passengerId => _passengerId;
  String? get channelId => _channelId;
  String? get wsToken => _wsToken;
  double? get price => _price;
  String? get rideType => _rideType;
  String? get vehicleType => _vehicleType;
  int? get seats => _seats;

  bool get driverHasArrived => _driverHasArrived;
  bool get passengerIsComing => _passengerIsComing;
  bool get rideHasStarted => _rideHasStarted;

  String? get driverName => _driverName;
  String? get driverPhone => _driverPhone;
  String? get driverProfilePicture => _driverProfilePicture;
  double? get driverRating => _driverRating;
  int? get driverTotalRides => _driverTotalRides;
  Map<String, dynamic>? get driverVehicle => _driverVehicle;
  bool? get driverIsValidated => _driverIsVerified;

  String? get passengerName => _passengerName;
  String? get passengerPhone => _passengerPhone;
  String? get passengerProfilePicture => _passengerProfilePicture;
  double? get passengerRating => _passengerRating;
  int? get passengerTotalRides => _passengerTotalRides;

  Map<String, dynamic>? get departure => _departure;
  Map<String, dynamic>? get destination => _destination;
  LatLng? get passengerLocation => _passengerLocation;
  LatLng? get driverLocation => _driverLocation;
  List<LatLng> get routePoints => _routePoints;

  double? get distanceKm => _distanceKm;
  String? get estimatedTime => _estimatedTime;
  int? get etaMinutes => _etaMinutes;

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RideTrackingProvider(this._trackingService, this._userProvider) {
    logInfo('RideTracking', 'Provider initialized with RideTrackingService');
    _setupServiceCallbacks();
  }

  // ==========================================================================
  // CALLBACK REGISTRATION
  // ==========================================================================

  void setOnRideCancelledCallback(Function(Map<String, dynamic>) callback) {
    _onRideCancelled = callback;
  }

  void setOnApproachingDestinationCallback(
    Function(Map<String, dynamic>) callback,
  ) {
    _onApproachingDestination = callback;
  }

  void setOnRideCompletedCallback(Function(Map<String, dynamic>) callback) {
    _onRideCompleted = callback;
  }

  void clearCallbacks() {
    _onRideCancelled = null;
    _onRideCompleted = null;
    _onApproachingDestination = null;
    _trackingService.clearCallbacks();
    logInfo('RideTracking', 'Callbacks cleared');
  }

  // ==========================================================================
  // SERVICE CALLBACKS SETUP
  // ==========================================================================

  void _setupServiceCallbacks() {
    logInfo('RideTracking', 'Setting up service callbacks');

    // Location updates from driver
    _trackingService.setOnLocationUpdate((location, data) {
      if (_isDisposed) return;

      logCritical('RideTracking', 'Location update received from service');
      _handleLocationUpdate(location, data);
    });

    // Driver arrived at pickup
    _trackingService.setOnDriverArrived((data) {
      if (_isDisposed) return;

      logSuccess('RideTracking', 'Driver arrived event received');
      _driverHasArrived = true;
      safeNotify();
    });

    // Passenger coming to pickup
    _trackingService.setOnPassengerComing((data) {
      if (_isDisposed) return;

      logSuccess('RideTracking', 'Passenger coming event received');
      _passengerIsComing = true;
      safeNotify();
    });

    // Ride started
    _trackingService.setOnRideStarted((data) {
      if (_isDisposed) return;

      logSuccess('RideTracking', 'Ride started event received');
      _rideHasStarted = true;
      _updateMarkersForRideStart();
      safeNotify();
    });

    // Ride completed
    _trackingService.setOnRideCompleted((data) {
      if (_isDisposed) return;

      logSuccess('RideTracking', 'Ride completed event received');
      if (_onRideCompleted != null) {
        _onRideCompleted!(data);
      }

      // Cleanup provider state after completion
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDisposed) {
          _cleanup();
        }
      });
    });

    // Approaching destination
    _trackingService.setOnApproachingDestination((data) {
      if (_isDisposed) return;

      final distance = data['distance'] as double?;
      logCritical(
        'RideTracking',
        'Approaching destination - Distance: $distance km',
      );

      if (_onApproachingDestination != null) {
        _onApproachingDestination!(data);
      }
    });

    // Ride cancelled
    _trackingService.setOnRideCancelled((data) {
      if (_isDisposed) return;

      final rideId = data['rideId'] as String?;
      final userId = data['userId'] as String?;

      final isOurRide = rideId == _rideId;
      final isOtherUserCancelling =
          (_userMode == 'driver' && userId == _passengerId) ||
          (_userMode == 'passenger' && userId == _driverId);

      if (isOurRide && isOtherUserCancelling && _onRideCancelled != null) {
        _onRideCancelled!(data);
        logWarning('RideTracking', 'Ride cancelled by other party');

        // Cleanup provider state after cancellation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_isDisposed) {
            _cleanup();
          }
        });
      }
    });

    // Error handling
    _trackingService.setOnError((data) {
      if (_isDisposed) return;

      final errorMsg = data['message'] as String?;
      _errorMessage = errorMsg;
      safeNotify();
      logError('RideTracking', 'Service error: $errorMsg');
    });

    logSuccess('RideTracking', 'Service callbacks configured');
  }

  // ==========================================================================
  // LOCATION UPDATE HANDLING
  // ==========================================================================

  void _handleLocationUpdate(LatLng location, Map<String, dynamic> data) {
    logCritical('RideTracking', 'Processing location update');

    _driverLocation = location;

    // Extract distance info if available
    final distanceToPickup = data['distanceToPickup'] as double?;
    final distanceToDestination = data['distanceToDestination'] as double?;

    if (distanceToPickup != null && !_rideHasStarted) {
      _distanceKm = distanceToPickup;
      logInfo(
        'RideTracking',
        'Distance to pickup: ${_distanceKm!.toStringAsFixed(2)} km',
      );
    } else if (distanceToDestination != null && _rideHasStarted) {
      _distanceKm = distanceToDestination;
      logInfo(
        'RideTracking',
        'Distance to destination: ${_distanceKm!.toStringAsFixed(2)} km',
      );
    }

    _updateMarkers();
    _calculateRoute();
    safeNotify();

    logSuccess('RideTracking', 'Location update processed - UI refreshed');
  }

  // ==========================================================================
  // RIDE INITIALIZATION
  // ==========================================================================

  void initializeRide(
    Map<String, dynamic> payload,
    String? userMode, {
    LatLng? initialDriverLocation,
  }) {
    logInfo('RideTracking', '========================================');
    logCritical('RideTracking', 'Initializing ride from payload');
    logInfo('RideTracking', '========================================');

    final storedMode = _userProvider.currentMode;
    _userMode = storedMode == UserMode.driver ? 'driver' : 'passenger';

    if (userMode != null && userMode != _userMode) {
      logWarning(
        'RideTracking',
        'Mode mismatch - Provided: $userMode, Stored: $_userMode',
      );
    }

    // logCritical('RideTracking', 'User mode: $_userMode');

    _isLoading = false;

    // Extract ride data
    _rideId = payload['rideId'] as String?;
    _driverId = payload['driverId'] as String?;
    _passengerId = payload['passengerId'] as String?;
    _price = (payload['price'] as num?)?.toDouble();
    _rideType = payload['rideType'] as String?;
    _vehicleType = payload['vehicleType'] as String?;
    _seats = payload['seats'] as int?;
    _distanceKm = (payload['distanceKm'] as num?)?.toDouble();
    _estimatedTime = payload['estimatedTime'] as String?;
    _channelId = payload['channelId'] as String?;
    _wsToken = payload['wsToken'] as String?;
    final rideStatus = payload['status'] as String?;

    // logWarning(
    //   'ride tracking',
    //   'the status fetched from current ride : $rideStatus',
    // );

    // logCritical(
    //   'ride tracking',
    //   'this is the current ride received : $payload',
    // );

    if (rideStatus == 'STARTED') {
      _driverHasArrived = true;
      _passengerIsComing = true;
      _rideHasStarted = true;
    } else {
      // Reset status flags
      _driverHasArrived = false;
      _passengerIsComing = false;
      _rideHasStarted = false;
    }

    logCritical('RideTracking', 'Ride ID: $_rideId');

    // Extract locations
    _departure = payload['departure'] as Map<String, dynamic>?;
    _destination = payload['destination'] as Map<String, dynamic>?;

    if (_departure != null) {
      final lat = (_departure!['latitude'] as num?)?.toDouble();
      final lng = (_departure!['longitude'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        _passengerLocation = LatLng(lat, lng);
        logInfo('RideTracking', 'Passenger location set');
      }
    }

    // Set initial driver location
    if (initialDriverLocation != null) {
      _driverLocation = initialDriverLocation;
      logInfo('RideTracking', 'Driver location set from initial parameter');
    } else if (_userMode == 'passenger') {
      final driverData = payload['driver'] as Map<String, dynamic>?;
      if (driverData != null) {
        final lat = (driverData['currentLatitude'] as num?)?.toDouble();
        final lng = (driverData['currentLongitude'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          _driverLocation = LatLng(lat, lng);
          logInfo('RideTracking', 'Driver location extracted from payload');
        }
      }
    }

    // Extract user info
    if (_userMode == 'passenger') {
      _extractDriverInfo(payload['driver'] as Map<String, dynamic>?);
    } else {
      _extractPassengerInfo(payload['passenger'] as Map<String, dynamic>?);
    }

    logSuccess('RideTracking', 'Ride initialization complete');

    // Connect to WebSocket via service
    _connectToRideTracking();

    // Start route refresh timer for passenger
    if (_userMode == 'passenger') {
      _startRouteRefreshTimer();
    }

    safeNotify();
    _updateMarkers();
  }

  Future<void> _connectToRideTracking() async {
    if (_rideId == null) {
      logError('RideTracking', 'Cannot connect - Missing ride ID');
      return;
    }

    try {
      logInfo('RideTracking', 'Connecting via RideTrackingService');

      await _trackingService.connect(
        rideId: _rideId!,
        userMode: _userMode,
        driverId: _driverId,
        passengerId: _passengerId,
      );

      logSuccess('RideTracking', 'Connected successfully');
    } catch (e) {
      logError('RideTracking', 'Connection failed: $e');
      _errorMessage = 'Connection failed';
      safeNotify();
    }
  }

  void _extractDriverInfo(Map<String, dynamic>? data) {
    if (data == null) return;

    _driverName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    _driverPhone = data['phoneNumber'];
    _driverProfilePicture = data['profilePicture'];
    _driverRating = (data['rating'] as num?)?.toDouble();
    _driverTotalRides = data['totalRides'] as int?;
    _driverIsVerified = data['isVerified'];

    _driverVehicle = {
      'model': '${data['vehicleBrand'] ?? ''} ${data['vehicleModel'] ?? ''}'
          .trim(),
      'color': data['vehicleColor'] ?? 'N/A',
      'type': data['vehicleType'] ?? 'auto',
      'registration-code': data['vehicleRegistrationCode'] ?? 'N/A',
    };

    logInfo('RideTracking', 'Driver info extracted: $_driverName');
  }

  void _extractPassengerInfo(Map<String, dynamic>? data) {
    if (data == null) return;

    _passengerName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
        .trim();
    _passengerPhone = data['phoneNumber'];
    _passengerProfilePicture = data['profilePicture'];
    _passengerRating = (data['rating'] as num?)?.toDouble();
    _passengerTotalRides = data['totalRides'] as int?;

    logInfo('RideTracking', 'Passenger info extracted: $_passengerName');
  }

  // ==========================================================================
  // RIDE STATUS ACTIONS
  // ==========================================================================

  Future<void> confirmDriverArrival() async {
    if (_driverLocation == null) {
      logError('RideTracking', 'Cannot confirm arrival - No location');
      return;
    }

    try {
      await _trackingService.sendDriverArrived(_driverLocation!);
      _driverHasArrived = true;
      safeNotify();
      logSuccess('RideTracking', 'Driver arrival confirmed');
    } catch (e) {
      logError('RideTracking', 'Error confirming arrival: $e');
    }
  }

  Future<void> notifyDriverPassengerComing() async {
    try {
      await _trackingService.sendPassengerComing(
        customMessage: 'Je suis en route vers le point de ramassage',
      );
      _passengerIsComing = true;
      safeNotify();
      logSuccess('RideTracking', 'Passenger coming notification sent');
    } catch (e) {
      logError('RideTracking', 'Error sending notification: $e');
    }
  }

  Future<void> startRide() async {
    try {
      await _trackingService.sendStartRide();
      _rideHasStarted = true;
      safeNotify();
      logSuccess('RideTracking', 'Ride started successfully');
    } catch (e) {
      logError('RideTracking', 'Error starting ride: $e');
    }
  }

  Future<void> finishRide() async {
    _isLoading = true;
    safeNotify();

    try {
      await _trackingService.sendFinishRide();
      logSuccess('RideTracking', 'Ride completion request sent');
    } catch (e) {
      logError('RideTracking', 'Error finishing ride: $e');
      _isLoading = false;
      safeNotify();
    }
  }

  // ==========================================================================
  // MAP & ROUTE MANAGEMENT
  // ==========================================================================

  void _updateMarkersForRideStart() {
    _markers.clear();

    if (_destination != null) {
      final destLat = (_destination!['latitude'] as num).toDouble();
      final destLng = (_destination!['longitude'] as num).toDouble();

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destLat, destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destination!['address'] as String?,
          ),
        ),
      );

      logInfo('RideTracking', 'Destination marker added');
    }

    if (_driverLocation != null) {
      _markers.add(
        MapUtils.createDriverMarker(
          position: _driverLocation!,
          driverName: isDriverMode
              ? 'Votre position'
              : _driverName ?? 'Chauffeur',
          vehicleModel: _driverVehicle?['model'] as String?,
        ),
      );
    }

    _calculateRoute();
    logSuccess('RideTracking', 'Markers updated for ride start');
  }

  void _updateMarkers() {
    _markers.clear();

    if (_rideHasStarted && _destination != null) {
      final destLat = (_destination!['latitude'] as num).toDouble();
      final destLng = (_destination!['longitude'] as num).toDouble();

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destLat, destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destination!['address'] as String?,
          ),
        ),
      );
    } else if (_passengerLocation != null) {
      _markers.add(
        MapUtils.createPassengerMarker(
          position: _passengerLocation!,
          passengerName: isPassengerMode
              ? 'Votre position'
              : _passengerName ?? 'Passager',
        ),
      );
    }

    if (_driverLocation != null) {
      _markers.add(
        MapUtils.createDriverMarker(
          position: _driverLocation!,
          driverName: isDriverMode
              ? 'Votre position'
              : _driverName ?? 'Chauffeur',
          vehicleModel: _driverVehicle?['model'] as String?,
        ),
      );
    }

    if (_markers.isNotEmpty) {
      safeNotify();
    }
  }

  Future<void> _calculateRoute() async {
    if (_driverLocation == null) return;

    final destination = _rideHasStarted && _destination != null
        ? LatLng(
            (_destination!['latitude'] as num).toDouble(),
            (_destination!['longitude'] as num).toDouble(),
          )
        : _passengerLocation;

    if (destination == null) return;

    try {
      final routeData = await MapUtils.calculateRoute(
        origin: _driverLocation!,
        destination: destination,
      );

      if (_isDisposed) return;

      if (routeData != null && routeData['success'] == true) {
        _routePoints = routeData['points'] as List<LatLng>;

        if (_distanceKm == null) {
          _distanceKm = routeData['distance'] as double?;
        }

        _estimatedTime = routeData['durationText']!;

        final durationSeconds = routeData['duration'] as int?;
        if (durationSeconds != null) {
          _etaMinutes = (durationSeconds / 60).round();
        }

        _updatePolylines();

        if (_mapController != null && _routePoints.isNotEmpty) {
          _fitRouteInView();
        }
      }
    } catch (e) {
      logError('RideTracking', 'Route calculation error: $e');
    }
  }

  void _updatePolylines() {
    _polylines.clear();

    if (_routePoints.isNotEmpty) {
      _polylines.add(
        MapUtils.createPolyline(
          id: _rideHasStarted ? 'to_destination' : 'to_pickup',
          points: _routePoints,
          color: _rideHasStarted
              ? const Color(0xFFDC2626)
              : const Color(0xFF10B981),
          width: 5,
        ),
      );
    }

    safeNotify();
  }

  void _fitRouteInView() {
    if (_isDisposed || _mapController == null) return;

    try {
      final coordinates = _routePoints.isNotEmpty
          ? _routePoints
          : [
              if (_passengerLocation != null) _passengerLocation!,
              if (_driverLocation != null) _driverLocation!,
            ];

      if (coordinates.isNotEmpty) {
        MapUtils.fitBounds(
          controller: _mapController!,
          coordinates: coordinates,
          padding: 100,
        );
      }
    } catch (e) {
      logError('RideTracking', 'Error fitting route in view: $e');
    }
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (_driverLocation != null) {
      _calculateRoute();
    }
    safeNotify();
  }

  // ==========================================================================
  // ROUTE REFRESH TIMER (PASSENGER ONLY)
  // ==========================================================================

  void _startRouteRefreshTimer() {
    _routeRefreshTimer?.cancel();

    logInfo(
      'RideTracking',
      '⏱️ Starting passenger route refresh - 15s interval',
    );

    _routeRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isDisposed) {
        logWarning('RideTracking', 'Provider disposed - stopping timer');
        _routeRefreshTimer?.cancel();
        return;
      }

      if (_driverLocation != null) {
        logDebug(
          'RideTracking',
          'Recalculating route from passenger perspective',
        );
        _calculateRoute();
      } else {
        logWarning(
          'RideTracking',
          'No driver location available for route calculation',
        );
      }
    });

    logSuccess('RideTracking', 'Passenger route recalculation timer started');
  }

  // ==========================================================================
  // RIDE CANCELLATION
  // ==========================================================================

  // Cancel the ride through the tracking WebSocket
  // Backend will handle broadcasting to both tracking and main WebSockets
  Future<bool> cancelRide(String reason) async {
    if (_rideId == null) {
      logError('RideTracking', 'Cannot cancel - No active ride');
      return false;
    }

    _isLoading = true;
    safeNotify();

    try {
      final userId = _userProvider.currentUser?.id;
      if (userId == null) {
        logError('RideTracking', 'Cannot cancel - No user ID');
        _isLoading = false;
        safeNotify();
        return false;
      }

      logCritical(
        'RideTracking',
        '📤 Sending cancellation via tracking WebSocket',
      );
      logInfo('RideTracking', 'Ride ID: $_rideId');
      logInfo('RideTracking', 'User ID: $userId');
      logInfo('RideTracking', 'Reason: $reason');

      // Send through tracking WebSocket
      // Backend will handle broadcasting to both tracking and main WebSockets
      await _trackingService.sendCancelRide(reason);

      logSuccess(
        'RideTracking',
        '✅ Cancellation sent - waiting for confirmation',
      );

      // Don't cleanup immediately - wait for server confirmation
      // Cleanup will happen in the onRideCancelled callback
      return true;
    } catch (e) {
      logError('RideTracking', 'Cancellation failed: $e');
      _isLoading = false;
      safeNotify();
      return false;
    }
  }

  // Disconnect from tracking WebSocket
  Future<void> disconnect() async {
    logInfo('RideTracking', '🔌 Disconnecting from tracking WebSocket');
    await _trackingService.disconnect();
    _cleanup();
  }

  // ==========================================================================
  // RESOURCE CLEANUP
  // ==========================================================================

  void _cleanup() {
    logInfo('RideTracking', 'Cleaning up ride tracking resources');

    _routeRefreshTimer?.cancel();
    _routeRefreshTimer = null;

    _mapController?.dispose();
    _mapController = null;

    _rideId = null;
    _driverId = null;
    _passengerId = null;
    _channelId = null;
    _wsToken = null;

    _driverHasArrived = false;
    _passengerIsComing = false;
    _rideHasStarted = false;

    _markers.clear();
    _polylines.clear();
    _routePoints.clear();

    _isLoading = false;
    _errorMessage = null;

    logSuccess('RideTracking', 'Cleanup completed');
  }

  @override
  void dispose() {
    logInfo('RideTracking', 'Disposing provider');

    _isDisposed = true;
    _routeRefreshTimer?.cancel();
    _mapController?.dispose();
    clearCallbacks();
    _trackingService.dispose();

    super.dispose();

    logInfo('RideTracking', 'Provider disposed');
  }
}
