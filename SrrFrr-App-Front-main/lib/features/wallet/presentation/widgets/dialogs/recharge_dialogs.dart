// Recharge Dialogs - All recharge-related dialogs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/recharge_code.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RechargeDialogs {
  // Show main recharge options dialog
  static void showRechargeOptions(
    BuildContext context, {
    Function(RechargeCode)? onCodeGenerated,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.rechargeWallet,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RechargeOption(
              icon: Icons.receipt_long,
              title: l10n.generateCodeOption,
              subtitle: l10n.generateCodeSubtitle,
              onTap: () {
                Navigator.pop(dialogContext);
                _showGenerateCodeDialog(context, onCodeGenerated, l10n);
              },
            ),
            const SizedBox(height: 12),
            _RechargeOption(
              icon: Icons.credit_card,
              title: l10n.creditCardOption,
              subtitle: l10n.creditCardSubtitle,
              onTap: () {
                Navigator.pop(dialogContext);
                _showCreditCardDialog(context, l10n);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate code dialog
  static void _showGenerateCodeDialog(
    BuildContext context,
    Function(RechargeCode)? onCodeGenerated,
    AppLocalizations l10n,
  ) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.generateCodeOption,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.amount,
                hintText: l10n.amountHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: l10n.currencySymbol,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.generateCodeInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount >= 100) {
                Navigator.pop(dialogContext);
                HapticFeedback.mediumImpact();

                final newCode = RechargeCode(
                  code:
                      'RC2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  amount: amount,
                  dateGenerated: DateTime.now(),
                  status: RechargeCodeStatus.active,
                );

                if (onCodeGenerated != null) {
                  onCodeGenerated(newCode);
                }

                _showCodeGeneratedDialog(context, newCode, l10n);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.generate,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Code generated success dialog
  static void _showCodeGeneratedDialog(
    BuildContext context,
    RechargeCode code,
    AppLocalizations l10n,
  ) {    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 28),
            const SizedBox(width: 12),
            Text(
              l10n.codeGenerated,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL + 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    code.code,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${l10n.amountHint.split(': ')[0]}: ${code.amount.toStringAsFixed(2)} ${l10n.currencySymbol}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.presentCodeInfo,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code.code));
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
              if (context.mounted) {
                SnackBarService(
                  context,
                ).showInfo(l10n.codeCopied);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.copyCode,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Credit card payment dialog
  static void _showCreditCardDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.cardPaymentTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.amount,
                hintText: l10n.amountHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: l10n.currencySymbol,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.securePaymentInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount >= 100) {
                Navigator.pop(dialogContext);
                HapticFeedback.mediumImpact();
                if (context.mounted) {
                  SnackBarService(
                    context,
                  ).showInfo(l10n.redirectingPayment);
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.continueButton,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// Recharge Option Widget
class _RechargeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RechargeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL + 2),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}