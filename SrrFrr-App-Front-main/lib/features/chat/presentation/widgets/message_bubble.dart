/// Message bubble widget
///
/// Path: lib/features/chat/presentation/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/chat/data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByMe;
    final topPadding = isFirstInGroup ? 8.0 : 2.0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 2),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && isFirstInGroup) _buildAvatar(),
          if (!isSent && !isFirstInGroup) const SizedBox(width: 40),
          Flexible(
            child: Column(
              crossAxisAlignment: isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubbleContent(context),
                if (showTimestamp) _buildTimestamp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          message.senderName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    final isSent = message.isSentByMe;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSent
            ? LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: isSent ? null : Colors.white,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isSent && isLastInGroup ? Radius.zero : null,
          bottomLeft: !isSent && isLastInGroup ? Radius.zero : null,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: isSent ? Colors.white : AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (message.isSentByMe) ...[
            const SizedBox(width: 4),
            Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (message.status) {
      case MessageStatus.read:
        return AppColors.primary;
      case MessageStatus.failed:
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}
