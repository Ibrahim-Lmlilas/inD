// features/ride_tracking/presentation/widgets/common/loading_overlay.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

class RideTrackingLoadingOverlay extends StatelessWidget {
  const RideTrackingLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.loading,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
