// Information about message grouping for UI rendering

import 'package:flutter/foundation.dart';

@immutable
class MessageGroupInfo {
  final bool showDateSeparator;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTimestamp;

  const MessageGroupInfo({
    required this.showDateSeparator,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showTimestamp,
  });
}
