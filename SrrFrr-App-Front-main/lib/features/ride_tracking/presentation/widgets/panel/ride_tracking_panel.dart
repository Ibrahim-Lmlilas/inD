// features/ride_tracking/presentation/widgets/panel/ride_tracking_panel.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/glass_card.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/common/rating_widget.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/info_card.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/ride_tracking_actions.dart';
import '../cards/vehicle_info_card.dart';
import '../buttons/ride_action_buttons.dart';
import 'communication_section.dart';


class RideTrackingPanel extends StatelessWidget {
  final RideTrackingState state;
  final RideTrackingActions actions;
  final bool hasRatedDuringRide;
  final int selectedStars;
  final String? selectedOptionId;
  final Function(int) onStarSelected;
  final Function(String) onOptionSelected;
  final VoidCallback onRatingSubmit;

  const RideTrackingPanel({
    super.key,
    required this.state,
    required this.actions,
    required this.hasRatedDuringRide,
    required this.selectedStars,
    required this.selectedOptionId,
    required this.onStarSelected,
    required this.onOptionSelected,
    required this.onRatingSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (state.isPassengerMode) ...[
                      const VehicleInfoCard(),
                      const SizedBox(height: 16),
                    ],
                    InfoCard(state: state),
                    const SizedBox(height: 16),
                    RideActionButtons(state: state, actions: actions),
                    const SizedBox(height: 16),
                    if (state.rideHasStarted) _buildEmbeddedRating(),
                    if (state.rideHasStarted) const SizedBox(height: 16),
                    CommunicationSection(state: state, actions: actions),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedRating() {
    final otherUserName = state.isPassengerMode
        ? state.driverName
        : state.passengerName;

    return RatingWidget(
      hasRated: hasRatedDuringRide,
      otherUserName: otherUserName,
      selectedStars: selectedStars,
      selectedOptionId: selectedOptionId,
      onStarSelected: onStarSelected,
      onOptionSelected: onOptionSelected,
      onSubmit: onRatingSubmit,
    );
  }
}
