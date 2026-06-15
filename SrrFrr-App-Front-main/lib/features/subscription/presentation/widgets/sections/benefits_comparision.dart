// Benefits Comparison Section Widget

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class BenefitsComparisonSection extends StatelessWidget {
  final double padding;

  const BenefitsComparisonSection({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              l10n!.comparison,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _BenefitRow(
                  benefit: l10n.commission,
                  basic: "0%",
                  premium: "0%",
                  pro: "0%",
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _BenefitRow(
                  benefit: l10n.rideLimit,
                  basic: l10n.rideLimitBasic,
                  premium: l10n.rideLimitPremium,
                  pro: l10n.unlimited,
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _BenefitRow(
                  benefit: l10n.support,
                  basic: l10n.standard,
                  premium: l10n.priority,
                  pro: l10n.vip247,
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _BenefitRow(
                  benefit: l10n.statistics,
                  basic: l10n.basic,
                  premium: l10n.advanced,
                  pro: l10n.complete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String benefit;
  final String basic;
  final String premium;
  final String pro;

  const _BenefitRow({
    required this.benefit,
    required this.basic,
    required this.premium,
    required this.pro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            benefit,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            basic,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            premium,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10B981),
            ),
          ),
        ),
        Expanded(
          child: Text(
            pro,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ),
      ],
    );
  }
}