import 'package:flutter/foundation.dart';

enum Gender { male, female }

enum InterfaceType {
  regular,
  ladies;

  String get displayName {
    switch (this) {
      case InterfaceType.regular:
        return 'Interface SrrFrr Régulière';
      case InterfaceType.ladies:
        return 'Interface SrrFrr Ladies';
    }
  }

  static InterfaceType fromString(String value) {
    return InterfaceType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => InterfaceType.regular,
    );
  }

  static List<InterfaceType> get all => InterfaceType.values;
}

enum Language { french, english, arabic }

extension GenderExtension on Gender {
  String toBackend() {
    switch (this) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
    }
  }

  static Gender fromBackend(String value) {
    switch (value.toUpperCase()) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}

extension InterfaceTypeExtension on InterfaceType {
  String toBackend() {
    switch (this) {
      case InterfaceType.regular:
        return 'REGULAR';
      case InterfaceType.ladies:
        return 'LADIES';
    }
  }

  static InterfaceType fromBackend(String value) {
    switch (value.toUpperCase()) {
      case 'LADIES':
        return InterfaceType.ladies;
      case 'REGULAR':
      default:
        return InterfaceType.regular;
    }
  }
}

// Language extension - simplified to use fr, en, ar everywhere
extension LanguageExtension on Language {
  // Backend uses same codes: fr, en, ar
  String toBackend() {
    switch (this) {
      case Language.french:
        return 'fr';
      case Language.english:
        return 'en';
      case Language.arabic:
        return 'ar';
    }
  }

  static Language fromBackend(String value) {
    switch (value.toLowerCase()) {
      case 'fr':
        return Language.french;
      case 'en':
        return Language.english;
      case 'ar':
        return Language.arabic;
      default:
        return Language.french;
    }
  }

  String get code {
    return toBackend(); // Same as backend
  }

  String get displayName {
    switch (this) {
      case Language.french:
        return 'Français';
      case Language.english:
        return 'English';
      case Language.arabic:
        return 'العربية';
    }
  }
}

@immutable
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profilePhotoPath;
  final Gender gender;
  final InterfaceType interfaceType;
  final Language language; // NEW FIELD
  final int points;
  final double wallet;
  final int totalRides;
  final double rating;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profilePhotoPath,
    required this.gender,
    required this.interfaceType,
    required this.language, // NEW PARAMETER
    required this.points,
    required this.wallet,
    required this.totalRides,
    required this.rating,
  });

  String get fullName => '$firstName $lastName';

  // Check if user should see ladies interface
  bool get shouldUseLadiesInterface =>
      gender == Gender.female && interfaceType == InterfaceType.ladies;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profilePhotoPath: json['profilePicture'] as String?,
      gender: GenderExtension.fromBackend(json['gender'] as String),
      interfaceType: InterfaceTypeExtension.fromBackend(
        json['interfaceType'] as String,
      ),
      language: LanguageExtension.fromBackend(
        json['language'] as String? ?? 'FRA',
      ), // NEW
      points: (json['points'] as num?)?.toInt() ?? 0,
      wallet: (json['wallet'] as num?)?.toDouble() ?? 0.0,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePhotoPath,
      'gender': gender.toBackend(),
      'interfaceType': interfaceType.toBackend(),
      'language': language.toBackend(), // NEW
      'points': points,
      'wallet': wallet,
      'totalRides': totalRides,
      'rating': rating,
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoPath,
    Gender? gender,
    InterfaceType? interfaceType,
    Language? language, // NEW PARAMETER
    int? points,
    double? wallet,
    int? totalRides,
    double? rating,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      gender: gender ?? this.gender,
      interfaceType: interfaceType ?? this.interfaceType,
      language: language ?? this.language, // NEW
      points: points ?? this.points,
      wallet: wallet ?? this.wallet,
      totalRides: totalRides ?? this.totalRides,
      rating: rating ?? this.rating,
    );
  }
}
