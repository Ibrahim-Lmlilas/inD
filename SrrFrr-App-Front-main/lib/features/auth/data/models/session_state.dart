// Session state
//
// Path: lib/features/auth/data/models/session_state.dart

import 'package:flutter/foundation.dart';

@immutable
class SessionState {
  final bool isAuthenticated;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;

  const SessionState({
    required this.isAuthenticated,
    this.accessToken,
    this.refreshToken,
    this.userId,
  });

  factory SessionState.unauthenticated() {
    return const SessionState(isAuthenticated: false);
  }

  factory SessionState.authenticated({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) {
    return SessionState(
      isAuthenticated: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }
}