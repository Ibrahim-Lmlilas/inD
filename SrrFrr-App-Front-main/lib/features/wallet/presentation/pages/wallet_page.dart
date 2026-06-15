// Driver Wallet Page - Main Entry Point
//
// Simplified main page that coordinates between tabs
// Modern navigation matching subscription page style

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/dialogs/recharge_dialogs.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/tabs/history_tab.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/tabs/overview_tab.dart';
import 'package:srrfrr_app_front/features/wallet/presentation/widgets/tabs/recharge_codes_tab.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshWallet() async {
    HapticFeedback.lightImpact();
    final walletProvider = context.read<WalletProvider>();
    await walletProvider.refresh();
  }

  Future<void> _rechargeWallet() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    RechargeDialogs.showRechargeOptions(context);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.walletTitle,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary, size: 22),
            onPressed: _refreshWallet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.overviewTab),
                Tab(text: l10n.codesTab),
                Tab(text: l10n.historyTab),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (walletProvider.isLoading && !walletProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (walletProvider.errorMessage != null) {
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
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      walletProvider.errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _refreshWallet,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.retry,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(
                padding: padding,
                walletProvider: walletProvider,
                onRecharge: _rechargeWallet,
              ),
              RechargeCodesTab(padding: padding),
              HistoryTab(padding: padding, walletProvider: walletProvider),
            ],
          );
        },
      ),
    );
  }
}
