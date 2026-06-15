// Message model with client-side ID tracking


import 'package:flutter/foundation.dart';
import 'message_status.dart';

@immutable
class Message {
  final String id; // Server ID (or temp client ID before confirmation)
  final String? clientMessageId; // Client-side tracking ID
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSentByMe;
  final MessageStatus status;
  final String messageType;
  final String? fileUrl;
  final int? fileSize;

  const Message({
    required this.id,
    this.clientMessageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.isSentByMe,
    required this.status,
    required this.messageType,
    this.fileUrl,
    this.fileSize,
  });

  factory Message.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    String? otherUserName,
  }) {
    final senderId = json['senderId'] as String;
    final isSentByMe = senderId == currentUserId;

    return Message(
      id: json['id'] as String? ?? json['messageId'] as String,
      clientMessageId: json['clientMessageId'] as String?,
      senderId: senderId,
      senderName: isSentByMe ? 'Moi' : (otherUserName ?? 'User'),
      content: json['content'] as String,
      timestamp: DateTime.parse(
        json['sentAt'] as String? ?? json['timestamp'] as String,
      ),
      isRead: json['readAt'] != null,
      isSentByMe: isSentByMe,
      status: _parseStatus(json['status'] as String?),
      messageType: json['messageType'] as String? ?? 'TEXT',
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'] as int?,
    );
  }

  static MessageStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SENT':
        return MessageStatus.sent;
      case 'DELIVERED':
        return MessageStatus.delivered;
      case 'READ':
        return MessageStatus.read;
      case 'FAILED':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  Message copyWith({
    String? id,
    String? clientMessageId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSentByMe,
    MessageStatus? status,
    String? messageType,
    String? fileUrl,
    int? fileSize,
  }) {
    return Message(
      id: id ?? this.id,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      status: status ?? this.status,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
