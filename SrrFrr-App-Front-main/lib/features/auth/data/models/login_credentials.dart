// Login credentials
//
// Path: lib/features/auth/data/models/login_credentials.dart

import 'package:flutter/foundation.dart';

@immutable
class LoginCredentials {
  final String phoneNumber;
  final String password;
  final String fcmToken;
  final String deviceId;

  const LoginCredentials({
    required this.phoneNumber,
    required this.password,
    required this.fcmToken,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'password': password,
      'fcmToken': fcmToken,
      'deviceId': deviceId,
    };
  }
}
