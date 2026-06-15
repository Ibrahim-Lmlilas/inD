// Recharge Codes Tab - Manage recharge codes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/recharge_code.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/dialogs/recharge_dialogs.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RechargeCodesTab extends StatefulWidget {
  final double padding;

  const RechargeCodesTab({super.key, required this.padding});

  @override
  State<RechargeCodesTab> createState() => _RechargeCodesTabState();
}

class _RechargeCodesTabState extends State<RechargeCodesTab> {
  final List<RechargeCode> _rechargeCodes = [];

  void _onGenerateNewCode() {
    RechargeDialogs.showRechargeOptions(
      context,
      onCodeGenerated: (code) {
        setState(() {
          _rechargeCodes.insert(0, code);
        });
      },
    );
  }

  void _onDeleteCode(RechargeCode code, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppLocalizations.of(context)!.deleteCodeTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          l10n.deleteCodeConfirmation,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
              setState(() {
                _rechargeCodes.remove(code);
              });
              Navigator.pop(dialogContext);
              HapticFeedback.mediumImpact();
              if (mounted) {
                SnackBarService(
                  context,
                ).showInfo(AppLocalizations.of(context)!.codeDeleted);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeCodes = _rechargeCodes
        .where((c) => c.status == RechargeCodeStatus.active)
        .toList();
    final expiredCodes = _rechargeCodes
        .where((c) => c.status == RechargeCodeStatus.expired)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: widget.padding),

          // Generate New Code Button
          Padding(
            padding: ResponsiveUtils.getResponsiveCardPadding(context),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _onGenerateNewCode();
                },
                icon: const Icon(Icons.add),
                label: Text(
                  l10n.generateNewCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: widget.padding * 1.5),

          // Active Codes
          if (activeCodes.isNotEmpty) ...[
            Padding(
              padding: ResponsiveUtils.getResponsiveCardPadding(context),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.activeCodes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.padding),
            ...activeCodes.map(
              (code) => Padding(
                padding: EdgeInsets.only(
                  left: widget.padding,
                  right: widget.padding,
                  bottom: widget.padding,
                ),
                child: _CodeCard(
                  code: code,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    HapticFeedback.lightImpact();
                    if (mounted) {
                      SnackBarService(context).showInfo(l10n.codeCopied);
                    }
                  },
                  onDelete: () => _onDeleteCode(code, l10n),
                ),
              ),
            ),
            SizedBox(height: widget.padding),
          ],

          // Expired Codes
          if (expiredCodes.isNotEmpty) ...[
            Padding(
              padding: ResponsiveUtils.getResponsiveCardPadding(context),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.expiredCodes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.padding),
            ...expiredCodes.map(
              (code) => Padding(
                padding: EdgeInsets.only(
                  left: widget.padding,
                  right: widget.padding,
                  bottom: widget.padding,
                ),
                child: _CodeCard(
                  code: code,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    HapticFeedback.lightImpact();
                    if (mounted) {
                      SnackBarService(context).showInfo(l10n.codeCopied);
                    }
                  },
                  onDelete: () => _onDeleteCode(code, l10n),
                ),
              ),
            ),
          ],

          // Empty State
          if (_rechargeCodes.isEmpty)
            Padding(
              padding: EdgeInsets.all(widget.padding * 2),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.noRechargeCodes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.generateCodeDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          SizedBox(height: widget.padding * 2),
        ],
      ),
    );
  }
}

// Code Card Widget
class _CodeCard extends StatelessWidget {
  final RechargeCode code;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _CodeCard({
    required this.code,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExpired = code.status == RechargeCodeStatus.expired;
    final statusColor = isExpired
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final statusBgColor = isExpired
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFDCFCE7);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL + 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? const Color(0xFFE2E8F0)
              : statusColor.withValues(alpha: 0.2),
        ),
        boxShadow: isExpired
            ? null
            : [
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isExpired
                            ? const Color(0xFF64748B)
                            : const Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(context, code.dateGenerated),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isExpired ? l10n.expired : l10n.active,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${code.amount.toStringAsFixed(2)} ${l10n.currencySymbol}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isExpired
                        ? const Color(0xFF64748B)
                        : AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (!isExpired)
                OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(
                    l10n.copy,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFEF4444),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else if (diff.inDays < 7) {
      return l10n.daysAgo(diff.inDays);
    } else {
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'ar') {
        return '${date.year}/${date.month}/${date.day}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}