// Chat session information

import 'package:flutter/foundation.dart';

@immutable
class ChatSession {
  final String chatId;
  final String rideId;
  final String channelId;
  final String wsToken;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatSession({
    required this.chatId,
    required this.rideId,
    required this.channelId,
    required this.wsToken,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  factory ChatSession.fromMap(
    Map<String, dynamic> chatData,
    Map<String, dynamic> rideData,
  ) {
    return ChatSession(
      chatId: chatData['chatId'] as String? ?? '',
      rideId: rideData['ride_id'] as String,
      channelId: chatData['channelId'] as String,
      wsToken: chatData['wsToken'] as String,
      currentUserId: chatData['current_user_id'] as String? ?? '',
      otherUserId: chatData['other_user_id'] as String? ?? '',
      otherUserName: chatData['other_user_name'] as String? ?? 'Utilisateur',
    );
  }
}
