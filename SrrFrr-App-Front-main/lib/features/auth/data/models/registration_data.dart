// Registration data for new passenger account
//
// Path: lib/features/auth/data/models/registration_data.dart

import 'package:flutter/foundation.dart';

@immutable
class RegistrationData {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender; // Backend format: MALE/FEMALE
  final String password;
  final String interfaceType; // Backend format: REGULAR/LADIES
  final String? email;
  final String language;
  final String? profilePhotoPath;
  final bool termsAccepted;
  final String fcmToken;
  final String deviceId;

  const RegistrationData({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.password,
    required this.interfaceType,
    this.email,
    this.profilePhotoPath,
    required this.language,
    required this.termsAccepted,
    required this.fcmToken,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'password': password,
      'interfaceType': interfaceType,
      'email': email,
      'profilePhotoPath': profilePhotoPath,
      'termsAccepted': termsAccepted,
      'fcmToken': fcmToken,
      'deviceId': deviceId,
    };
  }
}
