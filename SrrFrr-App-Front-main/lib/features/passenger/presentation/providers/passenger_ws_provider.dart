// Passenger WebSocket Provider
//
// Manages passenger-side WebSocket communication for ride requests,
// driver offers, and ride status updates. Provides reactive state management
// for the passenger journey from request creation through driver selection
// and price negotiation.
library;

import 'dart:async';
import 'package:srrfrr_app_front/core/services/websocket_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/features/passenger/data/models/driver_offer.dart';

// ============================================================================
// RIDE REQUEST STATUS ENUM
// ============================================================================

enum RideRequestStatus {
  idle,
  requesting,
  waiting,
  negotiating,
  accepted,
  cancelled,
  error,
}


// ============================================================================
// PASSENGER WEBSOCKET PROVIDER
// ============================================================================

class PassengerWsProvider extends DisposableProvider {
  final WebSocketService _wsService;
  final RideTrackingProvider _rideTrackingProvider;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;

  String? _currentRideId;
  double? _currentPrice;
  RideRequestStatus _status = RideRequestStatus.idle;
  String? _errorMessage;

  final List<DriverOffer> _driverOffers = [];
  DriverOffer? _pendingCounterOffer;

  Function(Map<String, dynamic>)? _onRideConfirmed;

  // Public getters
  String? get currentRideId => _currentRideId;
  double? get currentPrice => _currentPrice;
  RideRequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<DriverOffer> get driverOffers => List.unmodifiable(_driverOffers);
  DriverOffer? get pendingCounterOffer => _pendingCounterOffer;
  bool get hasActiveRequest => _currentRideId != null;
  bool get isWaitingForDrivers => _status == RideRequestStatus.waiting;
  WsConnectionStatus get connectionStatus => _wsService.status;
  Stream<WsConnectionStatus> get statusStream => _wsService.statusStream;

  PassengerWsProvider(this._wsService, this._rideTrackingProvider) {
    _initialize();
  }

  void setRideConfirmedCallback(Function(Map<String, dynamic>)? callback) {
    _onRideConfirmed = callback;
    logInfo(
      'PassengerWs',
      'Navigation callback ${callback != null ? "set" : "cleared"}',
    );
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  void _initialize() {
    _statusSubscription = _wsService.statusStream.listen((status) {
      if (status == WsConnectionStatus.connected) {
        logSuccess('PassengerWs', 'Connected');
      } else if (status == WsConnectionStatus.error) {
        _setError('Connexion perdue');
      }
      safeNotify();
    });

    _messageSubscription = _wsService.messages.listen(
      _handleMessage,
      onError: (error) {
        logError('PassengerWs', 'Message error: $error');
        _setError('Erreur de communication');
      },
    );
  }

  // ==========================================================================
  // MESSAGE ROUTING
  // ==========================================================================

  void _handleMessage(WsMessage message) {
    if (isDisposed) return;

    logInfo('PassengerWs', 'Received: ${message.type.name}');

    switch (message.type) {
      case WsMessageType.rideH3Info:
        _handleRideH3Info(message.data);
        break;

      case WsMessageType.driverOffer:
        _handleDriverOffer(message.data);
        break;

      case WsMessageType.rideConfirmed:
        _handleRideConfirmed(message.data);
        break;

      case WsMessageType.cancelRide:
        _handleRideCancelled(message.data);
        break;

      case WsMessageType.counterOfferSent:
        _handleCounterOfferSent(message.data);
        break;

      case WsMessageType.driverRejected:
        _handleDriverRejected(message.data);
        break;

      case WsMessageType.driverCancelled:
        _handleDriverCancelled(message.data);
        break;

      case WsMessageType.rideRejected:
        _handleRideRejected(message.data);
        break;

      case WsMessageType.error:
        _handleError(message.data);
        break;

      default:
        logWarning('PassengerWs', 'Unhandled message type: ${message.type}');
    }
  }

  // ==========================================================================
  // MESSAGE HANDLERS
  // ==========================================================================

  void _handleRideH3Info(Map<String, dynamic> data) {
    logInfo('PassengerWs', 'Ride H3 info received: $data');

    _currentRideId = data['rideId'] as String?;

    if (_currentRideId != null) {
      _status = RideRequestStatus.waiting;
      _errorMessage = null;
      safeNotify();
    }
  }

  void _handleDriverOffer(Map<String, dynamic> data) {
    logInfo('PassengerWs', 'Driver offer received: $data');

    final offerType = data['offerType'] as String?;
    final isCounter = offerType == 'counter';

    if (isCounter) {
      final offer = DriverOffer.fromWsMessage(data, isCounter: true);
      _pendingCounterOffer = offer;
      _status = RideRequestStatus.negotiating;
      logWarning(
        'PassengerWs',
        'Counter-offer: ${offer.driverName} wants ${offer.suggestedPrice} DH',
      );
    } else {
      final offer = DriverOffer.fromWsMessage(data, isCounter: false);

      final existingIndex = _driverOffers.indexWhere(
        (o) => o.driverId == offer.driverId,
      );

      if (existingIndex >= 0) {
        _driverOffers[existingIndex] = offer;
      } else {
        _driverOffers.add(offer);
      }

      logSuccess(
        'PassengerWs',
        'Driver offer: ${offer.driverName} at ${offer.suggestedPrice} DH',
      );
    }

    safeNotify();
  }

  void _handleRideConfirmed(Map<String, dynamic> data) {
    logSuccess('PassengerWs', '✅ Ride confirmed!');
    logDebug('PassengerWs', 'Ride ID: ${data['rideId']}');
    logDebug('PassengerWs', 'Driver ID: ${data['driverId']}');
    logDebug('PassengerWs', 'Final Price: ${data['price']} DH');

    _status = RideRequestStatus.accepted;

    try {
      final driverData = data['driver'] as Map<String, dynamic>?;
      if (driverData != null) {
        logSuccess(
          'PassengerWs',
          '✅ Driver data found: ${driverData['firstName']} ${driverData['lastName']}',
        );
      } else {
        logError('PassengerWs', '❌ No driver data in payload!');
      }

      _rideTrackingProvider.initializeRide(data, 'passenger');

      logSuccess(
        'PassengerWs',
        '✅ Ride tracking initialized for passenger mode',
      );
      logInfo(
        'PassengerWs',
        'Driver: ${data['driver']?['firstName']} ${data['driver']?['lastName']}',
      );
      logInfo(
        'PassengerWs',
        'Vehicle: ${data['driver']?['vehicleBrand']} ${data['driver']?['vehicleModel']}',
      );
    } catch (e, stackTrace) {
      logError('PassengerWs', 'Error initializing ride tracking: $e');
      logError('PassengerWs', 'Stack trace: $stackTrace');
    }

    safeNotify();
  }

  void _handleRideCancelled(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final userId = data['userId'] as String?;

    logWarning('PassengerWs', '🚫 Ride cancelled: $rideId by user: $userId');

    if (rideId != _currentRideId) {
      logWarning(
        'PassengerWs',
        '⚠️ Cancelled ride does not match current ride',
      );
      return;
    }

    _cleanup();

    logSuccess('PassengerWs', '✅ Passenger state cleaned after cancellation');
  }

  void _handleCounterOfferSent(Map<String, dynamic> data) {
    logInfo('PassengerWs', '✅ Counter-offer sent confirmation: $data');

    _pendingCounterOffer = null;
    _status = RideRequestStatus.waiting;
    safeNotify();
  }

  void _handleDriverRejected(Map<String, dynamic> data) {
    logInfo('PassengerWs', 'Driver rejected confirmation: $data');

    final driverId = data['driverId'] as String?;
    if (driverId != null) {
      _driverOffers.removeWhere((offer) => offer.driverId == driverId);

      if (_pendingCounterOffer?.driverId == driverId) {
        _pendingCounterOffer = null;
      }

      logSuccess('PassengerWs', '✅ Driver $driverId removed from offers list');
      safeNotify();
    }
  }

  void _handleRideRejected(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final message = data['message'] as String?;

    if (rideId != _currentRideId) {
      logWarning(
        'RideRejected',
        '⚠️ Rejected ride does not match current ride',
      );
      return;
    }

    logWarning('PassengerWs', '❌ Driver rejected ride: $rideId');
    logInfo('PassengerWs', 'Message: ${message ?? "Driver declined"}');

    // Note: The ride is removed from backend's activeRideOffers
    // But passenger keeps waiting for other drivers
    // UI shows: "Conducteur refusé. En attente d'autres conducteurs."

    safeNotify();
    logSuccess('PassengerWs', '✅ Ride rejection acknowledged');
  }

  void _handleError(Map<String, dynamic> data) {
    logError('PassengerWs', 'Error message: $data');

    final message = data['message'] as String? ?? 'Une erreur est survenue';
    _setError(message);
  }

  void _handleDriverCancelled(Map<String, dynamic> data) {
    final rideId = data['rideId'] as String?;
    final driverId = data['driverId'] as String?;

    if (rideId == null) {
      logError('DriverCancelled', 'Missing rideId in cancellation message');
      return;
    }

    logWarning(
      'DriverCancelled',
      '❌ Driver $driverId cancelled offer for ride $rideId',
    );

    _driverOffers.removeWhere(
      (offer) => offer.rideId == rideId && offer.driverId == driverId,
    );

    if (_pendingCounterOffer?.rideId == rideId &&
        _pendingCounterOffer?.driverId == driverId) {
      _pendingCounterOffer = null;
      logInfo('DriverCancelled', '✅ Cleared pending counter-offer');
    }

    safeNotify();

    logSuccess('DriverCancelled', '✅ Driver offer removed from list');
  }

  Future<void> connect() async {
    if (_wsService.isConnected) {
      if (_wsService.currentEndpoint == '/ws/passenger') {
        logWarning('PassengerWs', 'Already connected to passenger endpoint');
        return;
      }

      logInfo('PassengerWs', 'Switching to passenger endpoint');
      await _wsService.switchEndpoint('/ws/passenger');
    } else {
      await _wsService.connect('/ws/passenger');
    }
  }

  Future<bool> sendRideRequest({
    required String passengerId,
    required Map<String, dynamic> departure,
    required Map<String, dynamic> destination,
    required int price,
    required String rideType,
    required String vehicleType,
    required int seats,
    required double distanceKm,
    required String estimatedTime,
    required String paymentType,
  }) async {
    if (!_wsService.isConnected) {
      _setError('Non connecté au serveur');
      return false;
    }

    try {
      _status = RideRequestStatus.requesting;
      _errorMessage = null;
      _driverOffers.clear();
      _pendingCounterOffer = null;
      _currentPrice = price.toDouble();
      safeNotify();

      final requestData = {
        'type': 'rideRequest',
        'passengerId': passengerId,
        'departure': departure,
        'destination': destination,
        'price': price,
        'rideType': rideType,
        'vehicleType': vehicleType,
        'seats': seats,
        'distanceKm': distanceKm,
        'estimatedTime': estimatedTime,
        'paymentType': paymentType,
      };

      _wsService.sendMessage(requestData);

      logSuccess('PassengerWs', '=== RIDE REQUEST SENT ===');
      logInfo('PassengerWs', 'Passenger ID: $passengerId');
      logInfo('PassengerWs', 'Price: $price DH');
      logInfo('PassengerWs', 'Distance: ${distanceKm}km');
      logInfo('PassengerWs', 'Payment Type: $paymentType');

      return true;
    } catch (e) {
      logError('PassengerWs', 'Error sending ride request: $e');
      _setError('Erreur lors de l\'envoi de la demande');
      return false;
    }
  }

  Future<bool> acceptDriver(String driverId, String passengerId) async {
    if (!_wsService.isConnected || _currentRideId == null) {
      _setError('Aucune course active');
      return false;
    }

    try {
      _wsService.sendMessage({
        'type': 'acceptDriver',
        'rideId': _currentRideId,
        'driverId': driverId,
        'passengerId': passengerId,
      });

      logSuccess('PassengerWs', '✅ Driver acceptance sent: $driverId');
      return true;
    } catch (e) {
      logError('PassengerWs', 'Error accepting driver: $e');
      _setError('Erreur lors de l\'acceptation');
      return false;
    }
  }

  Future<bool> rejectDriver(String driverId, String passengerId) async {
    if (!_wsService.isConnected || _currentRideId == null) {
      _setError('Aucune course active');
      return false;
    }

    try {
      logInfo('PassengerWs', '📤 Sending rejectDriver for: $driverId');

      _wsService.sendMessage({
        'type': 'rejectDriver',
        'rideId': _currentRideId,
        'driverId': driverId,
        'passengerId': passengerId,
      });

      logSuccess('PassengerWs', '✅ Driver rejection sent: $driverId');

      // Remove from UI
      _driverOffers.removeWhere((offer) => offer.driverId == driverId);

      if (_pendingCounterOffer?.driverId == driverId) {
        _pendingCounterOffer = null;
      }

      safeNotify();

      return true;
    } catch (e) {
      logError('PassengerWs', 'Error rejecting driver: $e');
      _setError('Erreur lors du rejet');
      return false;
    }
  }

  Future<bool> acceptCounterOffer(String passengerId) async {
    if (_pendingCounterOffer == null) {
      _setError('Aucune contre-offre en attente');
      return false;
    }

    return await acceptDriver(_pendingCounterOffer!.driverId, passengerId);
  }

  Future<bool> rejectCounterOffer(String passengerId) async {
    if (_pendingCounterOffer == null) {
      _setError('Aucune contre-offre en attente');
      return false;
    }

    final driverId = _pendingCounterOffer!.driverId;
    _pendingCounterOffer = null;
    safeNotify();

    return await rejectDriver(driverId, passengerId);
  }

  // Validates if user can send counter-offer with new price
  // For FREE RIDE: must have points >= newPrice
  bool canSendCounterOffer(
    double newPrice,
    int availablePoints,
    String paymentType,
  ) {
    if (paymentType == 'FREERIDE') {
      return availablePoints >= newPrice.toInt();
    }
    return true; // Cash payment - no validation needed
  }

  Future<bool> sendCounterOffer(
    String passengerId,
    double newPrice,
    int availablePoints,
    String paymentType,
  ) async {
    if (!_wsService.isConnected || _currentRideId == null) {
      _setError('Aucune course active');
      return false;
    }

    // VALIDATE FREE RIDE counter-offer
    if (!canSendCounterOffer(newPrice, availablePoints, paymentType)) {
      _setError(
        'Points insuffisants pour cette contre-offre: ${newPrice.toInt()}pts requis, vous avez ${availablePoints}pts',
      );
      logWarning('PassengerWs', 'Counter-offer blocked: insufficient points');
      return false;
    }

    try {
      _wsService.sendMessage({
        'type': 'counterOffer',
        'rideId': _currentRideId,
        'passengerId': passengerId,
        'newPrice': newPrice,
      });

      _currentPrice = newPrice;
      logWarning('PassengerWs', '✅ Passenger counter-offer sent: $newPrice DH');
      return true;
    } catch (e) {
      logError('PassengerWs', 'Error sending counter-offer: $e');
      _setError('Erreur lors de l\'envoi de la contre-offre');
      return false;
    }
  }

  Future<bool> cancelRide(String passengerId, String reason) async {
    if (!_wsService.isConnected) {
      logWarning('PassengerWs', 'Cannot cancel: WebSocket not connected');
      _cleanup();
      return true;
    }

    if (_currentRideId == null) {
      logWarning('PassengerWs', 'Cannot cancel: No active ride');
      _cleanup();
      return true;
    }

    try {
      logInfo('PassengerWs', '📤 Sending cancelRide message');
      logDebug('PassengerWs', 'Ride ID: $_currentRideId');
      logDebug('PassengerWs', 'User ID: $passengerId');
      logDebug('PassengerWs', 'Reason: $reason');

      _wsService.sendMessage({
        'type': 'cancelRide',
        'rideId': _currentRideId,
        'userId': passengerId,
      });

      logSuccess('PassengerWs', '✅ Cancellation sent');

      await Future.delayed(const Duration(milliseconds: 300));

      _cleanup();

      return true;
    } catch (e) {
      logError('PassengerWs', '❌ Error cancelling ride: $e');
      _setError('Erreur lors de l\'annulation');
      _cleanup();
      return false;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = RideRequestStatus.error;
    safeNotify();
  }

  void _cleanup() {
    logInfo('PassengerWs', 'Cleaning up state');
    _currentRideId = null;
    _currentPrice = null;
    _status = RideRequestStatus.idle;
    _driverOffers.clear();
    _pendingCounterOffer = null;
    _onRideConfirmed = null;
    safeNotify();
  }

  void reset() {
    _cleanup();
    _errorMessage = null;
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _onRideConfirmed = null;
    super.dispose();
  }
}
