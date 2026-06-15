// Map Widget Component
//
// Displays Google Maps using MapProvider for state management.
// All map operations are handled through the provider.
// Supports map-based location selection with tap events.
// User can zoom in/out for precise location selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/map_provider.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.5731, -7.5898),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) {
            mapProvider.setMapController(controller);
          },
          onTap: (position) {
            if (mapProvider.isSelectingLocation) {
              HapticFeedback.selectionClick();
              mapProvider.updateTempSelection(position);
            }
          },
          markers: mapProvider.markers,
          polylines: mapProvider.polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 200,
            bottom: 200,
          ),
        );
      },
    );
  }
}
