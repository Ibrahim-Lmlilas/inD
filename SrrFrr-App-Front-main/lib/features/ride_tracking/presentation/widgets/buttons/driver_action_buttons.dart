// features/ride_tracking/presentation/widgets/buttons/driver_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class DriverApproachingButton extends StatelessWidget {
  final double? distanceKm;
  final VoidCallback onConfirmArrival;

  const DriverApproachingButton({
    super.key,
    required this.distanceKm,
    required this.onConfirmArrival,
  });

  @override
  Widget build(BuildContext context) {
    final canConfirm = distanceKm != null && distanceKm! <= 0.05;
    final l10n = AppLocalizations.of(context)!;

    if (!canConfirm) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onConfirmArrival,
        icon: const Icon(Icons.where_to_vote_rounded, size: 24),
        label: Text(
          l10n.arrivedAtPickup,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class DriverStartRideButton extends StatelessWidget {
  final VoidCallback onStartRide;

  const DriverStartRideButton({super.key, required this.onStartRide});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onStartRide,
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: Text(
          l10n.startingRide,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class DriverFinishRideButton extends StatelessWidget {
  final double? distanceKm;
  final VoidCallback onFinishRide;

  const DriverFinishRideButton({
    super.key,
    required this.distanceKm,
    required this.onFinishRide,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: distanceKm != null && distanceKm! <= 0.05
            ? onFinishRide
            : null,
        icon: const Icon(Icons.flag_rounded, size: 24),
        label: Text(
          l10n.finishRide,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          disabledBackgroundColor: AppColors.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
