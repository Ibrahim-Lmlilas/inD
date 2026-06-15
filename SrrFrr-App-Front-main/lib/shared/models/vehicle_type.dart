import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

enum VehicleType {
  car('CAR'),
  motorcycle('MOTORCYCLE'),
  truck('TRUCK');

  final String backendValue;
  const VehicleType(this.backendValue);

  static VehicleType fromBackend(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.backendValue == value,
      orElse: () => VehicleType.car,
    );
  }

  // Remove getters and use methods with AppLocalizations parameter
  String label(AppLocalizations l10n) {
    switch (this) {
      case VehicleType.car:
        return l10n.carLabel;
      case VehicleType.motorcycle:
        return l10n.motorcycleLabel;
      case VehicleType.truck:
        return l10n.truckLabel;
    }
  }

  String subtitle(AppLocalizations l10n) {
    switch (this) {
      case VehicleType.car:
        return l10n.carSubtitle;
      case VehicleType.motorcycle:
        return l10n.motorcycleSubtitle;
      case VehicleType.truck:
        return l10n.truckSubtitle;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.truck:
        return Icons.local_shipping;
    }
  }

  Color get color {
    switch (this) {
      case VehicleType.car:
        return AppColors.primary;
      case VehicleType.motorcycle:
        return const Color(0xFFEC4899);
      case VehicleType.truck:
        return const Color(0xFF8B5CF6);
    }
  }
}