// Monthly Breakdown Card - Enhanced with more metrics

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class MonthBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final double padding;

  const MonthBreakdownCard({
    super.key,
    required this.stats,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final thisMonthEarnings = (stats['thisMonthEarnings'] as double?) ?? 0.0;
    final thisMonthCommissions =
        (stats['thisMonthCommissions'] as double?) ?? 0.0;
    final creditTransactions = (stats['creditTransactions'] as int?) ?? 0;
    final netEarnings = thisMonthEarnings - thisMonthCommissions;
    final effectiveRate = thisMonthEarnings > 0
        ? (netEarnings / thisMonthEarnings) * 100
        : 0.0;
    final costPerRide = creditTransactions > 0
        ? thisMonthCommissions / creditTransactions
        : 0.0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
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
            l10n.monthDetails,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Earnings Row
          _BreakdownRow(
            icon: Icons.attach_money,
            label: l10n.grossEarnings,
            value:
                '${thisMonthEarnings.toStringAsFixed(2)} ${l10n.currencySymbol}',
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 14),

          // Commission Row
          _BreakdownRow(
            icon: Icons.workspace_premium,
            label: l10n.commissions,
            value:
                '-${thisMonthCommissions.toStringAsFixed(2)} ${l10n.currencySymbol}',
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Net Earnings Row
          _BreakdownRow(
            icon: Icons.account_balance_wallet,
            label: l10n.netEarnings,
            value:
                '${netEarnings.toStringAsFixed(2)} ${l10n.currencySymbol}',
            color: const Color(0xFF0F172A),
            isBold: true,
          ),

          const SizedBox(height: 20),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value:
                      '${costPerRide.toStringAsFixed(2)} ${l10n.currencySymbol}',
                  label: l10n.costPerRide,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  value: '${effectiveRate.toStringAsFixed(1)}%',
                  label: l10n.effectiveRate,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: isBold ? const Color(0xFF0F172A) : color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
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
          ),
        ],
      ),
    );
  }
}