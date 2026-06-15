// Ride Tracking Service - Independent WebSocket Connection
//
// Handles dedicated WebSocket connection for ride tracking:
// - Separate from main driver/passenger WebSocket
// - Manages /ws/tracking/{rideId} connection
// - Driver location broadcasting during ride
// - Ride event handling (arrival, start, finish, cancel)
// - Auto-disconnect on ride completion/cancellation

library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' show sin, pi, cos, sqrt, atan2;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

// Callback types for ride events
typedef RideEventCallback = void Function(Map<String, dynamic> data);
typedef LocationUpdateCallback =
    void Function(LatLng location, Map<String, dynamic> data);

class RideTrackingService {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;

  // Connection state
  String? _rideId;
  String? _driverId;
  String? _passengerId;
  String? _userMode; // 'driver' or 'passenger'
  bool _isConnected = false;

  // Location tracking (driver only)
  Timer? _locationTimer;
  LatLng? _lastSentLocation;
  static const _minDistanceMeters = 10.0;
  static const _locationIntervalSeconds = 10;

  // Reconnection
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Callbacks
  LocationUpdateCallback? _onLocationUpdate;
  RideEventCallback? _onDriverArrived;
  RideEventCallback? _onPassengerComing;
  RideEventCallback? _onRideStarted;
  RideEventCallback? _onRideCompleted;
  RideEventCallback? _onApproachingDestination;
  RideEventCallback? _onRideCancelled;
  RideEventCallback? _onError;

  // Getters
  bool get isConnected => _isConnected;
  String? get rideId => _rideId;
  bool get isDriverMode => _userMode == 'driver';

  // ✅ No constructor dependencies
  RideTrackingService();

  // ==========================================================================
  // CONNECTION MANAGEMENT
  // ==========================================================================

  // Build WebSocket URL for ride tracking
  String _getWsUrl(String rideId) {
    final apiUrl = dotenv.env['API_BASE_URL'];
    if (apiUrl == null) {
      throw Exception('API_BASE_URL not found in environment');
    }

    final uri = Uri.parse(apiUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final path = uri.path;

    final wsUrl =
        '$wsScheme://${uri.host}:${uri.port}${path}/ws/tracking/$rideId';

    logInfo('RideTrackingSvc', 'WebSocket URL: $wsUrl');
    return wsUrl;
  }

  // Connect to ride tracking WebSocket
  Future<void> connect({
    required String rideId,
    required String userMode,
    String? driverId,
    String? passengerId,
  }) async {
    if (_isConnected && _rideId == rideId) {
      logWarning('RideTrackingSvc', 'Already connected to ride: $rideId');
      return;
    }

    // Disconnect from previous ride if any
    if (_isConnected && _rideId != rideId) {
      logInfo('RideTrackingSvc', 'Disconnecting from previous ride: $_rideId');
      await disconnect();
    }

    _rideId = rideId;
    _userMode = userMode;
    _driverId = driverId;
    _passengerId = passengerId;

    final wsUrl = _getWsUrl(rideId);

    logInfo('RideTrackingSvc', '========================================');
    logInfo('RideTrackingSvc', '🔌 Connecting to ride tracking WebSocket');
    logInfo('RideTrackingSvc', 'Ride ID: $rideId');
    logInfo('RideTrackingSvc', 'User Mode: $userMode');
    logInfo('RideTrackingSvc', 'URL: $wsUrl');
    logInfo('RideTrackingSvc', '========================================');

    try {
      // Create dedicated WebSocket channel
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection to be ready
      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;

      logSuccess('RideTrackingSvc', '✅ WebSocket connection established');

      // Setup message listener
      _setupMessageListener();

      logSuccess('RideTrackingSvc', '✅ Message listener active');

      // If driver, start location broadcasting
      if (isDriverMode) {
        logCritical('RideTrackingSvc', '🚗 Driver mode detected');
        await _startLocationBroadcasting();
      } else {
        logInfo('RideTrackingSvc', '👤 Passenger mode - waiting for updates');
      }
    } catch (e) {
      logError('RideTrackingSvc', '❌ Connection failed: $e');
      _isConnected = false;
      _onError?.call({'message': 'Connection failed: $e'});

      // Schedule reconnection
      _scheduleReconnect();

      rethrow;
    }
  }

  // Disconnect from ride tracking
  Future<void> disconnect() async {
    if (!_isConnected && _channel == null) {
      logInfo('RideTrackingSvc', 'Already disconnected');
      return;
    }

    logInfo('RideTrackingSvc', '========================================');
    logInfo('RideTrackingSvc', '🔌 Disconnecting from ride tracking');
    logInfo('RideTrackingSvc', 'Ride ID: $_rideId');
    logInfo('RideTrackingSvc', '========================================');

    // Stop location broadcasting
    _stopLocationBroadcasting();

    // Cancel reconnection attempts
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Cancel message subscription
    _messageSubscription?.cancel();
    _messageSubscription = null;

    // Close WebSocket channel
    try {
      await _channel?.sink.close();
    } catch (e) {
      logError('RideTrackingSvc', 'Error closing channel: $e');
    }

    _channel = null;

    // Clear state
    _isConnected = false;
    _rideId = null;
    _driverId = null;
    _passengerId = null;
    _userMode = null;
    _lastSentLocation = null;
    _reconnectAttempts = 0;

    logSuccess('RideTrackingSvc', '✅ Disconnected successfully');
  }

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logError(
        'RideTrackingSvc',
        '❌ Max reconnect attempts reached ($_maxReconnectAttempts)',
      );
      _onError?.call({
        'message': 'Connection failed after $_maxReconnectAttempts attempts',
      });
      return;
    }

    if (_rideId == null) {
      logWarning('RideTrackingSvc', '⚠️ No ride ID - cannot reconnect');
      return;
    }

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;

    logInfo(
      'RideTrackingSvc',
      '🔄 Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_rideId != null && _userMode != null) {
        connect(
          rideId: _rideId!,
          userMode: _userMode!,
          driverId: _driverId,
          passengerId: _passengerId,
        );
      }
    });
  }

  // ==========================================================================
  // MESSAGE HANDLING
  // ==========================================================================

  // Setup message listener for incoming WebSocket messages
  void _setupMessageListener() {
    _messageSubscription?.cancel();

    logInfo('RideTrackingSvc', '🎧 Setting up message listener');

    _messageSubscription = _channel!.stream.listen(
      (data) {
        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;
          final messageType = jsonData['type'] as String?;

          logCritical('RideTrackingSvc', '📨 Message received: $messageType');
          logDebug('RideTrackingSvc', 'Data: $jsonData');

          _routeMessage(messageType, jsonData);
        } catch (e) {
          logError('RideTrackingSvc', '❌ Parse error: $e');
          logError('RideTrackingSvc', 'Raw data: $data');
        }
      },
      onError: (error) {
        logError('RideTrackingSvc', '❌ Stream error: $error');
        _isConnected = false;
        _onError?.call({'message': 'Stream error: $error'});
        _scheduleReconnect();
      },
      onDone: () {
        logWarning('RideTrackingSvc', '⚠️ Stream closed');
        _isConnected = false;
        _scheduleReconnect();
      },
      cancelOnError: false,
    );

    logSuccess('RideTrackingSvc', '✅ Message listener ready');
  }

  // Route incoming messages to appropriate handlers
  void _routeMessage(String? type, Map<String, dynamic> data) {
    if (type == null) {
      logWarning('RideTrackingSvc', '⚠️ Message without type field');
      return;
    }

    switch (type) {
      case 'connected':
        logSuccess('RideTrackingSvc', '✅ Connection confirmed by server');
        break;

      case 'driverLocation':
      case 'driverLocationUpdate':
        _handleLocationUpdate(data);
        break;

      case 'driverArrived':
        logSuccess('RideTrackingSvc', '🚗 Driver arrived at pickup');
        _onDriverArrived?.call(data);
        break;

      case 'passengerComing':
        logSuccess('RideTrackingSvc', '👤 Passenger coming to pickup');
        _onPassengerComing?.call(data);
        break;

      case 'rideStarted':
        logSuccess(
          'RideTrackingSvc',
          '🏁 Ride started - heading to destination',
        );
        _onRideStarted?.call(data);
        break;

      case 'rideCompleted':
        logSuccess('RideTrackingSvc', '🏁 Ride completed successfully');
        _onRideCompleted?.call(data);

        // Auto-disconnect after completion
        Future.delayed(const Duration(milliseconds: 500), () {
          disconnect();
        });
        break;

      case 'approachingDestination':
        final distance = data['distance'] as double?;
        logWarning(
          'RideTrackingSvc',
          '📍 Approaching destination - Distance: ${distance?.toStringAsFixed(2)} km',
        );
        _onApproachingDestination?.call(data);
        break;

      case 'cancelRide':
        logWarning('RideTrackingSvc', '❌ Ride cancelled');
        _onRideCancelled?.call(data);

        // Auto-disconnect after cancellation
        Future.delayed(const Duration(milliseconds: 500), () {
          disconnect();
        });
        break;

      case 'error':
        final errorMsg = data['message'] as String?;
        logError('RideTrackingSvc', '❌ Server error: $errorMsg');
        _onError?.call(data);
        break;

      default:
        logWarning('RideTrackingSvc', '⚠️ Unknown message type: $type');
    }
  }

  // Handle driver location update messages
  void _handleLocationUpdate(Map<String, dynamic> data) {
    final lat = data['latitude'] as double?;
    final lng = data['longitude'] as double?;

    if (lat == null || lng == null) {
      logError(
        'RideTrackingSvc',
        '❌ Invalid location data - missing coordinates',
      );
      return;
    }

    final location = LatLng(lat, lng);

    logSuccess(
      'RideTrackingSvc',
      '📍 Driver location: (${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)})',
    );

    // Extract distance info if available
    final distanceToPickup = data['distanceToPickup'] as double?;
    final distanceToDestination = data['distanceToDestination'] as double?;

    if (distanceToPickup != null) {
      logInfo(
        'RideTrackingSvc',
        '📏 Distance to pickup: ${distanceToPickup.toStringAsFixed(2)} km',
      );
    }

    if (distanceToDestination != null) {
      logInfo(
        'RideTrackingSvc',
        '📏 Distance to destination: ${distanceToDestination.toStringAsFixed(2)} km',
      );
    }

    _onLocationUpdate?.call(location, data);
  }

  // ==========================================================================
  // LOCATION BROADCASTING (DRIVER ONLY)
  // ==========================================================================

  // Start periodic location broadcasting for driver
  Future<void> _startLocationBroadcasting() async {
    if (!isDriverMode) {
      logWarning('RideTrackingSvc', '⚠️ Not driver mode - no broadcasting');
      return;
    }

    logCritical('RideTrackingSvc', '🚨 Starting driver location broadcasting');

    // Send initial location immediately
    await _broadcastCurrentLocation(forceFirstSend: true);

    // Start periodic updates
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      Duration(seconds: _locationIntervalSeconds),
      (_) => _broadcastCurrentLocation(),
    );

    logSuccess(
      'RideTrackingSvc',
      '✅ Broadcasting every $_locationIntervalSeconds seconds',
    );
  }

  // Stop location broadcasting
  void _stopLocationBroadcasting() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _lastSentLocation = null;
    logInfo('RideTrackingSvc', '🛑 Location broadcasting stopped');
  }

  // Broadcast current GPS location
  Future<void> _broadcastCurrentLocation({bool forceFirstSend = false}) async {
    if (!_isConnected || _rideId == null || _driverId == null) {
      logWarning('RideTrackingSvc', '⚠️ Cannot broadcast - not ready');
      return;
    }

    try {
      logInfo('RideTrackingSvc', '🛰️ Getting GPS position...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      final currentLocation = LatLng(position.latitude, position.longitude);

      // Check if we should send based on distance threshold
      bool shouldSend = forceFirstSend;

      if (!forceFirstSend && _lastSentLocation != null) {
        final distance = _calculateDistance(
          _lastSentLocation!,
          currentLocation,
        );
        final distanceMeters = distance * 1000;

        logDebug(
          'RideTrackingSvc',
          '📏 Moved: ${distanceMeters.toStringAsFixed(1)}m from last location',
        );

        shouldSend = distanceMeters >= _minDistanceMeters;

        if (!shouldSend) {
          logDebug(
            'RideTrackingSvc',
            '⏭️ Movement < ${_minDistanceMeters}m - skipping update',
          );
          return;
        }
      } else if (_lastSentLocation == null) {
        logCritical('RideTrackingSvc', '🎯 FIRST LOCATION - MUST SEND');
        shouldSend = true;
      }

      if (shouldSend) {
        await _sendLocationUpdate(currentLocation);
        _lastSentLocation = currentLocation;
      }
    } catch (e) {
      logError('RideTrackingSvc', '❌ Location broadcast failed: $e');

      if (e.toString().contains('PERMISSION_DENIED')) {
        _onError?.call({'message': 'GPS permission denied'});
      } else if (e.toString().contains('TimeoutException')) {
        _onError?.call({'message': 'GPS signal weak or timeout'});
      } else {
        _onError?.call({'message': 'Location error: $e'});
      }
    }
  }

  // Send location update via WebSocket
  Future<void> _sendLocationUpdate(LatLng location) async {
    final message = {
      'type': 'driverLocationUpdate',
      'rideId': _rideId,
      'driverId': _driverId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };

    logCritical('RideTrackingSvc', '📤 SENDING LOCATION UPDATE');
    logDebug(
      'RideTrackingSvc',
      'Lat: ${location.latitude}, Lng: ${location.longitude}',
    );

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);

      logSuccess('RideTrackingSvc', '✅ Location sent via WebSocket');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send location: $e');
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(LatLng from, LatLng to) {
    const earthRadius = 6371.0; // km

    final lat1 = from.latitude * pi / 180;
    final lon1 = from.longitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final lon2 = to.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // ==========================================================================
  // RIDE EVENTS (SEND TO BACKEND)
  // ==========================================================================

  // Driver confirms arrival at pickup location
  Future<void> sendDriverArrived(LatLng location) async {
    if (!_isConnected || _driverId == null) {
      logError('RideTrackingSvc', '❌ Cannot send - not connected');
      return;
    }

    logInfo('RideTrackingSvc', '📤 Sending driver arrived event');

    final message = {
      'type': 'driverArrived',
      'driverId': _driverId,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      logSuccess('RideTrackingSvc', '✅ Driver arrived event sent');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send driver arrived: $e');
    }
  }

  // Passenger notifies driver they're coming
  Future<void> sendPassengerComing({String? customMessage}) async {
    if (!_isConnected || _passengerId == null) {
      logError('RideTrackingSvc', '❌ Cannot send - not connected');
      return;
    }

    logInfo('RideTrackingSvc', '📤 Sending passenger coming event');

    final message = {
      'type': 'passengerComing',
      'passengerId': _passengerId,
      if (customMessage != null) 'message': customMessage,
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      logSuccess('RideTrackingSvc', '✅ Passenger coming event sent');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send passenger coming: $e');
    }
  }

  // Driver starts the ride
  Future<void> sendStartRide() async {
    if (!_isConnected || _driverId == null) {
      logError('RideTrackingSvc', '❌ Cannot send - not connected');
      return;
    }

    logInfo('RideTrackingSvc', '📤 Sending start ride event');

    final message = {'type': 'startRide', 'driverId': _driverId};

    try {
      _channel!.sink.add(jsonEncode(message));
      logSuccess('RideTrackingSvc', '✅ Start ride event sent');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send start ride: $e');
    }
  }

  // Driver finishes the ride
  Future<void> sendFinishRide() async {
    if (!_isConnected || _driverId == null) {
      logError('RideTrackingSvc', '❌ Cannot send - not connected');
      return;
    }

    logInfo('RideTrackingSvc', '📤 Sending finish ride event');

    final message = {'type': 'finishRide', 'driverId': _driverId};

    try {
      _channel!.sink.add(jsonEncode(message));
      logSuccess('RideTrackingSvc', '✅ Finish ride event sent');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send finish ride: $e');
    }
  }

  // Cancel the ride
  Future<void> sendCancelRide(String reason) async {
    if (!_isConnected) {
      logError('RideTrackingSvc', '❌ Cannot send - not connected');
      return;
    }

    final userId = isDriverMode ? _driverId : _passengerId;

    logInfo('RideTrackingSvc', '📤 Sending cancel ride event');

    final message = {
      'type': 'cancelRide',
      'rideId': _rideId,
      'userId': userId,
      'reason': reason,
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      logSuccess('RideTrackingSvc', '✅ Cancel ride event sent');
    } catch (e) {
      logError('RideTrackingSvc', '❌ Failed to send cancel ride: $e');
    }
  }

  // ==========================================================================
  // CALLBACK REGISTRATION
  // ==========================================================================

  void setOnLocationUpdate(LocationUpdateCallback callback) {
    _onLocationUpdate = callback;
  }

  void setOnDriverArrived(RideEventCallback callback) {
    _onDriverArrived = callback;
  }

  void setOnPassengerComing(RideEventCallback callback) {
    _onPassengerComing = callback;
  }

  void setOnRideStarted(RideEventCallback callback) {
    _onRideStarted = callback;
  }

  void setOnRideCompleted(RideEventCallback callback) {
    _onRideCompleted = callback;
  }

  void setOnApproachingDestination(RideEventCallback callback) {
    _onApproachingDestination = callback;
  }

  void setOnRideCancelled(RideEventCallback callback) {
    _onRideCancelled = callback;
  }

  void setOnError(RideEventCallback callback) {
    _onError = callback;
  }

  void clearCallbacks() {
    _onLocationUpdate = null;
    _onDriverArrived = null;
    _onPassengerComing = null;
    _onRideStarted = null;
    _onRideCompleted = null;
    _onApproachingDestination = null;
    _onRideCancelled = null;
    _onError = null;
  }

  // ==========================================================================
  // DISPOSAL
  // ==========================================================================

  void dispose() {
    logInfo('RideTrackingSvc', '🗑️ Disposing service');

    _stopLocationBroadcasting();
    _reconnectTimer?.cancel();
    _messageSubscription?.cancel();
    clearCallbacks();

    disconnect();

    logSuccess('RideTrackingSvc', '✅ Service disposed');
  }
}
