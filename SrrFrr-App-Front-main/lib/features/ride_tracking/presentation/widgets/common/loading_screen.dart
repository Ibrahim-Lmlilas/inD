// features/ride_tracking/presentation/widgets/common/loading_screen.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

class RideTrackingLoadingScreen extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const RideTrackingLoadingScreen({super.key, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.rideInitilisation,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
