// features/ride_tracking/presentation/widgets/panel/communication_section.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/buttons/communication_button.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/ride_tracking_actions.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';


class CommunicationSection extends StatelessWidget {
  final RideTrackingState state;
  final RideTrackingActions actions;

  const CommunicationSection({
    super.key,
    required this.state,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = state.isPassengerMode
        ? state.driverPhone
        : state.passengerPhone;

    final otherUserId = state.isPassengerMode
        ? state.driverId
        : state.passengerId;

    final otherUserName = state.isPassengerMode
        ? state.driverName
        : state.passengerName;

    final isDriver = !state.isPassengerMode;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CommunicationButton(
                icon: Icons.phone_rounded,
                label: l10n.call,
                color: AppColors.success,
                onTap: () => actions.callUser(phone),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommunicationButton(
                icon: Icons.chat_bubble_rounded,
                label: l10n.message,
                color: AppColors.primary,
                onTap: () => actions.navigateToChat(
                  otherUserId,
                  otherUserName,
                  state.rideId,
                ),
              ),
            ),
            if (isDriver) ...[
              const SizedBox(width: 12),
              Expanded(
                child: CommunicationButton(
                  icon: Icons.navigation_rounded,
                  label: l10n.navigate,
                  color: const Color(0xFF33CCFF),
                  onTap: () => actions.openNavigation(
                    isPassengerMode: state.isPassengerMode,
                    rideHasStarted: state.rideHasStarted,
                    destination: state.destination,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => actions.showCancelDialog(),
            icon: const Icon(Icons.cancel_outlined, size: 20),
            label: Text(
              l10n.cancelRide,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
