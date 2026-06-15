// WebSocket Service - Real-time Communication Layer
//
// Manages WebSocket connection lifecycle and message routing for
// driver and passenger providers with stream health monitoring.
library;

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

// ============================================================================
// ENUMS AND DATA MODELS
// ============================================================================

enum WsMessageType {
  rideH3Info,
  driverOffer,
  rideConfirmed,
  cancelRide, // renamed from rideCancelled
  counterOfferSent,
  driverRejected,
  rideRequest,
  offerSent,
  offerRejected,
  driverLocation,
  driverLocationUpdate,
  rideRejected,
  driverCancelled,
  approachingDestination,

  // TODO: to be added when ride tracking is implemented in the backend
  rideCompleted,
  rideStarted,
  error,
  unknown,
}

enum WsConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WsMessage {
  final WsMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WsMessage({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = _parseMessageType(typeString);

    return WsMessage(type: type, data: json);
  }

  static WsMessageType _parseMessageType(String? typeString) {
    if (typeString == null) return WsMessageType.unknown;

    switch (typeString) {
      case 'rideH3Info':
        return WsMessageType.rideH3Info;
      case 'driverOffer':
        return WsMessageType.driverOffer;
      case 'rideConfirmed':
        return WsMessageType.rideConfirmed;
      case 'cancelRide':
        return WsMessageType.cancelRide;
      case 'counterOfferSent':
        return WsMessageType.counterOfferSent;
      case 'driverRejected':
        return WsMessageType.driverRejected;
      case 'rideRequest':
        return WsMessageType.rideRequest;
      case 'offerSent':
        return WsMessageType.offerSent;
      case 'offerRejected':
        return WsMessageType.offerRejected;
      case 'driverLocation':
        return WsMessageType.driverLocation;
      case 'error':
        return WsMessageType.error;
      case 'rideRejected':
        return WsMessageType.rideRejected;
      case 'driverCancelled':
        return WsMessageType.driverCancelled;
      default:
        logWarning('WsMessage', 'Unknown message type: $typeString');
        return WsMessageType.unknown;
    }
  }
}

// ============================================================================
// WEB SOCKET SERVICE CLASS
// ============================================================================

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _streamHealthCheckTimer;
  String? _currentEndpoint;

  // ============================================================================
  // PRIVATE PROPERTIES
  // ============================================================================

  WsConnectionStatus _status = WsConnectionStatus.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  final StreamController<WsMessage> _messageController =
      StreamController<WsMessage>.broadcast();

  final StreamController<WsConnectionStatus> _statusController =
      StreamController<WsConnectionStatus>.broadcast();

  int _messageCount = 0;
  // DateTime? _lastMessageTime;

  // ============================================================================
  // PUBLIC GETTERS
  // ============================================================================

  WsConnectionStatus get status => _status;
  Stream<WsMessage> get messages => _messageController.stream;
  Stream<WsConnectionStatus> get statusStream => _statusController.stream;
  bool get isConnected => _status == WsConnectionStatus.connected;
  String? get currentEndpoint => _currentEndpoint;

  // ============================================================================
  // CONNECTION MANAGEMENT
  // ============================================================================

  // Get WebSocket URL from environment
  String _getWsUrl(String endpoint) {
    final apiUrl = dotenv.env['API_BASE_URL'];
    final uri = Uri.parse(apiUrl!);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';

    final path = uri.path;
    final wsUrl = '$wsScheme://${uri.host}:${uri.port}$path$endpoint';

    logInfo('WebSocket', 'URL: $wsUrl');
    return wsUrl;
  }

  // Connect to WebSocket server with specific endpoint
  Future<void> connect(String endpoint) async {
    if (_status == WsConnectionStatus.connected ||
        _status == WsConnectionStatus.connecting) {
      logWarning('WebSocket', 'Already connected or connecting');
      return;
    }

    try {
      _currentEndpoint = endpoint;
      _updateStatus(WsConnectionStatus.connecting);
      final wsUrl = _getWsUrl(endpoint);
      logInfo('WebSocket', 'Connecting to: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      await _channel!.ready;

      _updateStatus(WsConnectionStatus.connected);
      _reconnectAttempts = 0;
      logSuccess('WebSocket', 'Connected successfully');

      _listenToMessages();
      _startHeartbeat();
      // _startStreamHealthCheck();
    } catch (e) {
      logError('WebSocket', 'Connection error: $e');
      _updateStatus(WsConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  // Listen to incoming messages
  void _listenToMessages() {
    _messageSubscription?.cancel();

    logInfo('WebSocket', 'Starting message listener');
    logDebug('WebSocket', 'Stream is active: ${_channel?.stream != null}');

    _messageSubscription = _channel!.stream.listen(
      (data) {
        _messageCount++;
        // _lastMessageTime = DateTime.now();

        logDebug('WebSocket', '========================================');
        logDebug('WebSocket', 'RAW MESSAGE RECEIVED (#$_messageCount)');
        logDebug('WebSocket', 'Data type: ${data.runtimeType}');
        logDebug('WebSocket', 'Data length: ${(data as String).length}');
        logDebug('WebSocket', 'Raw data: $data');
        logDebug('WebSocket', '========================================');

        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;
          logInfo('WebSocket', 'JSON parsed successfully');
          logInfo('WebSocket', 'Message type: ${jsonData['type']}');

          final message = WsMessage.fromJson(jsonData);

          logSuccess('WebSocket', 'Received: ${message.type.name}');
          logDebug('WebSocket', 'Message data: ${message.data}');

          _messageController.add(message);

          logSuccess('WebSocket', 'Message added to stream controller');
          logInfo(
            'WebSocket',
            'Stream has listeners: ${_messageController.hasListener}',
          );
        } catch (e, stackTrace) {
          logError('WebSocket', 'Error parsing message: $e');
          logError('WebSocket', 'Stack trace: $stackTrace');
        }
      },
      onError: (error) {
        logError('WebSocket', 'Stream error: $error');
        _updateStatus(WsConnectionStatus.error);
        _scheduleReconnect();
      },
      onDone: () {
        logWarning('WebSocket', 'Connection closed');
        _updateStatus(WsConnectionStatus.disconnected);
        _scheduleReconnect();
      },
      cancelOnError: false,
    );

    logSuccess('WebSocket', 'Message listener started');
  }

  // ============================================================================
  // MESSAGE HANDLING
  // ============================================================================

  // Send message to server
  void sendMessage(Map<String, dynamic> message) {
    if (!isConnected) {
      logError('WebSocket', 'Cannot send message: not connected');
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      logInfo('WebSocket', 'Sending: ${message['type']} - $message');
      _channel!.sink.add(jsonMessage);

      if (message['type'] == 'driverLocation') {
        logInfo('WebSocket', 'Waiting for ride requests from backend');
      }
    } catch (e) {
      logError('WebSocket', 'Error sending message: $e');
    }
  }

  // ============================================================================
  // HEALTH MONITORING AND RECONNECTION
  // ============================================================================

  // Start stream health check
  // void _startStreamHealthCheck() {
  //   _streamHealthCheckTimer?.cancel();

  //   _streamHealthCheckTimer = Timer.periodic(const Duration(seconds: 10), (
  //     timer,
  //   ) {
  //     logInfo('WebSocket', '=== STREAM HEALTH CHECK ===');
  //     logInfo('WebSocket', 'Connected: $isConnected');
  //     logInfo('WebSocket', 'Messages received: $_messageCount');
  //     logInfo('WebSocket', 'Last message: ${_lastMessageTime ?? "Never"}');
  //     logInfo('WebSocket', 'Stream active: ${_channel?.stream != null}');
  //     logInfo('WebSocket', 'Has listeners: ${_messageController.hasListener}');
  //     logInfo(
  //       'WebSocket',
  //       'Subscription active: ${_messageSubscription != null}',
  //     );
  //     logInfo('WebSocket', '===========================');
  //   });
  // }

  // Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        sendMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  // Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logError('WebSocket', 'Max reconnect attempts reached');
      _updateStatus(WsConnectionStatus.error);
      return;
    }

    if (_currentEndpoint == null) {
      logWarning('WebSocket', 'No endpoint to reconnect to');
      return;
    }

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;

    logInfo(
      'WebSocket',
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );
    _updateStatus(WsConnectionStatus.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      connect(_currentEndpoint!);
    });
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  // Update connection status
  void _updateStatus(WsConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      logInfo('WebSocket', 'Status: ${newStatus.name}');
    }
  }

  // Disconnect from WebSocket
  Future<void> disconnect() async {
    logInfo('WebSocket', 'Disconnecting WebSocket');

    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _streamHealthCheckTimer?.cancel();
    _messageSubscription?.cancel();

    await _channel?.sink.close();
    _channel = null;
    _currentEndpoint = null;

    _updateStatus(WsConnectionStatus.disconnected);
    _reconnectAttempts = 0;
  }

  // Switch to different WebSocket endpoint
  Future<void> switchEndpoint(String newEndpoint) async {
    logInfo('WebSocket', 'Switching endpoint to: $newEndpoint');

    await disconnect();

    await Future.delayed(const Duration(milliseconds: 500));

    await connect(newEndpoint);
  }

  // Reset reconnect attempts counter
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}
