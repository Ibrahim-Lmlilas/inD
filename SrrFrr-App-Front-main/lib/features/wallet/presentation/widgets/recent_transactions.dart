// Recent Transactions Preview Widget

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_transaction.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/transaction_tile.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RecentTransactionsPreview extends StatelessWidget {
  final double padding;
  final List<WalletTransaction> transactions;

  const RecentTransactionsPreview({
    super.key,
    required this.padding,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final previewCount = transactions.length > 3 ? 3 : transactions.length;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: padding * 0.3, bottom: padding),
            child: Text(
              AppLocalizations.of(context)!.recentTransactions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
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
              children: List.generate(previewCount, (index) {
                return Column(
                  children: [
                    TransactionTile(transaction: transactions[index]),
                    if (index < previewCount - 1)
                      Divider(
                        height: 1,
                        indent: 64,
                        color: const Color(0xFFE2E8F0),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
