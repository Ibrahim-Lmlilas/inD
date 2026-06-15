// Pagination information for message history

import 'package:flutter/foundation.dart';

@immutable
class MessagePagination {
  final int currentPage;
  final int totalPages;
  final bool hasMoreMessages;

  const MessagePagination({
    required this.currentPage,
    required this.totalPages,
    required this.hasMoreMessages,
  });

  factory MessagePagination.initial() {
    return const MessagePagination(
      currentPage: 0,
      totalPages: 0,
      hasMoreMessages: true,
    );
  }

  MessagePagination copyWith({
    int? currentPage,
    int? totalPages,
    bool? hasMoreMessages,
  }) {
    return MessagePagination(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    );
  }
}
