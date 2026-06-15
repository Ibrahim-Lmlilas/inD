// Ride Type Selector Component
//
// Displays "City to City" and "In City" selection buttons

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class RideTypeSelector extends StatelessWidget {
  final String? selectedRideType;
  final Function(String) onRideTypeSelected;

  const RideTypeSelector({
    super.key,
    this.selectedRideType,
    required this.onRideTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRideTypeButton(
              context: context,
              type: 'city_to_city',
              label: 'Ville à ville',
              icon: Icons.location_city,
              isSelected: selectedRideType == 'city_to_city',
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: _buildRideTypeButton(
              context: context,
              type: 'in_city',
              label: 'En ville',
              icon: Icons.directions_car,
              isSelected: selectedRideType == 'in_city',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideTypeButton({
    required BuildContext context,
    required String type,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onRideTypeSelected(type);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.grey300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
