// Subscription Plan Card Widget
// lib/features/subscription/presentation/widgets/subscription_cards/subscription_plan_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isPopular;
  final bool hasActiveSubscription;
  final bool showPromo;
  final int? promoDays;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.isPopular,
    required this.hasActiveSubscription,
    required this.showPromo,
    this.promoDays,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getPlanColor(plan.type);
    final maxRides = _getMaxRides(plan.type);
    final ridesText = maxRides == 0
        ? l10n.unlimited
        : '$maxRides ${l10n.rides.toLowerCase()}';

    final provider = context.read<SubscriptionProvider>();
    final canChange = provider.canChangeTo(plan.type);
    final canSubscribe = provider.canSubscribeTo(plan.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentPlan
            ? Border.all(color: color, width: 2)
            : showPromo && !hasActiveSubscription
            ? Border.all(color: const Color(0xFFEF4444), width: 2)
            : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPopular ? 0.06 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPlanName(plan.type),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (showPromo && !hasActiveSubscription)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🎉 PROMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.popular,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.current,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.price.toInt()}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.amountPerMonth,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showPromo &&
                    !hasActiveSubscription &&
                    promoDays != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.celebration,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.daysForMonth(promoDays!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  ridesText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.descriptions.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 14, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isCurrentPlan
                        ? null
                        : (canChange || canSubscribe)
                        ? () {
                            HapticFeedback.mediumImpact();
                            if (canChange) {
                              _showChangeDialog(context, plan, color);
                            } else {
                              _showSubscribeDialog(context, plan, color);
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? const Color(0xFFE2E8F0)
                          : (canChange || canSubscribe)
                          ? color
                          : const Color(0xFFE2E8F0),
                      foregroundColor: isCurrentPlan
                          ? const Color(0xFF64748B)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? l10n.activeSubscription
                          : canChange
                          ? l10n.changeToPlan
                          : canSubscribe
                          ? showPromo && !hasActiveSubscription
                                ? l10n.takeAdvantage
                                : l10n.chooseThisPlan
                          : l10n.notAvailable,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
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

  void _showSubscribeDialog(
    BuildContext context,
    SubscriptionPlan plan,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final maxRides = _getMaxRides(plan.type);
    final ridesText = maxRides == 0
        ? l10n.unlimited
        : '$maxRides ${l10n.rides.toLowerCase()}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium, color: color, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.confirmSubscription,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.subscribeToPlan(_getPlanName(plan.type)),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${plan.price.toInt()} ${l10n.amountPerMonth}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.rides,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          ridesText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleSubscribe(context, plan.type);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeDialog(
    BuildContext context,
    SubscriptionPlan plan,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final maxRides = _getMaxRides(plan.type);
    final ridesText = maxRides == 0
        ? l10n.unlimited
        : '$maxRides ${l10n.rides.toLowerCase()}';
    final provider = context.read<SubscriptionProvider>();
    final currentPlan = provider.activeSubscription!;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_horiz, color: color, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changeSubscription,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.switchFromTo(
                  _getPlanName(currentPlan.planType),
                  _getPlanName(plan.type),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.newPlan,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _getPlanName(plan.type),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${plan.price.toInt()} ${l10n.amountPerMonth}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.rides,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          ridesText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.changeEffectiveImmediately,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleChange(context, plan.type);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context, String planType) async {
    HapticFeedback.mediumImpact();
    final provider = context.read<SubscriptionProvider>();
    final success = await provider.subscribeToPlan(planType);

    if (context.mounted) {
      if (success) {
        SnackBarService(
          context,
        ).showSuccess(AppLocalizations.of(context)!.subscriptionActivated);
      } else {
        SnackBarService(context).showError(
          provider.errorMessage ??
              AppLocalizations.of(context)!.errorSubscription,
        );
      }
    }
  }

  Future<void> _handleChange(BuildContext context, String planType) async {
    HapticFeedback.mediumImpact();
    final provider = context.read<SubscriptionProvider>();
    final success = await provider.changeSubscription(planType);

    if (context.mounted) {
      if (success) {
        SnackBarService(
          context,
        ).showSuccess(AppLocalizations.of(context)!.subscriptionChanged);
      } else {
        SnackBarService(context).showError(
          provider.errorMessage ?? AppLocalizations.of(context)!.errorChanging,
        );
      }
    }
  }

  String _getPlanName(String type) {
    switch (type.toUpperCase()) {
      case 'BASIC':
        return 'Basic';
      case 'PREMIUM':
        return 'Premium';
      case 'PRO':
        return 'Pro Illimité';
      default:
        return type;
    }
  }

  Color _getPlanColor(String type) {
    switch (type.toUpperCase()) {
      case 'BASIC':
        return const Color(0xFF3B82F6);
      case 'PREMIUM':
        return const Color(0xFF10B981);
      case 'PRO':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  int _getMaxRides(String type) {
    switch (type.toUpperCase()) {
      case 'PRO':
        return 0;
      case 'PREMIUM':
        return 150;
      case 'BASIC':
        return 60;
      default:
        return 0;
    }
  }
}