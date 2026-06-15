// No Subscription Card Widget
import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class NoSubscriptionCard extends StatelessWidget {
  final double padding;

  const NoSubscriptionCard({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: const EdgeInsets.all(
        20,
      ), // Changed from EdgeInsets.all(padding * 2)
      width: double.infinity, // Added to match width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ), // Added border to match
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noActiveSubscription,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.choosePlanPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
