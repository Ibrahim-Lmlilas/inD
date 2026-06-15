// First Time Promo Banner Widget
// lib/features/subscription/presentation/widgets/subscription_banners/first_time_promo_banner.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class FirstTimePromoBanner extends StatelessWidget {
  final String promoMessage;
  final int promoDays;
  final double padding;

  const FirstTimePromoBanner({
    super.key,
    required this.promoMessage,
    required this.promoDays,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            promoMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 18, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Text(
                  l10n.daysForMonth(promoDays),
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.specialOffer,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}