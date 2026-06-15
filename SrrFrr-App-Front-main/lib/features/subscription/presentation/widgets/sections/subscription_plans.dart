// Subscription Plans Section Widget

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/cards/subscription_plan.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class SubscriptionPlansSection extends StatelessWidget {
  final List<SubscriptionPlan> availablePlans;
  final String? currentPlanType;
  final bool hasActiveSubscription;
  final bool isFirstTimePromo;
  final int? promoDays;
  final double padding;

  const SubscriptionPlansSection({
    super.key,
    required this.availablePlans,
    required this.currentPlanType,
    required this.hasActiveSubscription,
    required this.isFirstTimePromo,
    this.promoDays,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (availablePlans.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              l10n.choosePlan,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          ...availablePlans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < availablePlans.length - 1 ? 12 : 0,
              ),
              child: SubscriptionPlanCard(
                plan: plan,
                isCurrentPlan: plan.type == currentPlanType,
                isPopular: plan.type == 'PREMIUM',
                hasActiveSubscription: hasActiveSubscription,
                showPromo: isFirstTimePromo,
                promoDays: promoDays,
              ),
            );
          }),
        ],
      ),
    );
  }
}