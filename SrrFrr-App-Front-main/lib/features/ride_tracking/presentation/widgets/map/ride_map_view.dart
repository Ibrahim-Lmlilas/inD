// features/ride_tracking/presentation/widgets/map/ride_map_view.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';

class RideMapView extends StatelessWidget {
  final RideTrackingState state;
  final double screenHeight;
  final bool isDisposed;

  const RideMapView({
    super.key,
    required this.state,
    required this.screenHeight,
    required this.isDisposed,
  });

  @override
  Widget build(BuildContext context) {
    final initialPosition = state.isPassengerMode
        ? (state.departure != null
              ? LatLng(
                  state.departure!['latitude'] as double,
                  state.departure!['longitude'] as double,
                )
              : const LatLng(33.5731, -7.5898))
        : (state.destination != null
              ? LatLng(
                  state.destination!['latitude'] as double,
                  state.destination!['longitude'] as double,
                )
              : const LatLng(33.5731, -7.5898));

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14),
      markers: state.markers,
      polylines: state.polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 140,
        bottom: screenHeight * 0.45 + 20,
      ),
      onMapCreated: (controller) {
        if (isDisposed) return;
        final provider = context.read<RideTrackingProvider>();
        provider.setMapController(controller);
      },
    );
  }
}
