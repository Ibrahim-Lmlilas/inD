// features/ride_tracking/presentation/widgets/panel/ride_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/buttons/driver_action_buttons.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/buttons/passenger_action_buttons.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/ride_tracking_actions.dart';

class RideActionButtons extends StatelessWidget {
  final RideTrackingState state;
  final RideTrackingActions actions;

  const RideActionButtons({
    super.key,
    required this.state,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.read<RideTrackingProvider>();

    if (!state.isPassengerMode) {
      // Driver flow
      if (!rideProvider.driverHasArrived && !rideProvider.rideHasStarted) {
        return DriverApproachingButton(
          distanceKm: state.distanceKm,
          onConfirmArrival: () => actions.onDriverConfirmArrival(),
        );
      }

      if (rideProvider.passengerIsComing && !rideProvider.rideHasStarted) {
        return DriverStartRideButton(
          onStartRide: () => actions.onDriverStartRide(),
        );
      }

      if (rideProvider.rideHasStarted) {
        return DriverFinishRideButton(
          distanceKm: state.distanceKm,
          onFinishRide: () => actions.onDriverFinishRide(),
        );
      }
    } else {
      // Passenger flow
      if (rideProvider.driverHasArrived && !rideProvider.passengerIsComing) {
        return PassengerNotifyComingButton(
          onNotifyComing: () => actions.onPassengerNotifyComing(),
        );
      }
    }

    return const SizedBox.shrink();
  }
}