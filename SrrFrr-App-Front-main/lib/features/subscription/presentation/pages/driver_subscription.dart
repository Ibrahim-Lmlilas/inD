// Main Subscription Page
// lib/features/subscription/presentation/pages/subscription_page.dart

library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/banners/first_time_promo.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/banners/subscription_history.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/cards/current_subscription.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/cards/no_subscription.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/sections/benefits_comparision.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/sections/commision_model.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/sections/faq_section.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/sections/subscription_plans.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class DriverSubscriptionPage extends StatefulWidget {
  final String source;

  const DriverSubscriptionPage({super.key, this.source = 'driver'});

  @override
  State<DriverSubscriptionPage> createState() => _DriverSubscriptionPageState();
}

class _DriverSubscriptionPageState extends State<DriverSubscriptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSubscriptions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeSubscriptions() async {
    final provider = context.read<SubscriptionProvider>();
    await provider.initialize();
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
          l10n.subscriptionsTitle,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
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
                Tab(text: l10n.plansTab),
                Tab(text: l10n.historyTab),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.availablePlans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Plans Tab
              RefreshIndicator(
                onRefresh: () => provider.initialize(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: padding),

                      // Promo Banner
                      if (provider.hasPromotion)
                        FirstTimePromoBanner(
                          promoMessage: provider.promoMessage!,
                          promoDays: provider.promoDurationDays!,
                          padding: padding,
                        ),

                      if (provider.hasPromotion)
                        SizedBox(height: padding * 1.5),

                      // Current Subscription or No Subscription Card
                      if (provider.hasActiveSubscription)
                        CurrentSubscriptionCard(
                          subscription: provider.activeSubscription!,
                          padding: padding,
                          onViewHistory: () => _tabController.animateTo(1),
                        )
                      else if (!provider.hasPromotion)
                        NoSubscriptionCard(padding: padding),

                      if (provider.hasActiveSubscription ||
                          !provider.hasPromotion)
                        SizedBox(height: padding * 1.5),

                      // Available Plans
                      SubscriptionPlansSection(
                        availablePlans: provider.availablePlans,
                        currentPlanType: provider.currentPlanType,
                        hasActiveSubscription: provider.hasActiveSubscription,
                        isFirstTimePromo: provider.isFirstTimeEligible,
                        promoDays: provider.promoDurationDays,
                        padding: padding,
                      ),

                      SizedBox(height: padding * 1.5),

                      // Benefits
                      BenefitsComparisonSection(padding: padding),

                      SizedBox(height: padding * 1.5),

                      // FAQ
                      FAQSection(padding: padding),

                      SizedBox(height: padding * 1.5),

                      // Commission Model
                      CommissionModelCard(padding: padding),

                      SizedBox(height: padding * 2),
                    ],
                  ),
                ),
              ),

              // History Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchSubscriptionHistory(),
                color: AppColors.primary,
                child: SubscriptionHistoryTab(
                  provider: provider,
                  padding: padding,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}