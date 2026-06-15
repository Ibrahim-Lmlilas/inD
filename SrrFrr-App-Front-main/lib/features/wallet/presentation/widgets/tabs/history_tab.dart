// History Tab - Full transaction history

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/transaction_tile.dart';

class HistoryTab extends StatelessWidget {
  final double padding;
  final WalletProvider walletProvider;

  const HistoryTab({
    super.key,
    required this.padding,
    required this.walletProvider,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = walletProvider.groupTransactionsByDate();

    if (walletProvider.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(padding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucune transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vos transactions apparaîtront ici',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => walletProvider.refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: ResponsiveUtils.getResponsiveCardPadding(context),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final dayTransactions = groupedTransactions[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) SizedBox(height: padding * 1.5),

              // Date Header
              Padding(
                padding: EdgeInsets.only(
                  left: padding * 0.3,
                  bottom: padding * 0.7,
                ),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Transactions for this date
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
                  children: List.generate(dayTransactions.length, (txIndex) {
                    final tx = dayTransactions[txIndex];
                    return Column(
                      children: [
                        TransactionTile(transaction: tx),
                        if (txIndex < dayTransactions.length - 1)
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
          );
        },
      ),
    );
  }
}
