// Driver Home Page

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/profile_picture_widgets.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/providers/driver_ws_provider.dart';
import 'package:srrfrr_app_front/core/services/websocket_service.dart';
import 'package:srrfrr_app_front/shared/widgets/app_drawer.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription? _wsStatusSubscription;
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _locationSubscription;
  Timer? _locationUpdateTimer;

  late final SnackBarService snackBarService;

  @override
  void initState() {
    super.initState();
    _checkDriverProfile();
    _initializeWebSocket();
    _initializeLocationTracking();
    snackBarService = SnackBarService(context);
  }

  @override
  void dispose() {
    try {
      if (mounted) {
        final wsProvider = context.read<DriverWsProvider>();
        wsProvider.clearOnRideConfirmedCallback();
      }
    } catch (e) {
      debugPrint('⚠️ Could not clear callback (widget disposed): $e');
    }

    _wsStatusSubscription?.cancel();
    _wsMessageSubscription?.cancel();
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  void _checkDriverProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final userProvider = context.read<UserProvider>();
        await userProvider.fetchDriverProfile();

        if (!mounted) return;

        if (!userProvider.isDriverValidated) {
          if (!userProvider.hasDriverProfile) {
            context.go('/driver-registration');
          } else {
            context.go('/driver-status');
          }
        }
      } catch (e) {
        debugPrint('[ERROR] Error checking profile: $e');
      }
    });
  }

  void _initializeWebSocket() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final userProvider = context.read<UserProvider>();
        final driverId = userProvider.currentUser?.id;

        if (driverId == null) {
          snackBarService.showError('Chat token missing');
          return;
        }

        final wsProvider = context.read<DriverWsProvider>();

        wsProvider.setOnRideConfirmedCallback(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              debugPrint(
                '⚠️ [DriverHome] Widget not mounted, skipping navigation',
              );
              return;
            }
            _navigateToRideTracking();
          });
        });

        wsProvider.connect(driverId);

        _wsStatusSubscription = wsProvider.statusStream.listen((status) {
          if (!mounted) return;
          if (status == WsConnectionStatus.connected) {
            debugPrint('✅ [DriverHome] WebSocket connected');
          } else if (status == WsConnectionStatus.error) {
            snackBarService.showError(
              AppLocalizations.of(context)!.connectionError,
            );
          }
        });
      } catch (e) {
        debugPrint('❌ [DriverHome] WebSocket init error: $e');
      }
    });
  }

  void _navigateToRideTracking() async {
    if (!mounted) return;

    try {
      final rideTrackingProvider = context.read<RideTrackingProvider>();

      if (rideTrackingProvider.rideId == null) {
        debugPrint('❌ [DriverHome] Cannot navigate - no ride ID');
        snackBarService.showError('Error: Missing ride data');
        return;
      }

      final passengerName = rideTrackingProvider.passengerName ?? 'Passenger';

      debugPrint('========================================');
      debugPrint('🚀 [DriverHome] NAVIGATING TO RIDE TRACKING');
      debugPrint('   - Ride ID: ${rideTrackingProvider.rideId}');
      debugPrint('   - Passenger: $passengerName');
      debugPrint('========================================');

      snackBarService.showSuccess('Ride confirmed with $passengerName!');
      context.go('/ride-tracking');
    } catch (e, stackTrace) {
      debugPrint('❌ [DriverHome] Navigation failed: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        snackBarService.showError('Navigation error');
      }
    }
  }

  void _initializeLocationTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }

        _startLocationUpdates();
      } catch (e) {
        debugPrint('[ERROR] Location initialization error: $e');
      }
    });
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();

    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;

      try {
        final wsProvider = context.read<DriverWsProvider>();
        if (!wsProvider.isOnline) return;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        wsProvider.updateLocation(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('[ERROR] Location update error: $e');
      }
    });
  }

  void _showCounterOfferDialog(BuildContext context, RideRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController priceController = TextEditingController();
    priceController.text = request.price.toStringAsFixed(0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(l10n.counterOfferTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.passengerOffer,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    '${request.price.toStringAsFixed(0)} DH',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.yourCounterOffer,
                hintText: l10n.enterYourPrice,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.money),
                suffixText: 'DH',
                helperText:
                    '${request.distanceKm.toStringAsFixed(1)}km · ${request.estimatedTime}',
              ),
              onSubmitted: (value) {
                final counterPrice = double.tryParse(value);
                if (counterPrice != null && counterPrice > 0) {
                  Navigator.pop(dialogContext);
                  _handleCounterOffer(context, request, counterPrice);
                }
              },
            ),

            const SizedBox(height: 8),

            Text(
              l10n.fairPriceTip,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final counterPrice = double.tryParse(priceController.text);
              if (counterPrice != null && counterPrice > 0) {
                Navigator.pop(dialogContext);
                _handleCounterOffer(context, request, counterPrice);
              } else {
                SnackBarService(context).showError(l10n.enterYourPrice);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.sendOffer),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCounterOffer(
    BuildContext context,
    RideRequest request,
    double counterPrice,
  ) async {
    final driverWsProvider = context.read<DriverWsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await driverWsProvider.sendCounterOffer(
      request.rideId,
      counterPrice,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (success && mounted) {
      snackBarService.showSuccess(
        '${AppLocalizations.of(context)!.sendOffer}: ${counterPrice.toStringAsFixed(0)} DH\n${AppLocalizations.of(context)!.waitingForResponse}...',
      );
    } else if (mounted) {
      snackBarService.showError(
        AppLocalizations.of(context)!.errorSendingOffer,
      );
    }
  }

  void _toggleOnlineStatus(DriverWsProvider wsProvider, bool newStatus) {
    final l10n = AppLocalizations.of(context)!;
    wsProvider.setOnlineStatus(newStatus);
    HapticFeedback.heavyImpact();

    final message = newStatus
        ? l10n.readyToAccept
        : l10n.offlineStatus;

    snackBarService.showInfo(message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Consumer<UserProvider>(
        builder: (context, userProvider, _) =>
            AppDrawer(user: userProvider.currentUser),
      ),
      body: Consumer<DriverWsProvider>(
        builder: (context, wsProvider, _) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 80,
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await context.read<UserProvider>().fetchDriverProfile();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: padding),

                        _buildOnlineToggleCard(wsProvider, padding, l10n),

                        SizedBox(height: padding * 1.5),

                        if (wsProvider.hasPendingOffer)
                          _buildPendingOfferCard(wsProvider, padding, l10n),

                        if (wsProvider.isOnline && !wsProvider.hasPendingOffer)
                          _buildRideRequestsSection(wsProvider, padding, l10n),

                        if (!wsProvider.isOnline)
                          _buildOfflineMessageCard(padding, l10n),

                        SizedBox(height: padding * 1.5),

                        _buildVehicleInfoCard(padding, l10n),

                        SizedBox(height: padding * 1.5),

                        _buildDriverStats(padding, l10n),

                        SizedBox(height: padding * 1.5),

                        _buildQuickActionsSection(padding, l10n),

                        SizedBox(height: padding * 2),
                      ],
                    ),
                  ),
                ),
              ),

              _buildTopBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
      left: AppSizes.paddingM,
      right: AppSizes.paddingM,
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
          final isVerified = userProvider.driverVerified;

          return Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                                pictureUrl,
                                fit: BoxFit.cover,
                                headers: const {'Accept': 'image/*'},
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary.withValues(
                                                    alpha: 0.5,
                                                  ),
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
                                        fontSize: 20,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),

                    if (isVerified)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 48,
                  height: 48,
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOnlineToggleCard(DriverWsProvider wsProvider, double padding, AppLocalizations l10n) {
    
    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: wsProvider.isOnline
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6B7280), const Color(0xFF4B5563)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color:
                (wsProvider.isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280))
                    .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  wsProvider.isOnline
                      ? Icons.online_prediction_rounded
                      : Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wsProvider.isOnline ? l10n.onlineMode : l10n.offlineMode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wsProvider.isOnline
                          ? l10n.readyToAccept
                          : l10n.activateToReceive,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _toggleOnlineStatus(wsProvider, !wsProvider.isOnline),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      wsProvider.isOnline
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      wsProvider.isOnline
                          ? l10n.goOffline
                          : l10n.goOnline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // VEHICLE INFORMATION CARD
  // ============================================================================

  Widget _buildVehicleInfoCard(double padding, AppLocalizations l10n) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final vehicleBrand = userProvider.vehicleBrand ?? 'N/A';
        final vehicleModel = userProvider.vehicleModel ?? 'N/A';
        final vehicleColor = userProvider.vehicleColor ?? 'N/A';
        final vehicleType = userProvider.vehicleType ?? 'auto';
        final productionYear = userProvider.productionYear ?? 'N/A';
        final registrationCode = userProvider.vehicleRegistrationCode ?? 'N/A';
        final vehiclePicturePath = userProvider.vehiclePicture;

        final hasValidVehiclePicture = UserProvider.isValidProfilePicture(
          vehiclePicturePath,
        );
        final vehiclePictureUrl = UserProvider.getProfilePictureUrl(
          vehiclePicturePath,
        );

        return Padding(
          padding: ResponsiveUtils.getResponsiveCardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: padding * 0.5, bottom: padding),
                child: Text(
                  l10n.myVehicle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(padding * 1.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(color: AppColors.grey200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Name & Picture
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: hasValidVehiclePicture
                                ? null
                                : AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusL,
                            ),
                          ),
                          child:
                              hasValidVehiclePicture &&
                                  vehiclePictureUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusL,
                                  ),
                                  child: Image.network(
                                    vehiclePictureUrl,
                                    fit: BoxFit.cover,
                                    headers: const {'Accept': 'image/*'},
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      AppColors.primary
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.directions_car_rounded,
                                        color: AppColors.primary,
                                        size: 28,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.directions_car_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$vehicleBrand $vehicleModel',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicleColor,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.grey200,
                            AppColors.grey200.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vehicle Details Grid - 2 columns, 2 rows each
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          child: Column(
                            children: [
                              _buildDetailRow(
                                label: l10n.registration,
                                value: registrationCode,
                                icon: Icons.pin_outlined,
                                l10n: l10n,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: l10n.type,
                                value: vehicleType.toUpperCase(),
                                icon: Icons.car_rental_outlined,
                                l10n: l10n,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Column
                        Expanded(
                          child: Column(
                            children: [
                              _buildDetailRow(
                                label: l10n.year,
                                value: productionYear,
                                icon: Icons.event_outlined,
                                l10n: l10n,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: l10n.colorLabel,
                                value: vehicleColor,
                                icon: Icons.palette_outlined,
                                l10n: l10n,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // DRIVER STATS WITH WALLET & TOTAL RIDES
  // ============================================================================

  Widget _buildDriverStats(double padding, AppLocalizations l10n) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final wallet = userProvider.driverWallet;
        final totalRides = userProvider.driverTotalRides;

        return Padding(
          padding: ResponsiveUtils.getResponsiveCardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: padding * 0.5, bottom: padding),
                child: Text(
                  l10n.statistics,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(padding * 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.account_balance_wallet_rounded,
                            '${wallet.toStringAsFixed(2)} DH',
                            l10n.driverWallet,
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.local_taxi_rounded,
                            totalRides.toString(),
                            l10n.totalRidesDriver,
                            const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPendingOfferCard(
    DriverWsProvider wsProvider,
    double padding,
    AppLocalizations l10n,
  ) {
    final pendingOffer = wsProvider.pendingOffer!;
    final secondsRemaining = pendingOffer.secondsRemainingForResponse ?? 0;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: Color(0xFFD97706),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.waitingForResponse,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.secondsRemaining(secondsRemaining),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD97706),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                wsProvider.cancelPendingOffer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
              label: Text(
                l10n.cancelOffer,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideRequestsSection(
    DriverWsProvider wsProvider,
    double padding,
    AppLocalizations l10n,
  ) {
    final requests = wsProvider.activeRequests;

    if (requests.isEmpty) {
      return _buildNoRequestsCard(padding, l10n);
    }

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: padding * 0.5, bottom: padding),
            child: Row(
              children: [
                Text(
                  l10n.activeRequests,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${requests.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...requests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRideRequestCard(request, wsProvider, padding, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideRequestCard(
    request,
    DriverWsProvider wsProvider,
    double padding,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfilePictureCard(
                imageUrl: request.passengerPhoto,
                fallbackText: request.passengerName ?? l10n.passengerDefault,
                size: 52,
                borderRadius: 26,
                gradientColors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                showShadow: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passengerName ?? l10n.passengerDefault,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.distanceKm?.toStringAsFixed(1) ?? '?'} km',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${request.price.round()} DH',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: AppColors.grey200, width: 1),
            ),
            child: Column(
              children: [
                _buildLocationRow(
                  Icons.trip_origin_rounded,
                  request.departure['address'] ?? l10n.unknownAddress,
                  const Color(0xFF10B981),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 22),
                      Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.3),
                              const Color(0xFFDC2626).withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLocationRow(
                  Icons.location_on_rounded,
                  request.destination['address'] ?? l10n.unknownAddress,
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    wsProvider.acceptRide(request.rideId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: Text(
                    l10n.acceptRide,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showCounterOfferDialog(context, request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.05,
                        ),
                      ),
                      icon: const Icon(Icons.request_quote_rounded, size: 20),
                      label: Text(
                        l10n.negotiateButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      wsProvider.declineRide(request.rideId);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                        color: Color(0xFFDC2626),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                      backgroundColor: const Color(
                        0xFFDC2626,
                      ).withValues(alpha: 0.05),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: Text(
                      l10n.refuseButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNoRequestsCard(double padding, AppLocalizations l10n) {
    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noRequests,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.searchingNearby,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        size: 14,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.notificationsActive,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMessageCard(double padding, AppLocalizations l10n) {
    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 28,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.offlineMode,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.goOnlineToReceive,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(double padding, AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: padding * 0.5, bottom: padding),
            child: Text(
              l10n.quickActions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  Icons.account_balance_wallet_rounded,
                  l10n.earnings,
                  const Color(0xFF10B981),
                  () {
                    HapticFeedback.lightImpact();
                    context.push('/driver/wallet');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.history_rounded,
                  l10n.historyDriver,
                  const Color(0xFF3B82F6),
                  () {
                    HapticFeedback.lightImpact();
                    context.push('/ride-history?source=driver');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.support_agent_rounded,
                  l10n.supportDriver,
                  const Color(0xFF8B5CF6),
                  () {
                    HapticFeedback.lightImpact();
                    context.push('/help-faq?source=driver');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
