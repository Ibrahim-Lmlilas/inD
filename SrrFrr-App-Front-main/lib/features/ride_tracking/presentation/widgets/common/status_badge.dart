// features/ride_tracking/presentation/widgets/badges/status_badge.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool rideHasStarted;
  final bool driverHasArrived;

  const StatusBadge({
    super.key,
    required this.rideHasStarted,
    required this.driverHasArrived,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (rideHasStarted) {
      statusColor = const Color(0xFFDC2626);
      statusText = 'En cours';
    } else if (driverHasArrived) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Attente';
    } else {
      statusColor = AppColors.success;
      statusText = 'Actif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
