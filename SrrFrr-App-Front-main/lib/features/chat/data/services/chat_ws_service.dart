// Chat WebSocket Service - Enhanced with client-side message ID tracking
library;

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:uuid/uuid.dart';

// =========================================================================
// Enums
// =========================================================================

enum ChatWsStatus { disconnected, connecting, connected, error }

enum ChatMessageType {
  connected,
  newMessage,
  messageSent,
  messageDelivered,
  userStatus,
  error,
  pong,
  unknown,
}

// =========================================================================
// Message Model
// =========================================================================

class ChatWsMessage {
  final ChatMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  ChatWsMessage({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory ChatWsMessage.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final type = _parseMessageType(typeString);
    return ChatWsMessage(type: type, data: json);
  }

  static ChatMessageType _parseMessageType(String? typeString) {
    if (typeString == null) return ChatMessageType.unknown;

    switch (typeString) {
      case 'connected':
        return ChatMessageType.connected;
      case 'newMessage':
        return ChatMessageType.newMessage;
      case 'messageSent':
        return ChatMessageType.messageSent;
      case 'messageDelivered':
        return ChatMessageType.messageDelivered;
      case 'userStatus':
        return ChatMessageType.userStatus;
      case 'error':
        return ChatMessageType.error;
      case 'pong':
        return ChatMessageType.pong;
      default:
        logWarning('ChatWs', 'Unknown message type: $typeString');
        return ChatMessageType.unknown;
    }
  }
}

// =========================================================================
// Pending Message Tracker
// =========================================================================

class PendingMessage {
  final String clientMessageId;
  final String content;
  final DateTime sentAt;

  PendingMessage({
    required this.clientMessageId,
    required this.content,
    required this.sentAt,
  });
}

// =========================================================================
// WebSocket Service
// =========================================================================

class ChatWebSocketService {
  // =======================================================================
  // State Variables
  // =======================================================================

  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  ChatWsStatus _status = ChatWsStatus.disconnected;

  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 3);

  String? _wsToken;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  final _uuid = const Uuid();

  // Track pending messages by client-side ID
  final Map<String, PendingMessage> _pendingMessages = {};

  final StreamController<ChatWsMessage> _messageController =
      StreamController<ChatWsMessage>.broadcast();

  final StreamController<ChatWsStatus> _statusController =
      StreamController<ChatWsStatus>.broadcast();

  // =======================================================================
  // Public Getters
  // =======================================================================

  ChatWsStatus get status => _status;
  Stream<ChatWsMessage> get messages => _messageController.stream;
  Stream<ChatWsStatus> get statusStream => _statusController.stream;
  bool get isConnected => _status == ChatWsStatus.connected;

  // =======================================================================
  // Connection Management
  // =======================================================================

  String _getChatWsUrl(String token) {
    final apiUrl = dotenv.env['API_BASE_URL'];
    final uri = Uri.parse(apiUrl!);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final path = uri.path;
    final wsUrl =
        '$wsScheme://${uri.host}:${uri.port}${path}/ws/chat?token=$token';
    logInfo('ChatWs', 'WebSocket URL: $wsUrl');
    return wsUrl;
  }

  Future<void> connect({required String token}) async {
    if (_status == ChatWsStatus.connected ||
        _status == ChatWsStatus.connecting) {
      logWarning('ChatWs', 'Already connected or connecting');
      return;
    }

    _cancelReconnectTimer();

    try {
      _wsToken = token;
      _updateStatus(ChatWsStatus.connecting);

      final wsUrl = _getChatWsUrl(token);
      logInfo('ChatWs', 'Connecting to: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      logInfo(
        'ChatWs',
        'WebSocket channel ready, awaiting server confirmation',
      );

      _listenToMessages();
      _startHeartbeat();

      _reconnectAttempts = 0;
    } catch (e) {
      logError('ChatWs', 'Connection error: $e');
      _updateStatus(ChatWsStatus.error);
      _scheduleReconnect();
    }
  }

  void _listenToMessages() {
    _messageSubscription?.cancel();

    logInfo('ChatWs', 'Starting message listener');

    _messageSubscription = _channel!.stream.listen(
      (data) {
        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;

          if (jsonData['type'] == 'connected') {
            logSuccess('ChatWs', 'Connection confirmed by server');
            logInfo('ChatWs', '   - Channel: ${jsonData['channelId']}');
            logInfo('ChatWs', '   - User: ${jsonData['userId']}');
            logInfo(
              'ChatWs',
              '   - Subscribers: ${jsonData['subscriberCount']}',
            );
            _updateStatus(ChatWsStatus.connected);
            return;
          }

          final message = ChatWsMessage.fromJson(jsonData);

          // Handle messageSent confirmation
          if (message.type == ChatMessageType.messageSent) {
            final serverMessageId = message.data['messageId'] as String?;
            if (serverMessageId != null) {
              _handleMessageConfirmation(serverMessageId, message.data);
            }
          }

          logSuccess('ChatWs', 'Received: ${message.type.name}');
          _messageController.add(message);
        } catch (e) {
          logError('ChatWs', 'Error parsing message: $e');
        }
      },
      onError: (error) {
        logError('ChatWs', 'Stream error: $error');
        _updateStatus(ChatWsStatus.error);
        _scheduleReconnect();
      },
      onDone: () {
        logWarning('ChatWs', 'Connection closed by server');
        _updateStatus(ChatWsStatus.disconnected);
        _scheduleReconnect();
      },
      cancelOnError: false,
    );
  }

  void _handleMessageConfirmation(
    String serverMessageId,
    Map<String, dynamic> data,
  ) {
    // Remove from pending messages when confirmed
    final confirmedMessage = _pendingMessages.entries
        .where((entry) => entry.value.content == data['content'])
        .firstOrNull;

    if (confirmedMessage != null) {
      _pendingMessages.remove(confirmedMessage.key);
      logSuccess(
        'ChatWs',
        'Message confirmed: ${confirmedMessage.key} -> $serverMessageId',
      );
    }
  }

  void _scheduleReconnect() {
    if (_wsToken == null) {
      logWarning('ChatWs', 'No token available, cannot reconnect');
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logError('ChatWs', 'Max reconnect attempts reached');
      return;
    }

    _cancelReconnectTimer();

    _reconnectAttempts++;
    logInfo(
      'ChatWs',
      'Scheduling reconnect attempt $_reconnectAttempts in ${_reconnectDelay.inSeconds}s',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_wsToken != null) {
        connect(token: _wsToken!);
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // =======================================================================
  // Message Sending with Client-Side ID Tracking
  // =======================================================================

  String sendTextMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (!isConnected) {
      logError('ChatWs', 'Cannot send message: not connected');
      throw Exception('Not connected');
    }

    // Generate unique client-side message ID
    final clientMessageId = _uuid.v4();

    // Check for duplicate content in pending messages (last 2 seconds)
    final now = DateTime.now();
    final duplicates = _pendingMessages.entries.where((entry) {
      return entry.value.content == content &&
          now.difference(entry.value.sentAt).inSeconds < 2;
    });

    if (duplicates.isNotEmpty) {
      logWarning('ChatWs', 'Duplicate message detected, ignoring send');
      return duplicates.first.key; // Return existing client ID
    }

    // Track pending message
    _pendingMessages[clientMessageId] = PendingMessage(
      clientMessageId: clientMessageId,
      content: content,
      sentAt: now,
    );

    // Clean old pending messages (older than 30 seconds)
    _pendingMessages.removeWhere((key, value) {
      return now.difference(value.sentAt).inSeconds > 30;
    });

    try {
      final message = {
        'type': 'sendMessage',
        'clientMessageId': clientMessageId, // Include for tracking
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': 'TEXT',
      };

      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);

      logInfo('ChatWs', 'Text message sent with ID: $clientMessageId');
      return clientMessageId;
    } catch (e) {
      _pendingMessages.remove(clientMessageId);
      logError('ChatWs', 'Error sending message: $e');
      rethrow;
    }
  }

  String sendMediaMessage({
    required String senderId,
    required String receiverId,
    required String messageType,
    required String fileUrl,
    required int fileSize,
    String? caption,
  }) {
    if (!isConnected) {
      logError('ChatWs', 'Cannot send message: not connected');
      throw Exception('Not connected');
    }

    final clientMessageId = _uuid.v4();

    try {
      final message = {
        'type': 'sendMessage',
        'clientMessageId': clientMessageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': caption ?? '',
        'messageType': messageType,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
      };

      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);

      logInfo(
        'ChatWs',
        'Media message sent ($messageType) with ID: $clientMessageId',
      );
      return clientMessageId;
    } catch (e) {
      logError('ChatWs', 'Error sending media message: $e');
      rethrow;
    }
  }

  // =======================================================================
  // Connection Health
  // =======================================================================

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
          logInfo('ChatWs', 'Heartbeat sent');
        } catch (e) {
          logError('ChatWs', 'Heartbeat error: $e');
          _updateStatus(ChatWsStatus.error);
          _scheduleReconnect();
        }
      }
    });

    logInfo(
      'ChatWs',
      'Heartbeat started (${_heartbeatInterval.inSeconds}s interval)',
    );
  }

  // =======================================================================
  // Status Management
  // =======================================================================

  void _updateStatus(ChatWsStatus newStatus) {
    if (_status != newStatus) {
      final oldStatus = _status;
      _status = newStatus;
      _statusController.add(newStatus);
      logInfo('ChatWs', 'Status: ${oldStatus.name} -> ${newStatus.name}');
    }
  }

  // =======================================================================
  // Cleanup
  // =======================================================================

  Future<void> disconnect() async {
    logInfo('ChatWs', 'Disconnecting...');

    _cancelReconnectTimer();
    _heartbeatTimer?.cancel();
    _messageSubscription?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _updateStatus(ChatWsStatus.disconnected);

    _wsToken = null;
    _reconnectAttempts = 0;
    _pendingMessages.clear();

    logSuccess('ChatWs', 'Disconnected successfully');
  }

  void dispose() {
    logInfo('ChatWs', 'Disposing service...');

    disconnect();
    _messageController.close();
    _statusController.close();

    logSuccess('ChatWs', 'Service disposed');
  }
}
