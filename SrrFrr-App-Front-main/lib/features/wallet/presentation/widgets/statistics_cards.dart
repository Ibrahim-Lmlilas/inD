// Enhanced Statistics Cards - Localized
//
// 2x3 grid showing key metrics with proper localization

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class StatisticsCards extends StatelessWidget {
  final Map<String, dynamic> stats;
  final double padding;

  const StatisticsCards({
    super.key,
    required this.stats,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final totalEarnings = (stats['totalEarnings'] as double?) ?? 0.0;
    final thisMonthEarnings = (stats['thisMonthEarnings'] as double?) ?? 0.0;
    final avgPerTransaction =
        (stats['averagePerTransaction'] as double?) ?? 0.0;
    final totalTransactions = (stats['totalTransactions'] as int?) ?? 0;
    final totalDebits = (stats['totalDebits'] as double?) ?? 0.0;
    final thisMonthNet = (stats['thisMonthNet'] as double?) ?? 0.0;

    debugPrint('\n📊 STATISTICS CARDS DISPLAY');
    debugPrint('Total Earnings: $totalEarnings DH');
    debugPrint('This Month Earnings: $thisMonthEarnings DH');
    debugPrint('Average per Transaction: $avgPerTransaction DH');
    debugPrint('Total Transactions: $totalTransactions');
    debugPrint('Total Debits: $totalDebits DH');
    debugPrint('This Month Net: $thisMonthNet DH\n');

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        children: [
          // Row 1: Earnings Focus
          // Row(
          //   children: [
          //     Expanded(
          //       child: _StatCard(
          //         icon: Icons.trending_up,
          //         label: l10n.totalEarned,
          //         value:
          //             '${totalEarnings.toStringAsFixed(0)} ${l10n.currencySymbol}',
          //         color: AppColors.primary,
          //         isLarge: true,
          //       ),
          //     ),
          //     SizedBox(width: padding),
          //     Expanded(
          //       child: _StatCard(
          //         icon: Icons.calendar_month,
          //         label: l10n.thisMonth,
          //         value:
          //             '${thisMonthEarnings.toStringAsFixed(0)} ${l10n.currencySymbol}',
          //         color: AppColors.primary,
          //         isLarge: true,
          //       ),
          //     ),
          //     SizedBox(width: padding),
          //     Expanded(
          //       child: _StatCard(
          //         icon: Icons.attach_money,
          //         label: l10n.perRide,
          //         value:
          //             '${avgPerTransaction.toStringAsFixed(0)} ${l10n.currencySymbol}',
          //         color: AppColors.primary,
          //         isLarge: true,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: padding),

          // Row 2: Activity & Balance
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: l10n.totalTransactions,
                  value: '$totalTransactions',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: padding),
              Expanded(
                child: _StatCard(
                  icon: Icons.remove_circle_outline,
                  label: l10n.totalDebits,
                  value:
                      '${totalDebits.toStringAsFixed(0)} ${l10n.currencySymbol}',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: padding),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet,
                  label: l10n.netThisMonth,
                  value:
                      '${thisMonthNet.toStringAsFixed(0)} ${l10n.currencySymbol}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLarge;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: isLarge ? 24 : 20, color: color),
          ),
          SizedBox(height: isLarge ? 12 : 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}