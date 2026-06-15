// features/ride_tracking/presentation/widgets/panel/vehicle_info_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/utils/color_utils.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';


class VehicleInfoCard extends StatelessWidget {
  const VehicleInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RideTrackingProvider>();
    final vehicleModel = provider.driverVehicle?['model'] as String?;
    final vehicleColor = provider.driverVehicle?['color'] as String?;
    final vehicleReg = provider.driverVehicle?['registration-code'] as String?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleModel ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (vehicleColor != null) ...[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: ColorUtils.getColorFromName(vehicleColor),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vehicleColor,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (vehicleReg != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicleReg,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}