// Subscription History Card Widget
// lib/features/subscription/presentation/widgets/subscription_cards/subscription_history_card.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class SubscriptionHistoryCard extends StatelessWidget {
  final SubscriptionData subscription;
  final double padding;

  const SubscriptionHistoryCard({
    super.key,
    required this.subscription,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planColor = _getPlanColor(subscription.planType);
    final statusColor = _getStatusColor(subscription.status);

    final startDateStr = subscription.startDate != null
        ? _formatDate(subscription.startDate!)
        : '-';
    final endDateStr = subscription.endDate != null
        ? _formatDate(subscription.endDate!)
        : '-';

    return Container(
      margin: EdgeInsets.only(bottom: padding),
      padding: EdgeInsets.all(padding * 1.2),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: planColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: planColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getPlanName(subscription.planType),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: planColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(subscription.status, l10n!),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.period,
                  value: '$startDateStr → $endDateStr',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.directions_car_outlined,
                        label: l10n.rides,
                        value: subscription.maxRides > 0
                            ? '${subscription.ridesUsed}/${subscription.maxRides}'
                            : '${subscription.ridesUsed} (∞)',
                      ),
                    ),
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.payments_outlined,
                        label: l10n.price,
                        value: '${subscription.price.toInt()} DH',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanName(String planType) {
    switch (planType.toUpperCase()) {
      case 'BASIC':
        return 'Basic';
      case 'PREMIUM':
        return 'Premium';
      case 'PRO':
        return 'Pro Illimité';
      default:
        return planType;
    }
  }

  Color _getPlanColor(String planType) {
    switch (planType.toUpperCase()) {
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF10B981);
      case 'EXPIRED':
        return const Color(0xFFEF4444);
      case 'CANCELLED':
        return const Color(0xFF64748B);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return l10n.active;
      case 'EXPIRED':
        return l10n.expired;
      case 'CANCELLED':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
