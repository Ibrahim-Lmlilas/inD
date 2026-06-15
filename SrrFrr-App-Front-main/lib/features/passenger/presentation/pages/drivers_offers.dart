// Driver Offers Page
//
// This page displays real-time driver offers for a passenger's ride request.
//
// KEY FEATURES:
// - Real-time offer updates with automatic 60-second expiration
// - Dynamic price negotiation with counter-offers
// - Driver acceptance/rejection with backend synchronization
// - Request cancellation with proper cleanup
// - Automatic navigation to ride tracking after acceptance
// - Comprehensive data validation and error handling

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/ride_config_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/profile_picture_widgets.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/driver_provider.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/passenger_ws_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class DriverOffersPage extends StatefulWidget {
  final Map<String, dynamic> rideRequest;

  const DriverOffersPage({super.key, required this.rideRequest});

  @override
  State<DriverOffersPage> createState() => _DriverOffersPageState();
}

class _DriverOffersPageState extends State<DriverOffersPage> {
  static const int _offerTimeoutSeconds = 60;
  static const int _showPriceControlAfterSeconds = 60;

  Timer? _expirationTimer;
  Timer? _refreshTimer;
  Timer? _waitTimer;
  bool _isProcessing = false;
  int _currentPrice = 0;
  int _secondsSincePageOpened = 0;
  bool _canAdjustPrice = false;

  @override
  void initState() {
    super.initState();
    _initializePrice();
    _startExpirationTimer();
    _startRefreshTimer();
    _startWaitTimer();
    _setupWebSocketListeners();
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    _refreshTimer?.cancel();
    _waitTimer?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  void _initializePrice() {
    _currentPrice = widget.rideRequest['price'] as int? ?? 0;
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
    });
  }

  // Wait timer to track time since page opened
  void _startWaitTimer() {
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsSincePageOpened++;
      });

      // Enable price control after 60 seconds with no offers
      final driverProvider = context.read<DriverProvider>();
      if (_secondsSincePageOpened >= _showPriceControlAfterSeconds &&
          driverProvider.drivers.isEmpty &&
          !_canAdjustPrice) {
        setState(() {
          _canAdjustPrice = true;
        });
        logInfo('DriverOffers', '⏰ 60 seconds passed - enabling price control');

        if (mounted) {
          SnackBarService(
            context,
          ).showInfo('No offers yet. Try adjusting your price!');
        }
      }
    });
  }

  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final driverProvider = context.read<DriverProvider>();
      final expiredDrivers = driverProvider.drivers
          .where(
            (driver) => driver.secondsSinceReceived >= _offerTimeoutSeconds,
          )
          .toList();

      for (final driver in expiredDrivers) {
        _removeExpiredDriver(driver.id);
      }

      if (mounted) setState(() {});
    });
  }

  void _setupWebSocketListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final wsProvider = context.read<PassengerWsProvider>();

      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (!mounted || _isProcessing) {
          timer.cancel();
          return;
        }

        if (wsProvider.status == RideRequestStatus.cancelled) {
          timer.cancel();
          _handleRideCancelled();
        }
      });
    });
  }

  void _removeExpiredDriver(String driverId) {
    final userProvider = context.read<UserProvider>();
    final passengerId = userProvider.currentUser?.id ?? 'unknown';

    context.read<DriverProvider>().declineDriver(driverId, passengerId);

    if (mounted) {
      SnackBarService(context).showWarning('Offer expired');
    }
  }

  void _handleRideCancelled() {
    if (!mounted) return;

    SnackBarService(context).showError('La demande de course a été annulée.');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pop();
    });
  }

  void _increasePrice() {
    if (_isProcessing || !_canAdjustPrice) return;

    setState(() => _currentPrice += 1);
    HapticFeedback.selectionClick();
  }

  void _decreasePrice() {
    if (_isProcessing || !_canAdjustPrice) return;

    final driverProvider = context.read<DriverProvider>();
    final minimumPrice = driverProvider.passengerPrice;

    if (_currentPrice <= minimumPrice) {
      HapticFeedback.heavyImpact();
      SnackBarService(context).showWarning('Prix minimum : $minimumPrice DH');
      return;
    }

    setState(() => _currentPrice -= 1);
    HapticFeedback.selectionClick();
  }

  Future<void> _sendCounterOffer() async {
    if (_isProcessing) return;

    final userProvider = context.read<UserProvider>();
    final passengerId = userProvider.currentUser?.id ?? 'unknown';
    final rideConfig = context.read<RideConfigProvider>();
    final wsProvider = context.read<PassengerWsProvider>();

    // VALIDATE FREE RIDE COUNTER-OFFER
    if (rideConfig.selectedPaymentType == PaymentType.freeRide) {
      final availablePoints = userProvider.points;
      final requiredPoints = _currentPrice;

      if (availablePoints < requiredPoints) {
        if (mounted) {
          SnackBarService(context).showError(
            'Points insuffisants: ${requiredPoints}pts requis, vous avez ${availablePoints}pts',
          );
        }
        return;
      }

      logInfo(
        'DriverOffers',
        'Free ride counter-offer validated: $availablePoints pts ≥ $requiredPoints pts',
      );
    }

    setState(() => _isProcessing = true);

    // SEND COUNTER-OFFER WITH VALIDATION
    final success = await wsProvider.sendCounterOffer(
      passengerId,
      _currentPrice.toDouble(),
      userProvider.points,
      rideConfig.getPaymentTypeString(),
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (success) {
        SnackBarService(
          context,
        ).showSuccess('Nouvelle offre envoyée : $_currentPrice DH');
      } else {
        // Error message already set by sendCounterOffer
        SnackBarService(context).showError(
          wsProvider.errorMessage ?? 'Erreur lors de l\'envoi de l\'offre',
        );
      }
    }
  }

  // ========================================================================
  // ACCEPT DRIVER
  // ========================================================================

  Future<void> _acceptDriver(Driver driver) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final userProvider = context.read<UserProvider>();
      final passengerId = userProvider.currentUser?.id ?? 'unknown';

      final success = await context.read<DriverProvider>().acceptDriver(
        driver.id,
        passengerId,
      );

      if (!mounted) return;

      if (!success) {
        setState(() => _isProcessing = false);
        SnackBarService(
          context,
        ).showError('Erreur lors de l\'acceptation du conducteur');
        return;
      }

      final rideTrackingProvider = context.read<RideTrackingProvider>();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Confirmation de la course...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        void rideConfirmedListener() {
          if (!mounted) return;

          if (rideTrackingProvider.rideId != null &&
              rideTrackingProvider.isPassengerMode) {
            logSuccess('DriverOffers', 'Ride confirmed, navigating...');

            rideTrackingProvider.removeListener(rideConfirmedListener);
            Navigator.of(context).pop();
            context.go('/ride-tracking');
          }
        }

        rideTrackingProvider.addListener(rideConfirmedListener);

        Future.delayed(const Duration(seconds: 10), () {
          if (!mounted) return;

          if (_isProcessing && rideTrackingProvider.rideId == null) {
            rideTrackingProvider.removeListener(rideConfirmedListener);
            Navigator.of(context).pop();
            setState(() => _isProcessing = false);
            SnackBarService(context).showError(
              'Le délai de confirmation de la course est expiré. Veuillez réessayer.',
            );
          }
        });
      }
    } catch (e) {
      logError('DriverOffers', 'Error accepting driver: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isProcessing = false);
        SnackBarService(
          context,
        ).showError('Erreur lors de l\'acceptation du conducteur');
      }
    }
  }

  Future<void> _declineDriver(Driver driver) async {
    if (_isProcessing) return;

    HapticFeedback.lightImpact();

    final userProvider = context.read<UserProvider>();
    final passengerId = userProvider.currentUser?.id ?? 'unknown';

    await context.read<DriverProvider>().declineDriver(driver.id, passengerId);

    if (mounted) {
      SnackBarService(context).showInfo('Conducteur refusé');
    }
  }

  Future<void> _cancelRequest() async {
    HapticFeedback.heavyImpact();

    final userProvider = context.read<UserProvider>();
    final passengerId = userProvider.currentUser?.id ?? 'unknown';

    setState(() => _isProcessing = true);

    final success = await context.read<DriverProvider>().cancelRequest(
      passengerId,
    );

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      setState(() => _isProcessing = false);
      SnackBarService(
        context,
      ).showError('Erreur lors de l\'annulation de la demande');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: Column(
            children: [
              _PageHeader(onCancel: _cancelRequest),

              // Only show price control after 60s with no offers
              if (_canAdjustPrice)
                _PriceControlWidget(
                  currentPrice: _currentPrice,
                  onIncrease: _increasePrice,
                  onDecrease: _decreasePrice,
                  onApply: _sendCounterOffer,
                )
              else
                _WaitingForOffersWidget(
                  secondsElapsed: _secondsSincePageOpened,
                  secondsRemaining:
                      _showPriceControlAfterSeconds - _secondsSincePageOpened,
                ),

              Expanded(
                child: Consumer<DriverProvider>(
                  builder: (context, provider, _) {
                    if (provider.drivers.isEmpty) {
                      return const _EmptyStateWidget();
                    }

                    return _DriversList(
                      drivers: provider.drivers,
                      passengerPrice: _currentPrice,
                      timeoutSeconds: _offerTimeoutSeconds,
                      onAccept: _acceptDriver,
                      onDecline: _declineDriver,
                    );
                  },
                ),
              ),
              _BottomInfoBar(onCancel: _isProcessing ? null : _cancelRequest),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Waiting for Offers Widget
// ============================================================================

class _WaitingForOffersWidget extends StatelessWidget {
  final int secondsElapsed;
  final int secondsRemaining;

  const _WaitingForOffersWidget({
    required this.secondsElapsed,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                color: AppColors.primary,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'En attente des offres des conducteurs...',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  overflow:
                      TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: padding * 0.75),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: secondsElapsed / 60,
              minHeight: 6,
              backgroundColor: AppColors.grey100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          SizedBox(height: padding * 0.5),

          Text(
            secondsRemaining > 0
                ? 'Vous pouvez ajuster le prix dans ${secondsRemaining}s si aucune offre'
                : 'Vous pouvez maintenant ajuster votre prix',
            style: TextStyle(
              fontSize: fontSize * 0.86,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXISTING WIDGETS
// ============================================================================

class _PageHeader extends StatelessWidget {
  final VoidCallback onCancel;
  const _PageHeader({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 18);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.local_offer,
              color: AppColors.primary,
              size: iconSize,
            ),
          ),
          SizedBox(width: padding * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offres des conducteurs',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Consumer<DriverProvider>(
                  builder: (context, provider, _) {
                    return Text(
                      '${provider.drivers.length} driver${provider.drivers.length != 1 ? 's' : ''} available',
                      style: TextStyle(
                        fontSize: fontSize * 0.72,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceControlWidget extends StatelessWidget {
  final int currentPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onApply;

  const _PriceControlWidget({
    required this.currentPrice,
    required this.onIncrease,
    required this.onDecrease,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding * 0.75),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                ),
              ),
              SizedBox(width: padding * 0.75),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajustez votre offre',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Consumer<DriverProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          'Min: ${provider.passengerPrice} DH',
                          style: TextStyle(
                            fontSize: fontSize * 0.86,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PriceButton(icon: Icons.remove, onPressed: onDecrease),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding * 0.75),
                    child: Text(
                      '$currentPrice DH',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _PriceButton(icon: Icons.add, onPressed: onIncrease),
                ],
              ),
            ],
          ),

          SizedBox(height: padding * 0.75),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: padding * 0.875),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
              ),
              icon: Icon(
                Icons.send,
                size: ResponsiveUtils.getResponsiveIconSize(context, 18),
              ),
              label: Text(
                'Appliquer le prix',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _PriceButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

// ============================================================================
// MARK: - Drivers List Widget
// ============================================================================

class _DriversList extends StatelessWidget {
  final List<Driver> drivers;
  final int passengerPrice;
  final int timeoutSeconds;
  final Function(Driver) onAccept;
  final Function(Driver) onDecline;

  const _DriversList({
    required this.drivers,
    required this.passengerPrice,
    required this.timeoutSeconds,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemCount: drivers.length,
      separatorBuilder: (_, __) => SizedBox(height: padding * 0.75),
      itemBuilder: (context, index) {
        final driver = drivers[index];

        return _DriverOfferCard(
          driver: driver,
          passengerPrice: passengerPrice,
          timeoutSeconds: timeoutSeconds,
          onAccept: () => onAccept(driver),
          onDecline: () => onDecline(driver),
        );
      },
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 18);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 40);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: iconSize,
                color: AppColors.grey400,
              ),
            ),
            SizedBox(height: padding),
            Text(
              'Recherche de conducteurs',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: padding * 0.5),
            Text(
              'Les conducteurs à proximité apparaîtront ici',
              style: TextStyle(
                fontSize: fontSize * 0.78,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: padding * 1.5),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomInfoBar extends StatelessWidget {
  final VoidCallback? onCancel;

  const _BottomInfoBar({this.onCancel});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 12);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 16);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: iconSize,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Les offres expirent après 60 secondes',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: padding * 0.75),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(Icons.cancel_outlined, size: iconSize + 4),
              label: Text(
                'Annuler la demande',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: padding * 0.75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Driver Offer Card Widget
// ============================================================================

class _DriverOfferCard extends StatelessWidget {
  final Driver driver;
  final int passengerPrice;
  final int timeoutSeconds;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _DriverOfferCard({
    required this.driver,
    required this.passengerPrice,
    required this.timeoutSeconds,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final secondsRemaining = timeoutSeconds - driver.secondsSinceReceived;
    final progress = secondsRemaining / timeoutSeconds;
    final isExpiring = secondsRemaining < 15;
    final priceDiff = driver.suggestedPrice - passengerPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isExpiring
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.grey200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExpiring ? AppColors.error : Colors.black).withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _TimerProgressBar(progress: progress, isExpiring: isExpiring),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _DriverInfoRow(
                  driver: driver,
                  secondsRemaining: secondsRemaining,
                  isExpiring: isExpiring,
                ),
                SizedBox(height: padding),
                Row(
                  children: [
                    Expanded(child: _VehicleInfoCard(driver: driver)),
                    SizedBox(width: padding * 0.75),
                    Expanded(
                      child: _PriceCard(driver: driver, priceDiff: priceDiff),
                    ),
                  ],
                ),
                if (driver.isCounterOffer) ...[
                  SizedBox(height: padding),
                  const _CounterOfferBadge(),
                ],
                SizedBox(height: padding),
                _ActionButtons(onAccept: onAccept, onDecline: onDecline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Timer Progress Bar
// ============================================================================

class _TimerProgressBar extends StatelessWidget {
  final double progress;
  final bool isExpiring;

  const _TimerProgressBar({required this.progress, required this.isExpiring});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXL),
      ),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: AppColors.grey100,
        valueColor: AlwaysStoppedAnimation<Color>(
          isExpiring ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }
}

// ============================================================================
// MARK: - Driver Info Row
// ============================================================================

class _DriverInfoRow extends StatelessWidget {
  final Driver driver;
  final int secondsRemaining;
  final bool isExpiring;

  const _DriverInfoRow({
    required this.driver,
    required this.secondsRemaining,
    required this.isExpiring,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 17);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 16);

    return Row(
      children: [
        _DriverAvatar(driver: driver),
        SizedBox(width: padding * 0.75),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: iconSize, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    driver.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: fontSize * 0.82,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    size: iconSize * 0.88,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${driver.vehicle['totalRides'] ?? 0} rides',
                      style: TextStyle(
                        fontSize: fontSize * 0.76,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _TimerBadge(secondsRemaining: secondsRemaining, isExpiring: isExpiring),
      ],
    );
  }
}

// ============================================================================
// MARK: - Driver Avatar
// ============================================================================

class _DriverAvatar extends StatelessWidget {
  final Driver driver;

  const _DriverAvatar({required this.driver});

  @override
  Widget build(BuildContext context) {
    // Extract profile picture from driver data
    final driverName = driver.name;
    final profilePictureUrl = driver.vehicle['profilePicture'] as String?;

    return ProfilePictureCard(
      imageUrl: profilePictureUrl,
      fallbackText: driverName,
      size: 56,
      borderRadius: 28, // Half of size = circular
      gradientColors: [
        AppColors.primary,
        AppColors.primary.withValues(alpha: 0.7),
      ],
      showShadow: true,
    );
  }
}

// ============================================================================
// MARK: - Timer Badge
// ============================================================================

class _TimerBadge extends StatelessWidget {
  final int secondsRemaining;
  final bool isExpiring;

  const _TimerBadge({required this.secondsRemaining, required this.isExpiring});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 16);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 0.75,
        vertical: padding * 0.375,
      ),
      decoration: BoxDecoration(
        color: (isExpiring ? AppColors.error : AppColors.grey100).withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isExpiring
              ? AppColors.error.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: iconSize,
            color: isExpiring ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${secondsRemaining}s',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: isExpiring ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Vehicle Info Card
// ============================================================================

class _VehicleInfoCard extends StatelessWidget {
  final Driver driver;

  const _VehicleInfoCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    // Combine brand and model into single line
    final vehicleInfo = driver.vehicle['model'] ?? 'N/A';
    final vehicleColor = driver.vehicle['color'] ?? '';

    return Container(
      padding: EdgeInsets.all(padding * 0.75),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.directions_car,
              color: AppColors.primary,
              size: iconSize,
            ),
          ),
          SizedBox(width: padding * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vehicleInfo,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (vehicleColor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    vehicleColor,
                    style: TextStyle(
                      fontSize: fontSize * 0.86,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Price Card
// ============================================================================

class _PriceCard extends StatelessWidget {
  final Driver driver;
  final int priceDiff;

  const _PriceCard({required this.driver, required this.priceDiff});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Container(
      padding: EdgeInsets.all(padding * 0.75),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.monetization_on,
              color: AppColors.success,
              size: iconSize,
            ),
          ),
          SizedBox(width: padding * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${driver.suggestedPrice} DH',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (priceDiff != 0)
                  Text(
                    '${priceDiff > 0 ? '+' : ''}$priceDiff DH',
                    style: TextStyle(
                      fontSize: fontSize * 0.86,
                      fontWeight: FontWeight.w600,
                      color: priceDiff > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  )
                else
                  Text(
                    driver.isCounterOffer ? 'Contre-offre' : 'Prix initial',
                    style: TextStyle(
                      fontSize: fontSize * 0.86,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Counter Offer Badge
// ============================================================================

class _CounterOfferBadge extends StatelessWidget {
  const _CounterOfferBadge();

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 13);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 16);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 0.75,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_alt, size: iconSize, color: AppColors.warning),
          SizedBox(width: padding * 0.5),
          Expanded(
            child: Text(
              'Contre-offre du conducteur',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK: - Action Buttons
// ============================================================================

class _ActionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ActionButtons({required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 15);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 20);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error, width: 1.5),
              padding: EdgeInsets.symmetric(vertical: padding * 0.875),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: Text(
              'Refuser',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: padding * 0.75),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: padding * 0.875),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: iconSize),
                SizedBox(width: padding * 0.5),
                Text(
                  'Accepter',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
