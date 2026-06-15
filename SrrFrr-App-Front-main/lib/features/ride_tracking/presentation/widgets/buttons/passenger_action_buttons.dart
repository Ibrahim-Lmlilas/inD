// features/ride_tracking/presentation/widgets/buttons/passenger_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

class PassengerNotifyComingButton extends StatelessWidget {
  final VoidCallback onNotifyComing;

  const PassengerNotifyComingButton({super.key, required this.onNotifyComing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onNotifyComing,
        icon: const Icon(Icons.directions_walk_rounded, size: 24),
        label: Text(
          l10n.coming,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
