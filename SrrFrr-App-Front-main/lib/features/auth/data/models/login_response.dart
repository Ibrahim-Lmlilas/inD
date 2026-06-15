// Login response from backend
//
// Path: lib/features/auth/data/models/login_response.dart

import 'package:flutter/foundation.dart';

@immutable
class LoginResponse {
  final bool success;
  final String? message;
  final String? userId;
  final String? accessToken;
  final String? refreshToken;

  const LoginResponse({
    required this.success,
    this.message,
    this.userId,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      userId: json['userId'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
