import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

enum TransactionType { debit, parrainage, trajet, rating }

class LoyaltyReward {
  final String id;
  final String labelAR;
  final String labelFR;
  final String labelEN;

  LoyaltyReward({
    required this.id,
    required this.labelAR,
    required this.labelFR,
    required this.labelEN,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    try {
      return LoyaltyReward(
        id: json['id']?.toString() ?? '',
        labelAR: json['labelAR']?.toString() ?? '',
        labelFR: json['labelFR']?.toString() ?? '',
        labelEN: json['labelEN']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Error parsing LoyaltyReward: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  /// Get label based on user's language preference
  String getLabel(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final language = userProvider.currentUser?.language ?? Language.french;

      switch (language) {
        case Language.arabic:
          return labelAR.isNotEmpty ? labelAR : labelFR;
        case Language.english:
          return labelEN.isNotEmpty ? labelEN : labelFR;
        case Language.french:
        default:
          return labelFR;
      }
    } catch (e) {
      // Fallback if context is not available
      return labelFR;
    }
  }

  @override
  String toString() => 'LoyaltyReward(id: $id, labelFR: $labelFR)';
}