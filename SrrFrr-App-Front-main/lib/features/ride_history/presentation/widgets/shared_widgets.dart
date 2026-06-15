/// Ride History Shared Components
///
/// Contains all reusable UI components and data models for ride history pages.
/// Used by both RideHistoryPassengerPage and RideHistoryDriverPage.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/core/utils/map_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

enum RideStatus { completed, canceled, inProgress }

extension RideStatusExtension on RideStatus {
  static RideStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'ACCEPTED':
        return RideStatus.completed;
      case 'CANCELED':
        return RideStatus.canceled;
      case 'IN_PROGRESS':
      case 'PENDING':
      case 'STARTED':
        return RideStatus.inProgress;
      default:
        return RideStatus.inProgress;
    }
  }
}

class RideHistoryItem {
  final String id;
  final DateTime date;
  final RideStatus status;
  final String pickupLocation;
  final String dropoffLocation;
  final double distance;
  final String vehicleType;
  final String driverName;
  final String driverId;
  final double driverRating;
  final String driverPhone;
  final String passengerName;
  final String passengerId;
  final String passengerPhone;
  final double fareAmount;
  final String paymentMethod;
  final List<LatLng> routePoints;
  final bool isRated;

  RideHistoryItem({
    required this.id,
    required this.date,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.vehicleType,
    required this.driverName,
    required this.driverId,
    required this.driverRating,
    required this.driverPhone,
    required this.passengerName,
    required this.passengerId,
    required this.passengerPhone,
    required this.fareAmount,
    required this.paymentMethod,
    required this.routePoints,
    required this.isRated,
  });

  factory RideHistoryItem.fromJson(
    Map<String, dynamic> json, {
    required bool isDriverMode,
    required AppLocalizations l10n,
  }) {

    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now();

    final statusStr = json['status'] as String? ?? 'IN_PROGRESS';
    final status = RideStatusExtension.fromString(statusStr);

    final departureAddress =
        json['departureAddress'] as String? ?? l10n.departure;
    final destinationAddress =
        json['destinationAddress'] as String? ?? l10n.arrival;

    final distanceKm = (json['distanceKm'] as num?)?.toDouble() ?? 0.0;
    final vehicleType = json['vehicleType'] as String? ?? 'auto';

    String passengerName = l10n.passengerDefault;
    String passengerId = '';
    String passengerPhone = '';

    if (json['passenger'] != null) {
      final passenger = json['passenger'] as Map<String, dynamic>;
      passengerName =
          '${passenger['firstName'] ?? ''} ${passenger['lastName'] ?? ''}'
              .trim();
      passengerId = passenger['id'] as String? ?? '';
      passengerPhone = passenger['phoneNumber'] as String? ?? '';
    }

    String driverName = l10n.driverDefault;
    String driverId = '';
    double driverRating = 0.0;
    String driverPhone = '';

    if (json['driver'] != null) {
      final driver = json['driver'] as Map<String, dynamic>;
      driverName = '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'
          .trim();
      driverId = driver['id'] as String? ?? '';
      driverRating = (driver['rating'] as num?)?.toDouble() ?? 0.0;
      driverPhone = driver['phoneNumber'] as String? ?? '';
    }

    final price = (json['price'] as num?)?.toDouble() ?? 0.0;

    final paymentType = json['paymentType'] as String? ?? 'CASH';
    final paymentMethod = paymentType == 'CASH' ? l10n.cash : l10n.creditCard;

    final routePoints = <LatLng>[];
    final departureLat = (json['departureLat'] as num?)?.toDouble();
    final departureLng = (json['departureLng'] as num?)?.toDouble();
    final destinationLat = (json['destinationLat'] as num?)?.toDouble();
    final destinationLng = (json['destinationLng'] as num?)?.toDouble();

    if (departureLat != null && departureLng != null) {
      routePoints.add(LatLng(departureLat, departureLng));
    }
    if (destinationLat != null && destinationLng != null) {
      routePoints.add(LatLng(destinationLat, destinationLng));
    }

    return RideHistoryItem(
      id: json['id'] as String,
      date: createdAt,
      status: status,
      pickupLocation: departureAddress,
      dropoffLocation: destinationAddress,
      distance: distanceKm,
      vehicleType: vehicleType,
      passengerName: passengerName,
      passengerId: passengerId,
      passengerPhone: passengerPhone,
      driverName: driverName,
      driverId: driverId,
      driverRating: driverRating,
      driverPhone: driverPhone,
      fareAmount: price,
      paymentMethod: paymentMethod,
      routePoints: routePoints,
      isRated: json['isRated'] as bool? ?? false,
    );
  }
}

// ============================================================================
// STATS HEADER
// ============================================================================

class StatsHeader extends StatelessWidget {
  final int totalRides;
  final double totalAmount;
  final bool isDriver;
  final double padding;

  const StatsHeader({
    super.key,
    required this.totalRides,
    required this.totalAmount,
    required this.isDriver,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
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
            Expanded(
              child: StatItem(
                icon: Icons.route,
                label: l10n.totalRidesLabel,
                value: totalRides.toString(),
                color: AppColors.primary,
              ),
            ),
            Container(
              height: 50,
              width: 1,
              color: AppColors.grey300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Expanded(
              child: StatItem(
                icon: Icons.payments,
                label: isDriver ? l10n.totalEarned : l10n.totalSpent,
                value: '${totalAmount.toStringAsFixed(0)} MAD',
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ============================================================================
// FILTERS SECTION
// ============================================================================

class FiltersSection extends StatelessWidget {
  final String selectedStatus;
  final String selectedPayment;
  final String selectedVehicle;
  final String sortBy;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPaymentChanged;
  final ValueChanged<String> onVehicleChanged;
  final ValueChanged<String> onSortChanged;
  final double padding;

  const FiltersSection({
    super.key,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.selectedVehicle,
    required this.sortBy,
    required this.onStatusChanged,
    required this.onPaymentChanged,
    required this.onVehicleChanged,
    required this.onSortChanged,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filtersTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            FilterRow(
              label: l10n.statusLabel,
              value: selectedStatus,
              options: [
                l10n.statusAll,
                l10n.statusCompleted,
                l10n.statusCancelled,
                l10n.statusInProgress,
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 12),
            FilterRow(
              label: l10n.paymentLabel,
              value: selectedPayment,
              options: [l10n.paymentAll, l10n.paymentCard, l10n.paymentCash],
              onChanged: onPaymentChanged,
            ),
            const SizedBox(height: 12),
            FilterRow(
              label: l10n.vehicleLabel,
              value: selectedVehicle,
              options: [
                l10n.vehicleAll,
                l10n.vehicleStandard,
                l10n.vehiclePremium,
                l10n.vehicleLadiesOnly,
              ],
              onChanged: onVehicleChanged,
            ),
            const SizedBox(height: 12),
            FilterRow(
              label: l10n.sortByLabel,
              value: sortBy,
              options: [
                l10n.sortDateNewestFirst,
                l10n.sortDateOldestFirst,
                l10n.sortPriceHighToLow,
                l10n.sortPriceLowToHigh,
                l10n.sortDistance,
              ],
              onChanged: onSortChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const FilterRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.grey300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                items: options.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    HapticFeedback.lightImpact();
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// RIDE CARD
// ============================================================================

class RideCard extends StatelessWidget {
  final RideHistoryItem ride;
  final bool isExpanded;
  final bool canRate;
  final bool isDriverMode;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRate;
  final VoidCallback onSupport;

  const RideCard({
    super.key,
    required this.ride,
    required this.isExpanded,
    required this.canRate,
    required this.isDriverMode,
    required this.onToggleExpanded,
    required this.onRate,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: canRate
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(status: ride.status),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM yyyy').format(ride.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LocationRow(
                    icon: Icons.circle,
                    iconColor: const Color(0xFF10B981),
                    location: ride.pickupLocation,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 6),
                        SizedBox(
                          width: 2,
                          height: 20,
                          child: ColoredBox(color: AppColors.grey300),
                        ),
                      ],
                    ),
                  ),
                  LocationRow(
                    icon: Icons.location_on,
                    iconColor: const Color(0xFFEF4444),
                    location: ride.dropoffLocation,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InfoChip(icon: Icons.local_taxi, text: ride.vehicleType),
                      if (ride.distance > 0) ...[
                        const SizedBox(width: 8),
                        InfoChip(
                          icon: Icons.route,
                          text: '${ride.distance.toStringAsFixed(1)} km',
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${ride.fareAmount.toStringAsFixed(0)} MAD',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (canRate) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.rateThisTrip,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded)
            ExpandedRideDetails(
              ride: ride,
              canRate: canRate,
              isDriverMode: isDriverMode,
              onRate: onRate,
              onSupport: onSupport,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXPANDED RIDE DETAILS
// ============================================================================

class ExpandedRideDetails extends StatefulWidget {
  final RideHistoryItem ride;
  final bool canRate;
  final bool isDriverMode;
  final VoidCallback onRate;
  final VoidCallback onSupport;

  const ExpandedRideDetails({
    super.key,
    required this.ride,
    required this.canRate,
    required this.isDriverMode,
    required this.onRate,
    required this.onSupport,
  });

  @override
  State<ExpandedRideDetails> createState() => _ExpandedRideDetailsState();
}

class _ExpandedRideDetailsState extends State<ExpandedRideDetails> {
  GoogleMapController? _mapController;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  Set<Marker> get _markers {
    if (widget.ride.routePoints.isEmpty) return {};

    return {
      // Point A (Departure)
      MapUtils.createPickupMarker(
        position: widget.ride.routePoints.first,
        address: widget.ride.pickupLocation,
      ),
      // Point B (Destination)
      if (widget.ride.routePoints.length > 1)
        MapUtils.createDestinationMarker(
          position: widget.ride.routePoints.last,
          address: widget.ride.dropoffLocation,
        ),
    };
  }

  Future<void> _fitBounds() async {
    if (_mapController == null || widget.ride.routePoints.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted || _isDisposed) return;

    // Fit to show both markers
    await MapUtils.fitBounds(
      controller: _mapController!,
      coordinates: widget.ride.routePoints,
      padding: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayName = widget.isDriverMode
        ? widget.ride.passengerName
        : widget.ride.driverName;
    final displayPhone = widget.isDriverMode
        ? widget.ride.passengerPhone
        : widget.ride.driverPhone;
    final displayRating = widget.isDriverMode ? null : widget.ride.driverRating;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusL),
          bottomRight: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),

          // Map Section - Simplified (A→B markers only)
          if (widget.ride.routePoints.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Text(
                l10n.viewTripLocation,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.ride.routePoints.first,
                      zoom: 12,
                    ),
                    markers: _markers,
                    polylines: {},
                    onMapCreated: (controller) {
                      if (_isDisposed) return;
                      _mapController = controller;
                      _fitBounds();
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // Ride Details
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              0,
              AppSizes.paddingL,
              AppSizes.paddingM,
            ),
            child: Text(
              l10n.rideDetails,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: Column(
              children: [
                DetailRow(
                  icon: Icons.person,
                  label: widget.isDriverMode
                      ? l10n.passengerLabel
                      : l10n.driverLabel,
                  value: displayName,
                ),
                if (displayRating != null) ...[
                  const SizedBox(height: 8),
                  DetailRow(
                    icon: Icons.star,
                    label: l10n.ratingLabel,
                    value: '${displayRating.toStringAsFixed(1)} ⭐',
                  ),
                ],
                const SizedBox(height: 8),
                DetailRow(
                  icon: Icons.phone,
                  label: l10n.phoneLabel,
                  value: displayPhone,
                ),
              ],
            ),
          ),

          // Payment Details
          if (widget.ride.status == RideStatus.completed) ...[
            const SizedBox(height: AppSizes.paddingL),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Text(
                l10n.fareDetails,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.ride.fareAmount.toStringAsFixed(0)} MAD',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          const SizedBox(height: AppSizes.paddingL),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.canRate)
                  ActionButton(
                    icon: Icons.star,
                    label: l10n.rateButton,
                    onTap: widget.onRate,
                    isPrimary: true,
                  ),
                if (widget.ride.status == RideStatus.completed ||
                    widget.ride.status == RideStatus.canceled)
                  ActionButton(
                    icon: Icons.support_agent,
                    label: l10n.complaintButton,
                    onTap: widget.onSupport,
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
// SUPPORTING WIDGETS
// ============================================================================

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final RideStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (bgColor, textColor, label, icon) = switch (status) {
      RideStatus.completed => (
        const Color(0xFF10B981).withValues(alpha: 0.1),
        const Color(0xFF10B981),
        l10n.statusCompletedBadge,
        Icons.check_circle,
      ),
      RideStatus.canceled => (
        const Color(0xFFEF4444).withValues(alpha: 0.1),
        const Color(0xFFEF4444),
        l10n.statusCancelledBadge,
        Icons.cancel,
      ),
      RideStatus.inProgress => (
        const Color(0xFFFBBF24).withValues(alpha: 0.1),
        const Color(0xFFFBBF24),
        l10n.statusInProgressBadge,
        Icons.hourglass_empty,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String location;

  const LocationRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? AppColors.primary
                      : AppColors.textSecondary,
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

class EmptyState extends StatelessWidget {
  final double padding;

  const EmptyState({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTripsFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tripsWillAppearHere,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
