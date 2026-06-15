// Password reset request
//
// Path: lib/features/auth/data/models/password_reset_request.dart

import 'package:flutter/foundation.dart';

@immutable
class PasswordResetRequest {
  final String phoneNumber;
  final String otp;
  final String newPassword;

  const PasswordResetRequest({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'otp': otp, 'newPassword': newPassword};
  }
}
