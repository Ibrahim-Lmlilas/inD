// Ride Options Panel Component
//
// Sliding panel for ride configuration including:
// - Ride type selection (City-to-City / In-City) - auto-detected
// - Vehicle type selection (currently only cars available)
// - Seat selection with text input (1-4 seats max)
// - Price control with dynamic minimum based on distance/seats
// - Route summary and confirmation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/services/pricing_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/vehicle_type.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/ride_config_provider.dart';
import 'package:srrfrr_app_front/shared/widgets/vehicle_type_selector.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/widgets/payment_section.dart';
import 'dart:math' show sin, pi;
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

class RideOptionsPanel extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;
  final String? pickupCity;
  final String? destinationCity;
  final double? distance;
  final String? estimatedTime;
  final VehicleType selectedVehicleType;
  final String? selectedRideType;
  final int offerPrice;
  final int selectedSeats;
  final Animation<double> priceShakeAnimation;
  final int minimumFare;
  final Function(String) onRideTypeSelected;
  final Function(VehicleType) onVehicleTypeChanged;
  final Function(int) onSeatsChanged;
  final VoidCallback onPriceIncrease;
  final VoidCallback onPriceDecrease;
  final VoidCallback onConfirm;
  final VoidCallback onClose;
  final bool canSubmit;
  final PaymentType selectedPaymentType;
  final int availablePoints;
  final ValueChanged<PaymentType> onPaymentTypeChanged;

  const RideOptionsPanel({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    this.pickupCity,
    this.destinationCity,
    this.distance,
    this.estimatedTime,
    required this.selectedVehicleType,
    this.selectedRideType,
    required this.offerPrice,
    required this.selectedSeats,
    required this.priceShakeAnimation,
    required this.minimumFare,
    required this.onRideTypeSelected,
    required this.onVehicleTypeChanged,
    required this.onSeatsChanged,
    required this.onPriceIncrease,
    required this.onPriceDecrease,
    required this.onConfirm,
    required this.onClose,
    required this.canSubmit,
    required this.selectedPaymentType,
    required this.availablePoints,
    required this.onPaymentTypeChanged,
  });

  @override
  State<RideOptionsPanel> createState() => _RideOptionsPanelState();
}

class _RideOptionsPanelState extends State<RideOptionsPanel> {
  late TextEditingController _seatsController;

  @override
  void initState() {
    super.initState();
    _seatsController = TextEditingController(
      text: widget.selectedSeats.toString(),
    );
  }

  @override
  void didUpdateWidget(RideOptionsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSeats != widget.selectedSeats) {
      _seatsController.text = widget.selectedSeats.toString();
    }
  }

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minimumFare = PricingService.calculateMinimumFare(
      distance: widget.distance ?? 0,
      rideType: widget.selectedRideType ?? 'in_city',
      seats: widget.selectedSeats,
    );

    final isPriceBelowMinimum = widget.offerPrice < minimumFare;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppSizes.radiusXS),
            ),
          ),
          _buildHeader(context, l10n),
          Divider(height: 1, color: AppColors.grey200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteSummary(l10n),
                  const SizedBox(height: AppSizes.paddingXL),
                  _buildRideTypeSection(l10n),
                  const SizedBox(height: AppSizes.paddingXL),
                  VehicleTypeSelector(
                    selectedType: widget.selectedVehicleType,
                    onTypeChanged: widget.onVehicleTypeChanged,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  PaymentMethodSection(
                    selectedPaymentType: widget.selectedPaymentType,
                    totalPrice: widget.offerPrice,
                    availablePoints: widget.availablePoints,
                    onPaymentTypeChanged: widget.onPaymentTypeChanged,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  _buildSeatsSection(l10n),
                  const SizedBox(height: AppSizes.paddingXL),
                  if (widget.selectedPaymentType != PaymentType.freeRide) ...[
                    _buildPriceSection(minimumFare, isPriceBelowMinimum, l10n),
                    const SizedBox(height: AppSizes.paddingXL),
                  ],
                  const SizedBox(height: AppSizes.paddingXL),
                  _buildConfirmButton(l10n),
                  const SizedBox(height: AppSizes.paddingM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rideDetails,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.distance != null &&
                    widget.estimatedTime != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.estimatedTime!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.onClose();
            },
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.radio_button_checked,
            iconColor: AppColors.success,
            text: widget.pickupLocation,
            city: widget.pickupCity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            child: Row(
              children: [
                const SizedBox(width: 36),
                Container(
                  width: 2,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXXS),
                  ),
                ),
              ],
            ),
          ),
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            text: widget.destinationLocation,
            city: widget.destinationCity,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    String? city,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (city != null && city.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  city,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideTypeSection(AppLocalizations l10n) {
    final bool isDifferentCities =
        widget.pickupCity != null &&
        widget.destinationCity != null &&
        widget.pickupCity!.toLowerCase() !=
            widget.destinationCity!.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.rideType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.autoDetected,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildRideTypeButton(
                type: 'city_to_city',
                label: l10n.cityToCity,
                icon: Icons.location_city,
                isSelected: widget.selectedRideType == 'city_to_city',
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildRideTypeButton(
                type: 'in_city',
                label: l10n.inCity,
                icon: Icons.directions_car,
                isSelected: widget.selectedRideType == 'in_city',
              ),
            ),
          ],
        ),
        if (isDifferentCities && widget.selectedRideType == 'city_to_city') ...[
          const SizedBox(height: AppSizes.paddingS),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.intercityTripDetected(
                      widget.pickupCity!,
                      widget.destinationCity!,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRideTypeButton({
    required String type,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onRideTypeSelected(type);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.numberOfSeats,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.grey300, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  final seatNumber = index + 1;
                  final isSelected = widget.selectedSeats >= seatNumber;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onSeatsChanged(seatNumber);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey300,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_normal,
                            size: 32,
                            color: isSelected
                                ? Colors.white
                                : AppColors.grey400,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.grey100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$seatNumber',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.seatsSelected(
                        widget.selectedSeats,
                        widget.selectedSeats > 1 ? 's' : '',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(
    int minimumFare,
    bool isPriceBelowMinimum,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proposePrice,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        AnimatedBuilder(
          animation: widget.priceShakeAnimation,
          builder: (context, child) {
            final offset = sin(widget.priceShakeAnimation.value * pi * 4) * 10;
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color:
                    isPriceBelowMinimum && widget.priceShakeAnimation.value > 0
                    ? AppColors.error
                    : AppColors.grey300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildPriceButton(
                      icon: Icons.remove,
                      onPressed: widget.onPriceDecrease,
                      isEnabled: !isPriceBelowMinimum,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${widget.offerPrice} DH',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color:
                                  isPriceBelowMinimum &&
                                      widget.priceShakeAnimation.value > 0
                                  ? AppColors.error
                                  : AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPriceButton(
                      icon: Icons.add,
                      onPressed: widget.onPriceIncrease,
                      isEnabled: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.minimumPrice(minimumFare),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isEnabled ? AppColors.primary : AppColors.grey400,
          size: 24,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildConfirmButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.canSubmit
            ? () {
                HapticFeedback.mediumImpact();
                widget.onConfirm();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.canSubmit
              ? AppColors.primary
              : AppColors.grey300,
          foregroundColor: widget.canSubmit ? Colors.white : AppColors.grey400,
          elevation: 0,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 22),
            const SizedBox(width: AppSizes.paddingM),
            Text(
              l10n.confirmRide,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
