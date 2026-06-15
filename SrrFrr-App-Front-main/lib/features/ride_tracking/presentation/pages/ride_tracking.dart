// Ride Tracking Page
//
// Features:
// - Users can rate at any time during the ride
// - Cancellation requires submitting a report first via bottom sheet
// - Shows rating dialog on ride completion
// - Only completed rides navigate away automatically
// - Navigation buttons only visible to drivers
// - Draggable/slidable bottom panel (30%-70% of screen)
// - Double back press to exit app

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/route_info_card.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/common/loading_overlay.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/common/loading_screen.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/map/ride_map_view.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/info_card.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/panel/ride_tracking_panel.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/ride_tracking_actions.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/ride_tracking_dialogs.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';


class RideTrackingPage extends StatefulWidget {
  const RideTrackingPage({super.key});

  @override
  State<RideTrackingPage> createState() => _RideTrackingPageState();
}

class _RideTrackingPageState extends State<RideTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late RideTrackingActions _actions;

  final PanelController _panelController = PanelController();

  bool _isDisposed = false;
  bool _callbacksRegistered = false;
  bool _hasRatedDuringRide = false;

  // Embedded rating state
  int _selectedStars = 0;
  String? _selectedOptionId;

  // Back button handling
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _actions = RideTrackingActions(context);
    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      _registerRideCallbacks();
      context.read<RatingProvider>().loadRatingValues();
    });
  }

  @override
  void dispose() {
    logCritical('RideTracking', '🗑️ dispose called');
    _isDisposed = true;

    if (mounted) {
      try {
        final rideProvider = context.read<RideTrackingProvider>();
        rideProvider.clearCallbacks();
        logSuccess('RideTracking', '✅ Callbacks cleared in dispose');
      } catch (e) {
        logWarning('RideTracking', '⚠️ Could not clear callbacks: $e');
      }
    }

    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = context.read<UserProvider>();
    final rideProvider = context.read<RideTrackingProvider>();

    if (rideProvider.rideId == null && userProvider.activeRideData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isDisposed) return;
        _initializeFromActiveRide(userProvider, rideProvider);
      });
    }

    if (!_callbacksRegistered && rideProvider.rideId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isDisposed) return;
        _registerRideCallbacks();
      });
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeFromActiveRide(
    UserProvider userProvider,
    RideTrackingProvider rideProvider,
  ) {
    final activeRide = userProvider.activeRideData;
    if (activeRide == null) return;

    final payload = {
      'rideId': activeRide['id'],
      'driverId': activeRide['driverId'],
      'passengerId': activeRide['passengerId'],
      'price': activeRide['price'],
      'rideType': activeRide['rideType'],
      'vehicleType': activeRide['vehicleType'],
      'seats': activeRide['seats'],
      'distanceKm': activeRide['distanceKm'],
      'estimatedTime': activeRide['estimatedTime'],
      'channelId': activeRide['channelId'],
      'wsToken': activeRide['wsToken'],
      'status': activeRide['status'],
      'departure': {
        'address': activeRide['departureAddress'],
        'latitude': activeRide['departureLat'],
        'longitude': activeRide['departureLng'],
        'city': activeRide['departureCity'],
      },
      'destination': {
        'address': activeRide['destinationAddress'],
        'latitude': activeRide['destinationLat'],
        'longitude': activeRide['destinationLng'],
        'city': activeRide['destinationCity'],
      },
      'passenger': activeRide['passenger'],
      'driver': activeRide['driver'],
    };

    rideProvider.initializeRide(payload, null);
    userProvider.clearActiveRideData();

    logSuccess('RideTracking', '✅ Active ride initialized successfully');
  }

  void _registerRideCallbacks() {
    if (_callbacksRegistered || !mounted || _isDisposed) return;

    try {
      final provider = context.read<RideTrackingProvider>();

      provider.setOnRideCancelledCallback((data) {
        if (!mounted || _isDisposed) return;
        _handleRideCancelled(data);
      });

      provider.setOnApproachingDestinationCallback((data) {
        if (!mounted || _isDisposed) return;
        _handleApproachingDestination(data);
      });

      provider.setOnRideCompletedCallback((data) {
        if (!mounted || _isDisposed) return;
        _handleRideCompleted(data);
      });

      _callbacksRegistered = true;
      logSuccess('RideTracking', '✅ Callbacks registered');
    } catch (e) {
      logError('RideTracking', '❌ Failed to register callbacks: $e');
    }
  }

  void _handleRideCompleted(Map<String, dynamic> data) {
    if (!mounted || _isDisposed) return;

    final userProvider = context.read<UserProvider>();
    userProvider.refreshUserProfile();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RideCompletionDialog(
        data: data,
        hasRatedDuringRide: _hasRatedDuringRide,
      ),
    );
  }

  void _handleApproachingDestination(Map<String, dynamic> data) {
    if (!mounted || _isDisposed) return;

    final distance = data['distance'] as double?;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Vous êtes arrivé à destination! (${(distance! * 1000).toStringAsFixed(0)}m)',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Terminer',
          textColor: Colors.white,
          onPressed: () => _actions.onDriverFinishRide(),
        ),
      ),
    );
  }

  void _handleRideCancelled(Map<String, dynamic> data) {
    if (!mounted || _isDisposed) return;

    final cancelledBy = data['userId'] as String?;
    final reason = data['reason'] as String?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RideCancellationDialog(cancelledBy: cancelledBy, reason: reason),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isDisposed || !mounted) return true;

    final shouldExit = await _actions.handleBackPress(_lastBackPress);
    if (!shouldExit) {
      setState(() => _lastBackPress = DateTime.now());
    }
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        body: Selector<RideTrackingProvider, RideTrackingState>(
          selector: (_, provider) => RideTrackingState(
            rideId: provider.rideId,
            driverIsValidated: provider.driverIsValidated,
            isPassengerMode: provider.isPassengerMode,
            driverName: provider.driverName,
            passengerName: provider.passengerName,
            driverProfilePicture: provider.driverProfilePicture,
            passengerProfilePicture: provider.passengerProfilePicture,
            driverRating: provider.driverRating,
            passengerRating: provider.passengerRating,
            driverPhone: provider.driverPhone,
            passengerPhone: provider.passengerPhone,
            driverId: provider.driverId,
            passengerId: provider.passengerId,
            etaMinutes: provider.etaMinutes,
            distanceKm: provider.distanceKm,
            departure: provider.departure,
            destination: provider.destination,
            markers: provider.markers,
            polylines: provider.polylines,
            isLoading: provider.isLoading,
            driverHasArrived: provider.driverHasArrived,
            passengerIsComing: provider.passengerIsComing,
            rideHasStarted: provider.rideHasStarted,
            driverTotalRides: provider.driverTotalRides,
            passengerTotalRides: provider.passengerTotalRides,
          ),
          builder: (context, state, _) {
            if (state.rideId == null) {
              return RideTrackingLoadingScreen(pulseAnimation: _pulseAnimation);
            }

            final screenHeight = MediaQuery.of(context).size.height;

            return SlidingUpPanel(
              controller: _panelController,
              minHeight: screenHeight * 0.30,
              maxHeight: screenHeight * 0.70,
              defaultPanelState: PanelState.OPEN,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              parallaxEnabled: false,
              backdropEnabled: false,
              panel: RideTrackingPanel(
                state: state,
                actions: _actions,
                hasRatedDuringRide: _hasRatedDuringRide,
                selectedStars: _selectedStars,
                selectedOptionId: _selectedOptionId,
                onStarSelected: (stars) {
                  setState(() {
                    _selectedStars = stars;
                    _selectedOptionId = null;
                  });
                  context.read<RatingProvider>().loadRatingValues(level: stars);
                },
                onOptionSelected: (optionId) {
                  setState(() => _selectedOptionId = optionId);
                },
                onRatingSubmit: () async {
                  final success = await _actions.submitRating(
                    selectedStars: _selectedStars,
                    selectedOptionId: _selectedOptionId,
                  );
                  if (success) {
                    setState(() => _hasRatedDuringRide = true);
                  }
                },
              ),
              body: Stack(
                children: [
                  RideMapView(
                    state: state,
                    screenHeight: screenHeight,
                    isDisposed: _isDisposed,
                  ),
                  RouteInfoCard(
                    departureAddress: state.departure?['address'],
                    destinationAddress: state.destination?['address'],
                  ),
                  if (state.isLoading) const RideTrackingLoadingOverlay(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}