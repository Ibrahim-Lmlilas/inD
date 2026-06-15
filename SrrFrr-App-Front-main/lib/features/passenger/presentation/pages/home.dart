/// Home Page - Passenger Ride Booking
///
/// Main interface for passengers to book rides with GPS location detection,
/// map-based selection, and ride configuration.
///
/// ## Features
/// - GPS location detection with auto-zoom
/// - Interactive map with route visualization
/// - Location search with Google Places
/// - Automatic ride type detection
/// - Dynamic pricing with validation
/// - Payment method selection

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/providers/map_provider.dart';
import 'package:srrfrr_app_front/features/passenger/data/models/ride_request.dart';
import 'package:srrfrr_app_front/features/passenger/data/repositories/ride_repository.dart';
import 'package:srrfrr_app_front/features/passenger/data/services/passenger_ws_service.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/driver_provider.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/passenger_ws_provider.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/ride_config_provider.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/widgets/location_input_card.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/widgets/map_selection_overlay.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/widgets/map_widget.dart';
// import 'package:srrfrr_app_front/features/passenger/presentation/widgets/passenger_drawer.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/widgets/ride_options_panel.dart';
import 'package:srrfrr_app_front/core/services/websocket_service.dart';
import 'package:srrfrr_app_front/shared/widgets/app_drawer.dart';

/// Home page for passenger ride booking
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final PanelController _panelController = PanelController();

  late final AnimationController _priceShakeController;
  late final Animation<double> _priceShakeAnimation;

  bool _isDisposed = false;
  VoidCallback? _mapListenerCallback;
  StreamSubscription? _wsStatusSubscription;

  // Lazy repository initialization
  RideRepository? _repository;
  RideRepository get _repo {
    _repository ??= RideRepository(
      PassengerWsService(context.read<PassengerWsProvider>()),
    );
    return _repository!;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      _initializeMap();
      _setupProviderListeners();
      _initializeWebSocket();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupListeners();
    _priceShakeController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  void _initializeAnimations() {
    _priceShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _priceShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _priceShakeController, curve: Curves.elasticIn),
    );
  }

  Future<void> _initializeMap() async {
    if (_isDisposed || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 30));
    if (_isDisposed || !mounted) return;

    try {
      final mapProvider = context.read<MapProvider>();
      mapProvider.setArcMode(true);
      await mapProvider.initializeLocation();
    } catch (e) {
      logError('HomePage', 'Error initializing map: $e');
      if (mounted && !_isDisposed) {
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(context).showError(l10n.errorLocationService);
      }
    }
  }

  Future<void> _setupProviderListeners() async {
    if (_isDisposed || !mounted) return;

    try {
      final mapProvider = context.read<MapProvider>();
      final rideConfigProvider = context.read<RideConfigProvider>();

      if (_isDisposed || !mounted) return;

      _mapListenerCallback = () {
        if (_isDisposed || !mounted) return;

        rideConfigProvider.detectRideType(
          mapProvider.pickupCity,
          mapProvider.destinationCity,
        );

        if (mapProvider.distance != null) {
          rideConfigProvider.updateDistance(mapProvider.distance);
        }
      };

      if (_isDisposed || !mounted) {
        _mapListenerCallback = null;
        return;
      }

      mapProvider.addListener(_mapListenerCallback!);
      logSuccess('HomePage', '✅ Provider listeners setup successfully');
    } catch (e) {
      logError('HomePage', 'Error setting up provider listeners: $e');
      _mapListenerCallback = null;
    }
  }

  Future<void> _initializeWebSocket() async {
    if (_isDisposed || !mounted) return;

    try {
      final wsProvider = context.read<PassengerWsProvider>();
      await wsProvider.connect();

      if (_isDisposed || !mounted) return;

      _wsStatusSubscription = wsProvider.statusStream.listen((status) {
        if (_isDisposed || !mounted) return;

        if (status == WsConnectionStatus.connected) {
          logSuccess('HomePage', '✅ WebSocket connected');
        } else if (status == WsConnectionStatus.error) {
          final l10n = AppLocalizations.of(context)!;
          SnackBarService(context).showError(l10n.errorOccurred);
        }
      });

      logSuccess('HomePage', '✅ WebSocket initialized successfully');
    } catch (e) {
      logError('HomePage', 'Error initializing WebSocket: $e');
    }
  }

  void _cleanupListeners() {
    if (_mapListenerCallback != null) {
      try {
        final mapProvider = context.read<MapProvider>();
        mapProvider.removeListener(_mapListenerCallback!);
      } catch (e) {
        logError('HomePage', 'Error removing map listener: $e');
      }
      _mapListenerCallback = null;
    }

    _wsStatusSubscription?.cancel();
    _wsStatusSubscription = null;
  }

  // ==========================================================================
  // EVENT HANDLERS
  // ==========================================================================

  void _onRideTypeSelected(String rideType) {
    if (_isDisposed || !mounted) return;
    context.read<RideConfigProvider>().setSelectedRideType(rideType);
  }

  void _increasePrice() {
    if (_isDisposed || !mounted) return;
    context.read<RideConfigProvider>().increasePrice();
    HapticFeedback.selectionClick();
  }

  void _decreasePrice() {
    if (_isDisposed || !mounted) return;

    final rideConfig = context.read<RideConfigProvider>();
    final minimumFare = rideConfig.minimumFare;

    if (rideConfig.offerPrice <= minimumFare) {
      _priceShakeController.forward().then((_) {
        if (!_isDisposed && mounted) {
          _priceShakeController.reverse();
        }
      });
      HapticFeedback.heavyImpact();
      return;
    }

    rideConfig.decreasePrice();
    HapticFeedback.selectionClick();
  }

  void _onContinueToOptions() {
    if (_isDisposed || !mounted) return;

    final mapProvider = context.read<MapProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (mapProvider.pickupLocation == null ||
        mapProvider.destinationLocation == null) {
      SnackBarService(context).showError(l10n.pleaseSelectBothLocations);
      return;
    }

    _panelController.open();
  }

  Future<void> _onRequestRide() async {
    if (_isDisposed || !mounted) return;

    final mapProvider = context.read<MapProvider>();
    final rideConfig = context.read<RideConfigProvider>();
    final userProvider = context.read<UserProvider>();
    final driverProvider = context.read<DriverProvider>();
    final wsProvider = context.read<PassengerWsProvider>();
    final l10n = AppLocalizations.of(context)!;

    // VALIDATION 1: Check locations
    if (mapProvider.pickupLocation == null ||
        mapProvider.destinationLocation == null) {
      SnackBarService(context).showError(l10n.pleaseSelectBothLocations);
      return;
    }

    // VALIDATION 2: Check distance
    if (mapProvider.distance == null || mapProvider.distance! <= 0) {
      SnackBarService(context).showError(l10n.unableToCalculateDistance);
      return;
    }

    // VALIDATION 3: Check ride type
    if (rideConfig.selectedRideType == null) {
      SnackBarService(context).showError(l10n.chooseRideType);
      return;
    }

    // VALIDATION 4: Check price
    final minimumFare = rideConfig.minimumFare;
    if (rideConfig.offerPrice < minimumFare) {
      SnackBarService(context).showError(
        l10n.minimumPriceIs(minimumFare),
      );
      return;
    }

    // VALIDATION 5: Validate free ride points
    if (rideConfig.selectedPaymentType == PaymentType.freeRide) {
      final availablePoints = userProvider.points;
      final requiredPoints = rideConfig.offerPrice;

      if (availablePoints < requiredPoints) {
        SnackBarService(context).showError(
          l10n.insufficientPointsForFreeRide(requiredPoints, availablePoints),
        );
        return;
      }

      logInfo(
        'HomePage',
        'Free ride validated: $availablePoints pts ≥ $requiredPoints pts',
      );
    }

    // VALIDATION 6: Check WebSocket connection
    if (wsProvider.connectionStatus != WsConnectionStatus.connected) {
      SnackBarService(context).showError(l10n.connectingToServer);
      await wsProvider.connect();
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted || _isDisposed) return;

      if (wsProvider.connectionStatus != WsConnectionStatus.connected) {
        SnackBarService(context).showError(l10n.unableToConnectToServer);
        return;
      }
    }

    // Build ride request (all values are now validated and non-null)
    final request = RideRequest(
      passengerId: userProvider.currentUser?.id ?? 'unknown',
      departure: LocationData(
        address: mapProvider.pickupLocation!,
        coordinates: mapProvider.pickupLatLng!,
        city: mapProvider.pickupCity,
      ),
      destination: LocationData(
        address: mapProvider.destinationLocation!,
        coordinates: mapProvider.destinationLatLng!,
        city: mapProvider.destinationCity,
      ),
      price: rideConfig.offerPrice,
      rideType: rideConfig.selectedRideType!,
      vehicleType: rideConfig.getVehicleTypeString(),
      seats: rideConfig.selectedSeats,
      distanceKm: mapProvider.distance!,
      estimatedTime: mapProvider.estimatedTime ?? '',
      paymentType: rideConfig.getPaymentTypeString(),
      timestamp: DateTime.now(),
    );

    // Close panel
    await _panelController.close();
    if (!mounted || _isDisposed) return;

    SnackBarService(context).showInfo(l10n.sendingRequest);

    // Submit via repository
    final result = await _repo.submitRideRequest(request);

    if (!mounted || _isDisposed) return;

    switch (result) {
      case RideSuccess(:final data):
        logSuccess('HomePage', 'Ride request successful: $data');

        // Load drivers and navigate
        await driverProvider.loadDrivers(data, rideConfig.offerPrice);

        if (mounted && !_isDisposed) {
          context.push('/driver-offers', extra: request.toNavigationData(data));
        }

      case RideFailure(:final message):
        SnackBarService(context).showError(message);
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isPhone = ResponsiveUtils.isPhone(context);

    return Scaffold(
      drawer: Selector<UserProvider, User?>(
        selector: (_, provider) => provider.currentUser,
        builder: (context, user, _) => AppDrawer(user: user),
      ),
      body: _buildBody(padding, isPhone),
    );
  }

  Widget _buildBody(double padding, bool isPhone) {
    final mapProvider = context.watch<MapProvider>();
    final rideConfig = context.watch<RideConfigProvider>();

    final canOpenPanel =
        mapProvider.pickupLocation != null &&
        mapProvider.destinationLocation != null;

    return SlidingUpPanel(
      controller: _panelController,
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.75,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXL),
      ),
      onPanelClosed: () => FocusScope.of(context).unfocus(),
      panel: RideOptionsPanel(
        pickupLocation: mapProvider.pickupLocation ?? '',
        destinationLocation: mapProvider.destinationLocation ?? '',
        pickupCity: mapProvider.pickupCity,
        destinationCity: mapProvider.destinationCity,
        distance: mapProvider.distance,
        estimatedTime: mapProvider.estimatedTime,
        selectedVehicleType: rideConfig.selectedVehicleType,
        selectedRideType: rideConfig.selectedRideType,
        offerPrice: rideConfig.offerPrice,
        selectedSeats: rideConfig.selectedSeats,
        priceShakeAnimation: _priceShakeAnimation,
        minimumFare: rideConfig.minimumFare,
        onRideTypeSelected: _onRideTypeSelected,
        onVehicleTypeChanged: (type) {
          if (!_isDisposed) {
            context.read<RideConfigProvider>().setVehicleType(type);
          }
        },
        onSeatsChanged: (seats) {
          if (!_isDisposed) {
            context.read<RideConfigProvider>().setSelectedSeats(seats);
          }
        },
        onPriceIncrease: _increasePrice,
        onPriceDecrease: _decreasePrice,
        onConfirm: _onRequestRide,
        onClose: () => _panelController.close(),
        canSubmit: canOpenPanel && rideConfig.isConfigurationComplete(),
        selectedPaymentType: rideConfig.selectedPaymentType,
        availablePoints: rideConfig.availablePoints,
        onPaymentTypeChanged: (paymentType) {
          if (!_isDisposed) {
            context.read<RideConfigProvider>().setPaymentType(paymentType);
          }
        },
      ),
      body: Stack(
        children: [
          const MapWidget(),
          if (mapProvider.isSelectingLocation)
            MapSelectionOverlay(
              selectionTarget: mapProvider.selectionTarget ?? '',
              isGeocoding: mapProvider.isGeocodingSelection,
              onCancel: () => context.read<MapProvider>().cancelMapSelection(),
              onConfirm: () =>
                  context.read<MapProvider>().confirmMapSelection(),
            ),
          if (mapProvider.isLoadingLocation && !mapProvider.isSelectingLocation)
            _LoadingIndicator(padding: padding),
          if (!mapProvider.isSelectingLocation) _TopBar(padding: padding),
          if (!mapProvider.isLoadingLocation &&
              !mapProvider.isSelectingLocation)
            _LocationInput(
              pickupLocation: mapProvider.pickupLocation,
              destinationLocation: mapProvider.destinationLocation,
              padding: padding,
            ),
          if (!mapProvider.isSelectingLocation)
            _ContinueButton(
              canOpenPanel: canOpenPanel,
              onPressed: _onContinueToOptions,
              padding: padding,
              isPhone: isPhone,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

class _LoadingIndicator extends StatelessWidget {
  final double padding;

  const _LoadingIndicator({required this.padding});

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top + (padding * 5);
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(width: padding),
              Text(l10n.locatingYourPosition),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double padding;

  const _TopBar({required this.padding});

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 48);

    return Positioned(
      top: MediaQuery.of(context).padding.top + padding,
      left: padding,
      right: padding,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;
          final profilePicturePath = user?.profilePhotoPath;
          final hasValidPicture = UserProvider.isValidProfilePicture(
            profilePicturePath,
          );
          final pictureUrl = UserProvider.getProfilePictureUrl(
            profilePicturePath,
          );
          final initial = UserProvider.getInitial(user?.firstName);

          return Row(
            children: [
              _ProfileAvatar(
                hasValidPicture: hasValidPicture,
                pictureUrl: pictureUrl,
                initial: initial,
                size: iconSize,
              ),
              const Spacer(),
              _MenuButton(size: iconSize),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final bool hasValidPicture;
  final String? pictureUrl;
  final String initial;
  final double size;

  const _ProfileAvatar({
    required this.hasValidPicture,
    required this.pictureUrl,
    required this.initial,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hasValidPicture ? null : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasValidPicture && pictureUrl != null
            ? ClipOval(
                child: Image.network(
                  pictureUrl!,
                  fit: BoxFit.cover,
                  headers: const {'Accept': 'image/*'},
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            20,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final double size;

  const _MenuButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.menu, color: AppColors.textPrimary),
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final String? pickupLocation;
  final String? destinationLocation;
  final double padding;

  const _LocationInput({
    this.pickupLocation,
    this.destinationLocation,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top + (padding * 5);

    return Positioned(
      top: topOffset,
      left: padding,
      right: padding,
      child: LocationInputCard(
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool canOpenPanel;
  final VoidCallback onPressed;
  final double padding;
  final bool isPhone;

  const _ContinueButton({
    required this.canOpenPanel,
    required this.onPressed,
    required this.padding,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isPhone ? 60.0 : 70.0;
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 18);
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      bottom: padding * 2,
      left: padding,
      right: padding,
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          boxShadow: canOpenPanel
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: canOpenPanel ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canOpenPanel
                ? AppColors.primary
                : AppColors.grey300,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward,
                size: 22,
                color: canOpenPanel ? Colors.white : AppColors.grey400,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Text(
                l10n.continueToOptions,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: canOpenPanel ? Colors.white : AppColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}