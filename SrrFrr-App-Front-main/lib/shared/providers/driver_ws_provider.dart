// Driver WebSocket Provider
//
// Manages driver-side WebSocket communication for real-time ride requests,
// offer handling, and location broadcasting. Interfaces with WebSocketService
// for connection management and provides reactive state updates to UI.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:srrfrr_app_front/core/services/websocket_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';

// Represents a ride request received from a passenger
class RideRequest {
  final String rideId;
  final String passengerId;
  final String? passengerName;
  final String? passengerPhoto;
  final double? passengerRating;
  final int? passengerTotalRides;
  final Map<String, dynamic> departure;
  final Map<String, dynamic> destination;
  final double price;
  final String rideType;
  final String vehicleType;
  final int seats;
  final double distanceKm;
  final String estimatedTime;
  final DateTime receivedAt;
  bool isPending;
  DateTime? offerSentAt;

  RideRequest({
    required this.rideId,
    required this.passengerId,
    this.passengerName,
    this.passengerPhoto,
    this.passengerRating,
    this.passengerTotalRides,
    required this.departure,
    required this.destination,
    required this.price,
    required this.rideType,
    required this.vehicleType,
    required this.seats,
    required this.distanceKm,
    required this.estimatedTime,
    DateTime? receivedAt,
    this.isPending = false,
    this.offerSentAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory RideRequest.fromWsMessage(Map<String, dynamic> data) {
    try {
      final passenger = data['passenger'] as Map<String, dynamic>?;

      String? passengerName;
      if (passenger != null) {
        final firstName = passenger['firstName'] as String? ?? '';
        final lastName = passenger['lastName'] as String? ?? '';
        passengerName = '$firstName $lastName'.trim();
        if (passengerName.isEmpty) passengerName = null;
      }

      return RideRequest(
        rideId: data['rideId'] as String? ?? '',
        passengerId: passenger?['id'] as String? ?? '',
        passengerName: passengerName,
        passengerPhoto: passenger?['profilePicture'] as String?,
        passengerRating: (passenger?['rating'] as num?)?.toDouble() ?? 0.0,
        passengerTotalRides: passenger?['totalRides'] as int? ?? 0,
        departure: data['departure'] as Map<String, dynamic>? ?? {},
        destination: data['destination'] as Map<String, dynamic>? ?? {},
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        rideType: data['rideType'] as String? ?? 'standard',
        vehicleType: data['vehicleType'] as String? ?? 'auto',
        distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
        estimatedTime: data['estimatedTime'] as String? ?? '',
        seats: data['seats'] as int? ?? 1,
      );
    } catch (e) {
      logError('RideRequest', 'Failed to parse ride request: $e');
      rethrow;
    }
  }

  int get secondsSinceReceived =>
      DateTime.now().difference(receivedAt).inSeconds;

  int? get secondsRemainingForResponse {
    if (offerSentAt == null) return null;
    const timeout = Duration(seconds: 60);
    final elapsed = DateTime.now().difference(offerSentAt!);
    final remaining = timeout - elapsed;
    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }

  bool get isResponseTimeout {
    final remaining = secondsRemainingForResponse;
    return remaining != null && remaining <= 0;
  }

  bool get isExpired {
    const expiration = Duration(minutes: 2);
    return DateTime.now().difference(receivedAt) > expiration;
  }
}

// ============================================================================
// DRIVER WEBSOCKET PROVIDER
// ============================================================================

class DriverWsProvider extends DisposableProvider {
  final WebSocketService _wsService;
  final RideTrackingProvider _rideTrackingProvider;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;
  Timer? _locationUpdateTimer;
  Timer? _requestCleanupTimer;
  Timer? _pendingOfferTimer;

  String? _driverId;
  bool _isOnline = false;
  String? _errorMessage;
  double? _currentLatitude;
  double? _currentLongitude;

  final List<RideRequest> _activeRequests = [];
  RideRequest? _pendingOffer;

  // DateTime? _lastLocationBroadcastTime;
  int _messageReceivedCount = 0;
  // DateTime? _lastMessageReceivedTime;

  VoidCallback? _onRideConfirmedCallback;

  // Public getters
  String? get driverId => _driverId;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;
  List<RideRequest> get activeRequests => List.unmodifiable(_activeRequests);
  RideRequest? get pendingOffer => _pendingOffer;
  bool get hasPendingOffer => _pendingOffer != null;
  int get activeRequestCount => _activeRequests.length;
  WsConnectionStatus get connectionStatus => _wsService.status;
  Stream<WsConnectionStatus> get statusStream => _wsService.statusStream;

  DriverWsProvider(this._wsService, this._rideTrackingProvider) {
    _initialize();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  void _initialize() {
    logInfo('Init', '🚀 Initializing DriverWsProvider');

    _statusSubscription = _wsService.statusStream.listen((status) {
      logInfo('Status', 'Connection status changed: ${status.name}');

      if (status == WsConnectionStatus.connected) {
        logSuccess('Status', '✅ Driver WebSocket connected');
        _setupMessageListener();
        _verifyListenerActive();

        _messageReceivedCount = 0;
        // _lastMessageReceivedTime = null;
      } else if (status == WsConnectionStatus.error) {
        _errorMessage = 'Connection lost';
        logError('Status', '❌ Connection error');
        safeNotify();
      } else if (status == WsConnectionStatus.disconnected) {
        logWarning('Status', '🔌 Disconnected from server');
        _clearAllRequests();
      }
    });

    _setupMessageListener();
    _startRequestCleanup();

    logSuccess('Init', '✅ DriverWsProvider initialization complete');
  }

  void setOnRideConfirmedCallback(VoidCallback callback) {
    logInfo('DriverWs', '🔔 Ride confirmed callback registered');
    _onRideConfirmedCallback = callback;
  }

  void clearOnRideConfirmedCallback() {
    logInfo('DriverWs', '🔕 Ride confirmed callback cleared');
    _onRideConfirmedCallback = null;
  }

  // ==========================================================================
  // MESSAGE LISTENER
  // ==========================================================================

  void _setupMessageListener() {
    _messageSubscription?.cancel();

    logInfo('Listener', '🎧 Setting up message listener...');

    _messageSubscription = _wsService.messages.listen(
      (message) {
        _messageReceivedCount++;
        // _lastMessageReceivedTime = DateTime.now();

        logCritical(
          'Listener',
          '📨 MESSAGE RECEIVED (#$_messageReceivedCount): ${message.type.name}',
        );

        _handleMessage(message);
      },
      onError: (error, stackTrace) {
        logError('Listener', '❌ Message stream error: $error');
      },
      onDone: () {
        logWarning('Listener', '⚠️ Message stream closed');
      },
    );
  }

  void _verifyListenerActive() {
    logInfo('Verify', '🔍 Verifying message listener status...');

    final checks = <String, bool>{
      'WebSocket connected': _wsService.isConnected,
      'Message subscription active': _messageSubscription != null,
      'Status subscription active': _statusSubscription != null,
      'Driver ID set': _driverId != null,
    };

    bool allPassed = true;
    checks.forEach((check, passed) {
      final status = passed ? '✓' : '✗';
      final color = passed ? LogColors.green : LogColors.red;
      debugPrint('$color$status${LogColors.reset} $check');
      if (!passed) allPassed = false;
    });

    if (allPassed) {
      logSuccess('Verify', '✅ All listener checks passed - Ready to receive!');
    } else {
      logError(
        'Verify',
        '❌ Some listener checks failed - Messages may not be received',
      );
    }
  }

  // ==========================================================================
  // CONNECTION MANAGEMENT
  // ==========================================================================

  Future<void> connect(String driverId) async {
    if (_wsService.isConnected) {
      logWarning('Connect', 'Already connected to WebSocket');
      return;
    }

    _driverId = driverId;
    _errorMessage = null;

    if (driverId.isEmpty) {
      logError('Connect', 'Driver ID is required for connection');
      _errorMessage = 'Driver ID required';
      safeNotify();
      return;
    }

    logInfo('WebSocket', '🔌 Connecting driver: $driverId');
    await _wsService.connect('/ws/driver');

    await Future.delayed(const Duration(milliseconds: 500));

    if (_wsService.isConnected) {
      logSuccess('WebSocket', '✅ Connection established and stable');
      _setupMessageListener();
    }
  }

  // ==========================================================================
  // MESSAGE ROUTING
  // ==========================================================================

  void _handleMessage(WsMessage message) {
    if (isDisposed) {
      logWarning('Handler', 'Provider disposed, ignoring message');
      return;
    }

    logInfo('Handler', '✅ Routing message: ${message.type.name}');

    switch (message.type) {
      case WsMessageType.rideRequest:
        _handleRideRequest(message.data);
        break;

      case WsMessageType.rideConfirmed:
        _handleRideConfirmed(message.data);
        break;

      case WsMessageType.cancelRide:
        _handleRideCancelled(message.data);
        break;

      case WsMessageType.offerSent:
        _handleOfferSent(message.data);
        break;

      case WsMessageType.offerRejected:
        _handleOfferRejected(message.data);
        break;

      case WsMessageType.error:
        _handleError(message.data);
        break;

      case WsMessageType.rideH3Info:
        _handleH3Info(message.data);
        break;

      case WsMessageType.driverRejected:
        _handleDriverRejected(message.data);
        break;

      case WsMessageType.counterOfferSent:
        _handleCounterOfferSent(message.data);
        break;

      case WsMessageType.rideRejected:
        _handleRideRejected(message.data);
        break;

      default:
        logWarning('Handler', 'Unhandled message type: ${message.type.name}');
    }
  }

  // ==========================================================================
  // MESSAGE HANDLERS
  // ==========================================================================

  void _handleRideRequest(Map<String, dynamic> data) {
    try {
      final request = RideRequest.fromWsMessage(data);

      if (_pendingOffer?.rideId == request.rideId) {
        logInfo(
          'RideRequest',
          'Ignoring request - already have pending offer: ${request.rideId}',
        );
        return;
      }

      final existingIndex = _activeRequests.indexWhere(
        (r) => r.rideId == request.rideId,
      );

      if (existingIndex >= 0) {
        logInfo(
          'RideRequest',
          '🔄 Updating existing request ${request.rideId}: price ${_activeRequests[existingIndex].price} → ${request.price} DH',
        );

        final existingRequest = _activeRequests[existingIndex];

        _activeRequests[existingIndex] = RideRequest(
          rideId: existingRequest.rideId,
          passengerId: existingRequest.passengerId,
          passengerName: existingRequest.passengerName,
          passengerPhoto: existingRequest.passengerPhoto,
          passengerRating: existingRequest.passengerRating,
          passengerTotalRides: existingRequest.passengerTotalRides,
          departure: existingRequest.departure,
          destination: existingRequest.destination,
          price: request.price,
          rideType: existingRequest.rideType,
          vehicleType: existingRequest.vehicleType,
          seats: existingRequest.seats,
          distanceKm: existingRequest.distanceKm,
          estimatedTime: existingRequest.estimatedTime,
          receivedAt: existingRequest.receivedAt,
          isPending: existingRequest.isPending,
          offerSentAt: existingRequest.offerSentAt,
        );

        safeNotify();

        logSuccess(
          'RideRequest',
          '✅ Price updated for existing card: ${request.rideId}',
        );
        return;
      }

      _activeRequests.add(request);
      safeNotify();

      logSuccess('RideRequest', '✅ New ride request added: ${request.rideId}');
      logInfo(
        'RideRequest',
        '📍 From: ${request.departure['address'] ?? 'Unknown'} → ${request.destination['address'] ?? 'Unknown'}',
      );
      logInfo('RideRequest', '💰 Price: ${request.price} DH');
      logInfo(
        'RideRequest',
        '👤 Passenger: ${request.passengerName ?? 'Unknown'}',
      );
      logInfo(
        'RideRequest',
        '✅ Total active requests: ${_activeRequests.length}',
      );
    } catch (e, stackTrace) {
      logError('RideRequest', 'Failed to process ride request: $e');
      logError('RideRequest', 'Stack trace: $stackTrace');
    }
  }

  void _handleRideConfirmed(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    logSuccess('RideConfirmed', '✅ Ride confirmed: $rideId');

    if (rideId != null) {
      _activeRequests.removeWhere((r) => r.rideId == rideId);
      if (_pendingOffer?.rideId == rideId) {
        _clearPendingOffer();
      }

      try {
        LatLng? driverLocation;
        if (_currentLatitude != null && _currentLongitude != null) {
          driverLocation = LatLng(_currentLatitude!, _currentLongitude!);
          logSuccess(
            'DriverWs',
            '📍 Using current GPS location: $_currentLatitude, $_currentLongitude',
          );
        } else {
          logWarning('DriverWs', '⚠️ No GPS location available');
        }

        _rideTrackingProvider.initializeRide(
          data,
          'driver',
          initialDriverLocation: driverLocation,
        );

        logSuccess('DriverWs', '✅ Ride tracking initialized for driver mode');
        logInfo(
          'DriverWs',
          'Passenger: ${data['passenger']?['firstName']} ${data['passenger']?['lastName']}',
        );
        logInfo('DriverWs', 'Price: ${data['price']} DH');

        safeNotify();

        if (_onRideConfirmedCallback != null) {
          logSuccess('DriverWs', '🚀 Triggering ride confirmed callback...');
          _onRideConfirmedCallback!();
        } else {
          logWarning(
            'DriverWs',
            '⚠️ No callback set! Navigation will not occur.',
          );
        }
      } catch (e, stackTrace) {
        logError('DriverWs', 'Error initializing ride tracking: $e');
        logError('DriverWs', 'Stack trace: $stackTrace');
      }

      safeNotify();
    }
  }

  // Handle ride cancellation from passenger
  void _handleRideCancelled(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final userId = data['userId'] as String?;

    logWarning('RideCancelled', '🚫 Ride cancelled: $rideId by user: $userId');

    if (rideId == null) return;

    _activeRequests.removeWhere((r) => r.rideId == rideId);

    if (_pendingOffer?.rideId == rideId) {
      _clearPendingOffer();
    }

    safeNotify();
    logSuccess('RideCancelled', '✅ Ride removed from driver queue');
  }

  void _handleOfferSent(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    logSuccess('OfferSent', '✅ Offer sent confirmation for: $rideId');

    if (rideId != null) {
      final requestIndex = _activeRequests.indexWhere(
        (r) => r.rideId == rideId,
      );

      if (requestIndex >= 0) {
        final request = _activeRequests[requestIndex];
        request.isPending = true;
        request.offerSentAt = DateTime.now();
        _pendingOffer = request;
        _activeRequests.removeAt(requestIndex);
        _startPendingOfferTimeout();
        safeNotify();

        logInfo('OfferSent', '✅ Request moved to pending: $rideId');
        logInfo('OfferSent', '✅ Started 60-second response timer');
      }
    }
  }

  void _handleOfferRejected(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final message = data['message'] as String?;

    logWarning('OfferRejected', '❌ Passenger rejected offer for: $rideId');
    logInfo('OfferRejected', 'Message: ${message ?? "No message"}');

    if (rideId != null) {
      // Remove from pending offer if it matches
      if (_pendingOffer?.rideId == rideId) {
        logInfo('OfferRejected', '🗑️ Clearing pending offer');
        _clearPendingOffer();
      }

      final initialLength = _activeRequests.length;
      _activeRequests.removeWhere((r) => r.rideId == rideId);
      final removedCount = initialLength - _activeRequests.length;
      if (removedCount > 0) {
        logInfo('OfferRejected', '🗑️ Removed from active requests');
      }

      safeNotify();
      logSuccess('OfferRejected', '✅ Offer cleaned up from driver UI');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    final message = data['message'] as String? ?? 'Unknown error';
    logError('Error', 'Backend error: $message');

    if (message.contains('already accepted')) {
      logWarning('Error', 'Ride taken by another driver');
      _clearPendingOffer();
      _clearAllRequests();
      _errorMessage = 'Ride was accepted by another driver';
      logInfo(
        '[INFO] Ride taken - searching for new requests',
        'cleared all requests',
      );
    } else if (message.contains('not found') ||
        message.contains('not available')) {
      logWarning('Error', 'Ride no longer available');
      _clearPendingOffer();
      _activeRequests.removeWhere((r) => r.rideId == data['rideId'] as String?);
      _errorMessage = 'Ride no longer available';
      logInfo(
        '[INFO] Ride no longer available',
        'removed from active requests',
      );
    } else if (message.contains('Missing required fields')) {
      logError('Error', 'Invalid request format');
      _errorMessage = 'Invalid request sent to server';
    } else if (message.contains('has not made an offer')) {
      logWarning('Error', 'Driver offer mismatch');
      _clearPendingOffer();
      _errorMessage = 'Offer processing error';
    } else {
      _errorMessage = message;
    }

    safeNotify();
  }

  void _handleH3Info(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final centerH3 = data['centerH3'];
    final hexagons = data['hexagons'];

    logInfo('H3Info', 'Ride $rideId - Center: $centerH3, Hexagons: $hexagons');
  }

  void _handleDriverRejected(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    logWarning('DriverRejected', 'Passenger rejected offer for: $rideId');

    if (rideId != null && _pendingOffer?.rideId == rideId) {
      _clearPendingOffer();
      logInfo('DriverRejected', 'Cleared pending offer after rejection');
    }
  }

  void _handleCounterOfferSent(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final newPrice = data['newPrice'];
    logSuccess('CounterSent', '✅ Counter-offer sent for $rideId: $newPrice DH');

    if (rideId != null) {
      final requestIndex = _activeRequests.indexWhere(
        (r) => r.rideId == rideId,
      );

      if (requestIndex >= 0) {
        final request = _activeRequests[requestIndex];
        request.isPending = true;
        request.offerSentAt = DateTime.now();
        _pendingOffer = request;
        _activeRequests.removeAt(requestIndex);
        _startPendingOfferTimeout();
        safeNotify();

        logInfo('CounterSent', '✅ Counter-offer moved to pending: $rideId');
        logInfo('CounterSent', '✅ Started 60-second response timer');
      }
    }
  }

  void _handleRideRejected(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final message = data['message'] as String?;

    if (rideId != null) {
      logInfo('RideRejected', '✅ Confirmed rejection of ride: $rideId');

      // Remove from active requests
      _activeRequests.removeWhere((r) => r.rideId == rideId);

      // Clear pending offer if it matches
      if (_pendingOffer?.rideId == rideId) {
        _clearPendingOffer();
      }

      safeNotify();

      logSuccess('RideRejected', message ?? '✅ Ride removed from your list');
    }
  }

  void updateLocation(double latitude, double longitude) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;

    logDebug('Location', 'Updated position: ($latitude, $longitude)');

    if (_isOnline) {
      _broadcastLocation();
    } else {
      logDebug('Location', 'Driver offline, not broadcasting');
    }
  }

  void _startLocationBroadcasting() {
    if (!_wsService.isConnected || _driverId == null) {
      logError('Location', 'Cannot start broadcasting - not connected');
      return;
    }

    _locationUpdateTimer?.cancel();

    logInfo('Location', '🌍 Starting location broadcasting');

    _broadcastLocation();

    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _broadcastLocation(),
    );

    logInfo(
      'Location',
      '📍 Broadcasting every 15 seconds for real-time matching',
    );
  }

  void _broadcastLocation() {
    if (!_wsService.isConnected || _driverId == null || !_isOnline) {
      logDebug('Location', 'Skipping broadcast (offline or disconnected)');
      return;
    }

    if (_currentLatitude == null || _currentLongitude == null) {
      logWarning('Location', '⚠️ No GPS location available to broadcast');
      return;
    }

    try {
      // _lastLocationBroadcastTime = DateTime.now();

      final message = {
        'type': 'driverLocation',
        'driverId': _driverId,
        'latitude': _currentLatitude,
        'longitude': _currentLongitude,
      };

      logInfo('Location', '📍 Broadcasting location to backend...');
      _wsService.sendMessage(message);
      logSuccess('Location', '✅ Location broadcast sent');
    } catch (e) {
      logError('Location', 'Failed to broadcast location: $e');
    }
  }

  void _stopLocationBroadcasting() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    logInfo('Location', '🛑 Location broadcasting stopped');
  }

  // ==========================================================================
  // DRIVER ACTIONS
  // ==========================================================================

  Future<bool> sendCounterOffer(String rideId, double counterPrice) async {
    if (!_wsService.isConnected || _driverId == null) {
      logError('CounterOffer', 'Cannot send - not connected or no driver ID');
      return false;
    }

    if (counterPrice <= 0) {
      logError('CounterOffer', 'Invalid counter price: $counterPrice');
      return false;
    }

    try {
      final request = _activeRequests.firstWhere(
        (r) => r.rideId == rideId,
        orElse: () => throw Exception('Ride request not found'),
      );

      logInfo('CounterOffer', '📤 Sending counter-offer...');
      logDebug('CounterOffer', 'Ride ID: $rideId');
      logDebug('CounterOffer', 'Driver ID: $_driverId');
      logDebug('CounterOffer', 'Original Price: ${request.price} DH');
      logDebug('CounterOffer', 'Counter Price: $counterPrice DH');

      _wsService.sendMessage({
        'type': 'counterOffer',
        'rideId': rideId,
        'driverId': _driverId,
        'newPrice': counterPrice,
      });

      logSuccess('CounterOffer', '✅ Counter-offer sent: $counterPrice DH');

      return true;
    } catch (e) {
      logError('CounterOffer', 'Failed to send counter-offer: $e');
      return false;
    }
  }

  Future<bool> acceptRide(String rideId) async {
    if (hasPendingOffer) {
      logWarning('AcceptRide', 'Cannot accept - already have pending offer');
      return false;
    }
    if (!_wsService.isConnected || _driverId == null) {
      logError('AcceptRide', 'Cannot accept - not connected');
      return false;
    }

    try {
      _wsService.sendMessage({
        'type': 'acceptOffer',
        'rideId': rideId,
        'driverId': _driverId,
      });

      logSuccess('AcceptRide', '✅ Sent acceptance for: $rideId');
      return true;
    } catch (e) {
      logError('AcceptRide', 'Failed to accept: $e');
      return false;
    }
  }

  Future<bool> declineRide(String rideId) async {
    if (!_wsService.isConnected || _driverId == null) {
      logError('DeclineRide', 'Cannot decline - not connected');
      _activeRequests.removeWhere((r) => r.rideId == rideId);
      safeNotify();
      return false;
    }

    try {
      // Remove from UI first
      _activeRequests.removeWhere((r) => r.rideId == rideId);
      safeNotify();

      // Send rejectRide event
      _wsService.sendMessage({
        'type': 'rejectRide',
        'rideId': rideId,
        'driverId': _driverId,
      });

      logSuccess('DeclineRide', '✅ Sent rejectRide for: $rideId');
      return true;
    } catch (e) {
      logError('DeclineRide', 'Failed to reject ride: $e');
      return false;
    }
  }

  Future<bool> cancelPendingOffer() async {
    if (_pendingOffer == null) {
      logWarning('CancelOffer', 'No pending offer to cancel');
      return false;
    }

    final rideId = _pendingOffer!.rideId;

    try {
      if (_wsService.isConnected && _driverId != null) {
        _wsService.sendMessage({
          'type': 'rejectRide',
          'rideId': rideId,
          'driverId': _driverId,
        });

        logSuccess(
          'CancelOffer',
          '✅ Sent rejectRide for cancelled offer: $rideId',
        );
      }

      _clearPendingOffer();
      return true;
    } catch (e) {
      logError('CancelOffer', 'Failed to cancel: $e');
      _clearPendingOffer();
      return false;
    }
  }

  Future<bool> cancelRide(String rideId, String reason) async {
    if (!_wsService.isConnected || _driverId == null) {
      logError('CancelRide', '❌ Cannot cancel - not connected');
      return false;
    }

    try {
      _wsService.sendMessage({
        'type': 'cancelRide',
        'rideId': rideId,
        'userId': _driverId,
      });

      logSuccess('CancelRide', '✅ Cancellation sent: $rideId');

      _activeRequests.removeWhere((r) => r.rideId == rideId);
      if (_pendingOffer?.rideId == rideId) {
        _clearPendingOffer();
      }

      safeNotify();
      return true;
    } catch (e) {
      logError('CancelRide', '❌ Failed to cancel: $e');
      return false;
    }
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;

    if (online) {
      logInfo('Status', '🟢 Driver going ONLINE');
      _startLocationBroadcasting();
    } else {
      logInfo('Status', '🔴 Driver going OFFLINE');
      _stopLocationBroadcasting();
      _clearAllRequests();
    }

    safeNotify();
  }

  void _startPendingOfferTimeout() {
    _pendingOfferTimer?.cancel();

    _pendingOfferTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pendingOffer == null) {
        timer.cancel();
        return;
      }

      if (_pendingOffer!.isResponseTimeout) {
        logWarning('Timeout', '⏰ Response timeout for pending offer');
        _clearPendingOffer();
        timer.cancel();
      } else {
        safeNotify();
      }
    });
  }

  void _clearPendingOffer() {
    if (_pendingOffer != null) {
      _activeRequests.removeWhere((r) => r.rideId == _pendingOffer!.rideId);
      _pendingOffer = null;
      _pendingOfferTimer?.cancel();
      safeNotify();
      logInfo('PendingOffer', '✅ Cleared pending offer');
    }
  }

  void _startRequestCleanup() {
    _requestCleanupTimer?.cancel();

    _requestCleanupTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (isDisposed) return;

      final before = _activeRequests.length;
      _activeRequests.removeWhere((r) => r.isExpired);
      final removed = before - _activeRequests.length;

      if (removed > 0) {
        logInfo('Cleanup', 'Removed $removed expired ride requests');
        safeNotify();
      }
    });
  }

  void _clearAllRequests() {
    _activeRequests.clear();
    _clearPendingOffer();
    logInfo('Clear', 'Cleared all active requests');
    safeNotify();
  }

  @override
  void dispose() {
    logInfo('Dispose', '🗑️ Disposing DriverWsProvider');

    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _requestCleanupTimer?.cancel();
    _pendingOfferTimer?.cancel();
    _onRideConfirmedCallback = null;

    super.dispose();

    logSuccess('Dispose', '✅ DriverWsProvider disposed');
  }
}
