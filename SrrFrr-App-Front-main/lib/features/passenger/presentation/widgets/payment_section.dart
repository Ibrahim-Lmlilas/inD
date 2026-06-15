// Payment Method Selection Widget
//
// Features:
// - Cash payment option
// - Free ride option (requires full points coverage: 1pt = 1DH)
// - Simplified UI with no loyalty discount slider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/features/passenger/presentation/providers/ride_config_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class PaymentMethodSection extends StatefulWidget {
  final PaymentType selectedPaymentType;
  final int totalPrice;
  final int availablePoints;
  final Function(PaymentType) onPaymentTypeChanged;

  const PaymentMethodSection({
    super.key,
    required this.selectedPaymentType,
    required this.totalPrice,
    required this.availablePoints,
    required this.onPaymentTypeChanged,
  });

  @override
  State<PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<PaymentMethodSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  // Check if user has enough points for free ride (1pt = 1DH)
  bool _canUseFreeRide() {
    debugPrint(
      'Checking free ride eligibility: Available Points = ${widget.availablePoints}, Total Price = ${widget.totalPrice}',
    );
    return widget.availablePoints >= widget.totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<UserProvider, RideConfigProvider>(
      builder: (context, userProvider, rideConfigProvider, _) {
        final availablePoints = userProvider.points;
        final canUseFreeRide = _canUseFreeRide();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Text(
              l10n.paymentMethod,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Selected Payment Display Card
            GestureDetector(
              onTap: _toggleExpansion,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: _isExpanded ? AppColors.primary : AppColors.grey300,
                    width: _isExpanded ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isExpanded ? AppColors.primary : Colors.black)
                          .withValues(alpha: _isExpanded ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _getPaymentIcon(widget.selectedPaymentType),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPaymentLabel(widget.selectedPaymentType, l10n),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getPaymentSubtitle(
                              widget.selectedPaymentType,
                              availablePoints,
                              canUseFreeRide,
                              l10n,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(
                        begin: 0.0,
                        end: 0.5,
                      ).animate(_expandAnimation),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Free Ride Info (show if selected and can use)
            if (widget.selectedPaymentType == PaymentType.freeRide &&
                canUseFreeRide) ...[
              const SizedBox(height: 12),
              _buildFreeRideInfo(availablePoints, l10n),
            ],

            // Expanded Payment Options
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        PaymentType.cash,
                        l10n.cash,
                        l10n.cashPayment,
                        Icons.payments_rounded,
                        const Color(0xFF10B981),
                        null,
                        l10n,
                      ),
                      const Divider(height: 1),
                      _buildPaymentOption(
                        PaymentType.freeRide,
                        l10n.freeRide,
                        canUseFreeRide
                            ? l10n.youHavePoints(availablePoints)
                            : l10n.insufficientPoints(
                                widget.totalPrice,
                                availablePoints,
                              ),
                        Icons.stars_rounded,
                        const Color(0xFFF59E0B),
                        canUseFreeRide
                            ? null
                            : l10n.insufficientPoints(
                                widget.totalPrice,
                                availablePoints,
                              ),
                        l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFreeRideInfo(int availablePoints, AppLocalizations l10n) {
    final pointsAfterRide = availablePoints - widget.totalPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                size: 20,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.freeRideTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: const Text(
                  '0 DH',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Points calculation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.availablePoints,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${availablePoints}pts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.afterThisRide,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${pointsAfterRide}pts',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Info box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.pointsWillBeDeducted(widget.totalPrice),
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
      ),
    );
  }

  Widget _buildPaymentOption(
    PaymentType type,
    String label,
    String subtitle,
    IconData icon,
    Color color,
    String? disabledReason,
    AppLocalizations l10n,
  ) {
    final isSelected = widget.selectedPaymentType == type;
    final isDisabled = disabledReason != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                widget.onPaymentTypeChanged(type);
                HapticFeedback.selectionClick();
                // Close dropdown after selection
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) _toggleExpansion();
                });
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? AppColors.grey200
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? AppColors.grey400 : color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Label and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? AppColors.grey400
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      disabledReason ?? subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: disabledReason != null
                            ? AppColors.error
                            : AppColors.textSecondary,
                        fontStyle: disabledReason != null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else if (!isDisabled)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPaymentIcon(PaymentType type) {
    IconData icon;
    Color color;

    switch (type) {
      case PaymentType.cash:
        icon = Icons.payments_rounded;
        color = const Color(0xFF10B981);
        break;
      case PaymentType.freeRide:
        icon = Icons.stars_rounded;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.payments_rounded;
        color = const Color(0xFF10B981);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _getPaymentLabel(PaymentType type, AppLocalizations l10n) {
    switch (type) {
      case PaymentType.cash:
        return l10n.cash;
      case PaymentType.freeRide:
        return l10n.freeRideTitle;
      default:
        return l10n.cash;
    }
  }

  String _getPaymentSubtitle(
    PaymentType type,
    int availablePoints,
    bool canUseFreeRide,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case PaymentType.cash:
        return l10n.cashPayment;
      case PaymentType.freeRide:
        return canUseFreeRide
            ? l10n.freeRideWithPoints
            : l10n.insufficientPoints(widget.totalPrice, availablePoints);
      default:
        return l10n.cashPayment;
    }
  }
}