// OTP request/response models
//
// Path: lib/features/auth/data/models/otp_models.dart

import 'package:flutter/foundation.dart';

@immutable
class OtpRequest {
  final String phoneNumber;
  final String? otp;

  const OtpRequest({required this.phoneNumber, this.otp});
}

@immutable
class OtpResponse {
  final bool success;
  final String? message;
  final String? errorCode;

  const OtpResponse({required this.success, this.message, this.errorCode});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
    );
  }

  bool get isRateLimited => errorCode == 'RATE_LIMIT' || errorCode == '429';
}
