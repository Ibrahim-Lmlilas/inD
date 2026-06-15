// Generic auth result wrapper
//
// Path: lib/features/auth/data/models/auth_result.dart

import 'package:flutter/foundation.dart';

@immutable
class AuthResult<T> {
  final T? data;
  final String? error;
  final bool success;

  const AuthResult._({this.data, this.error, required this.success});

  factory AuthResult.success(T data) {
    return AuthResult._(data: data, success: true);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(error: error, success: false);
  }
}
