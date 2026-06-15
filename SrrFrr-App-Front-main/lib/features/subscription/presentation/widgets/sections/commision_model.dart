// Commission Model Card Widget
// lib/features/subscription/presentation/widgets/subscription_sections/commission_model_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class CommissionModelCard extends StatelessWidget {
  final double padding;

  const CommissionModelCard({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.percent, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n!.commissionModel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.preferCommission,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.commissionExplanation,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showCommissionDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.learnMore,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommissionDialog(BuildContext context) {
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.percent,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n!.commissionModalTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.commissionPerRide,
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
                    _CommissionFeature(
                      icon: Icons.check_circle,
                      text: l10n.commissionFeature1,
                    ),
                    const SizedBox(height: 12),
                    _CommissionFeature(
                      icon: Icons.check_circle,
                      text: l10n.commissionFeature2,
                    ),
                    const SizedBox(height: 12),
                    _CommissionFeature(
                      icon: Icons.check_circle,
                      text: l10n.commissionFeature3,
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
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.commissionExample,
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
                        l10n.close,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        SnackBarService(context).showInfo(l10n.contactSupport);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.activate,
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
}

class _CommissionFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CommissionFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}