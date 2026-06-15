// Weekly Earnings Chart Widget

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class WeeklyEarningsChart extends StatelessWidget {
  final double padding;
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyEarningsChart({
    super.key,
    required this.padding,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAmount = weeklyData
        .map((d) => d['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        padding: EdgeInsets.all(padding * 1.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.thisWeek,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weeklyData.map((data) {
                  final amount = data['amount'] as double;
                  final height = maxAmount > 0
                      ? (amount / maxAmount) * 120
                      : 0.0;
                  final day = data['day'] as String;
                  debugPrint('Weekly Chart - Day: $day, Amount: $amount, Height: $height');

                  // Localize day names
                  String localizedDay = _getLocalizedDay(day, context);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (amount > 0)
                            Text(
                              '${amount.toInt()}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizedDay,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDay(String day, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (day.toLowerCase()) {
      case 'lun':
        return l10n.monday;
      case 'mar':
        return l10n.tuesday;
      case 'mer':
        return l10n.wednesday;
      case 'jeu':
        return l10n.thursday;
      case 'ven':
        return l10n.friday;
      case 'sam':
        return l10n.saturday;
      case 'dim':
        return l10n.sunday;
      default:
        return day;
    }
  }
}