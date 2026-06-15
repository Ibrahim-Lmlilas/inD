// Current Subscription Card Widget

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class CurrentSubscriptionCard extends StatelessWidget {
  final SubscriptionData subscription;
  final double padding;
  final VoidCallback onViewHistory;

  const CurrentSubscriptionCard({
    super.key,
    required this.subscription,
    required this.padding,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor(subscription.planType);
    final l10n = AppLocalizations.of(context)!;
    final progress = subscription.maxRides > 0
        ? subscription.ridesUsed / subscription.maxRides
        : 0.0;

    final daysUntilRenewal = subscription.endDate != null
        ? subscription.endDate!.difference(DateTime.now()).inDays
        : 0;

    final isExpiring = daysUntilRenewal <= 7 && daysUntilRenewal > 0;
    final isExpired = daysUntilRenewal <= 0;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: planColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: planColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: planColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, size: 18, color: planColor),
                    const SizedBox(width: 6),
                    Text(
                      _getPlanName(subscription.planType),
                      style: TextStyle(
                        color: planColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.history, color: planColor, size: 18),
                ),
                onPressed: onViewHistory,
                tooltip: l10n.historyTab,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress
          if (subscription.maxRides > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ridesUsed,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subscription.ridesUsed} / ${subscription.maxRides}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progress >= 0.8
                        ? const Color(0xFFFEF3C7)
                        : planColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: progress >= 0.8
                          ? const Color(0xFFD97706)
                          : planColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 0.8 ? const Color(0xFFF59E0B) : planColor,
                ),
              ),
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.coursesThisMonth,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${subscription.ridesUsed}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.unlimited,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Renewal Info
          if (subscription.endDate != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isExpired
                    ? const Color(0xFFFEE2E2)
                    : isExpiring
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired
                        ? Icons.error_outline
                        : isExpiring
                        ? Icons.access_time
                        : Icons.check_circle_outline,
                    size: 18,
                    color: isExpired
                        ? const Color(0xFFEF4444)
                        : isExpiring
                        ? const Color(0xFFD97706)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isExpired
                          ? l10n.subscriptionExpired
                          : isExpiring
                          ? l10n.expiresInDays(daysUntilRenewal)
                          : l10n.renewsInDays(daysUntilRenewal),
                      style: TextStyle(
                        color: isExpired
                            ? const Color(0xFFEF4444)
                            : isExpiring
                            ? const Color(0xFFD97706)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.cancelSubscription,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
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

  void _showCancelDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n!.cancelSubscriptionDialog,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.cancelSubscriptionWarning(
                  _getPlanName(subscription.planType),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
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
                        l10n.back,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleCancel(context, l10n);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

  Future<void> _handleCancel(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    HapticFeedback.mediumImpact();
    final provider = context.read<SubscriptionProvider>();
    final success = await provider.cancelSubscription();

    if (context.mounted) {
      if (success) {
        SnackBarService(context).showSuccess(l10n.subscriptionCancelled);
      } else {
        SnackBarService(
          context,
        ).showError(provider.errorMessage ?? l10n.errorCancellation);
      }
    }
  }
}
