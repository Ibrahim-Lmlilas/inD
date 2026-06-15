// Centralized Logging Utility
//
// Provides color-coded console logging for the entire application.
// Use these functions instead of direct debugPrint calls for consistent
// logging format and better debugging experience.

import 'package:flutter/foundation.dart';

class LogColors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
}

void logInfo(String component, String message) {
  debugPrint('${LogColors.cyan}[INFO]${LogColors.reset} [$component] $message');
}

void logSuccess(String component, String message) {
  debugPrint(
    '${LogColors.green}[SUCCESS]${LogColors.reset} [$component] $message',
  );
}

void logWarning(String component, String message) {
  debugPrint(
    '${LogColors.yellow}[WARN]${LogColors.reset} [$component] $message',
  );
}

void logError(String component, String message) {
  debugPrint('${LogColors.red}[ERROR]${LogColors.reset} [$component] $message');
}

void logDebug(String component, String message) {
  debugPrint(
    '${LogColors.magenta}[DEBUG]${LogColors.reset} [$component] $message',
  );
}

void logCritical(String component, String message) {
  debugPrint(
    '${LogColors.white}${LogColors.red}[CRITICAL]${LogColors.reset} [$component] $message',
  );
}
