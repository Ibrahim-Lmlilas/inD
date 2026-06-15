// Transaction Tile Widget - Reusable transaction display

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_transaction.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(transaction.type);
    final color = _getColor(transaction.type);
    final isPositive =
        transaction.type == WalletTransactionType.credit ||
        transaction.type == WalletTransactionType.init;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL + 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 22, color: color),
          ),
          const SizedBox(width: AppSizes.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.getDisplayName(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(context, transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currencySymbol}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.credit:
        return Icons.add_circle_outline;
      case WalletTransactionType.debit:
        return Icons.remove_circle_outline;
      case WalletTransactionType.init:
        return Icons.account_balance_wallet;
      case WalletTransactionType.commission:
        return Icons.workspace_premium;
      case WalletTransactionType.subscription:
        return Icons.subscriptions;
    }
  }

  Color _getColor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.credit:
      case WalletTransactionType.init:
        return const Color(0xFF10B981);
      case WalletTransactionType.debit:
      case WalletTransactionType.commission:
      case WalletTransactionType.subscription:
        return const Color(0xFFEF4444);
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return l10n.justNow;
    } else if (diff.inHours < 1) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else if (diff.inDays < 7) {
      return l10n.daysAgo(diff.inDays);
    } else {
      // Format date based on locale
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'ar') {
        // Arabic date format
        return '${date.year}/${date.month}/${date.day}';
      } else {
        // European date format for FR/EN
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}