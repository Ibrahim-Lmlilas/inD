// Overview Tab - Main wallet statistics and insights
//
// Features:
// - Balance card with recharge
// - Enhanced statistics cards
// - Monthly breakdown
// - Weekly earnings chart
// - Recent transactions preview

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/balance_card.dart';
// import 'package:srrfrr_app_front/features/wallet/presentation/widgets/month_breakdown_card.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/recent_transactions.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/statistics_cards.dart';
// import 'package:srrfrr_app_front/features/wallet/presentation/widgets/weekly_chart.dart';

class OverviewTab extends StatelessWidget {
  final double padding;
  final WalletProvider walletProvider;
  final VoidCallback onRecharge;

  const OverviewTab({
    super.key,
    required this.padding,
    required this.walletProvider,
    required this.onRecharge,
  });

  @override
  Widget build(BuildContext context) {
    final stats = walletProvider.getStatistics();

    return RefreshIndicator(
      onRefresh: () => walletProvider.refresh(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: padding),

            // Balance Card
            BalanceCard(
              availableBalance: walletProvider.balance,
              padding: padding,
              onRecharge: onRecharge,
            ),

            SizedBox(height: padding * 1.5),

            // Statistics Grid
            StatisticsCards(stats: stats, padding: padding),

            SizedBox(height: padding * 1.5),

            // Monthly Breakdown
            // MonthBreakdownCard(stats: stats, padding: padding),

            // SizedBox(height: padding * 1.5),

            // Weekly Earnings Chart
            // WeeklyEarningsChart(
            //   padding: padding,
            //   weeklyData: walletProvider.getWeeklyEarnings(),
            // ),

            // SizedBox(height: padding * 1.5),

            // Recent Transactions Preview
            RecentTransactionsPreview(
              padding: padding,
              transactions: walletProvider.recentTransactions,
            ),

            SizedBox(height: padding * 2),
          ],
        ),
      ),
    );
  }
}
