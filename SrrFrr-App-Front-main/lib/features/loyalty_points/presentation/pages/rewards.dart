// Rewards Page - Minimalist Professional Implementation
//
// Features:
// - Clean loyalty points overview
// - Paginated transaction history
// - Simple quick actions
// - Earn points catalog from backend
// - Removed discount conversion (old business model)

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/loyalty_points/data/model/loyalty_reward.dart';
import 'package:srrfrr_app_front/features/loyalty_points/presentation/providers/loyalty_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/features/loyalty_points/presentation/widgets/referral_dialog.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RewardsPage extends StatefulWidget {
  final String source;

  const RewardsPage({super.key, this.source = 'passenger'});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<LoyaltyProvider>();
        if (!provider.isLoadingMore && provider.hasMore) {
          provider.loadMoreTransactions();
        }
      }
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      final loyaltyProvider = context.read<LoyaltyProvider>();
      await loyaltyProvider.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(context).showError(l10n.errorOccurred);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _shareReferralLink() async {
    HapticFeedback.lightImpact();
    showReferralDialog(context: context);
  }

  Future<void> _refreshData() async {
    try {
      HapticFeedback.mediumImpact();
      final loyaltyProvider = context.read<LoyaltyProvider>();
      await loyaltyProvider.refresh();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(
          context,
        ).showSuccess('Données actualisées'); // Keep as is or use translation
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(context).showError(l10n.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l10n),
      body: Consumer2<LoyaltyProvider, UserProvider>(
        builder: (context, loyaltyProvider, userProvider, _) {
          if (loyaltyProvider.isLoading && !_isInitialized) {
            return _buildLoadingState();
          }

          // Get points from UserProvider instead of LoyaltyProvider
          final points = userProvider.points;

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Points Card - using UserProvider points
                SliverToBoxAdapter(
                  child: _PointsBalanceCard(
                    currentPoints: points,
                    level: loyaltyProvider.currentLevel(points),
                    padding: 20,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Level Progress
                SliverToBoxAdapter(
                  child: _ProgressToNextLevel(
                    currentPoints: points,
                    nextLevelPoints: loyaltyProvider.nextLevelPoints(points),
                    currentLevel: loyaltyProvider.currentLevel(points),
                    nextLevel: loyaltyProvider.nextLevel(points),
                    progress: loyaltyProvider.getLevelProgress(points),
                    padding: 20,
                    l10n: l10n,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Earn Points Section
                SliverToBoxAdapter(
                  child: _EarnPointsSection(
                    rewards: loyaltyProvider.rewards,
                    l10n: l10n,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Referral Action
                SliverToBoxAdapter(
                  child: _ReferralCard(onTap: _shareReferralLink, l10n: l10n),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Transaction History
                _TransactionHistorySliver(
                  transactions: loyaltyProvider.transactions,
                  isLoadingMore: loyaltyProvider.isLoadingMore,
                  hasMore: loyaltyProvider.hasMore,
                  totalElements: loyaltyProvider.totalElements,
                  l10n: l10n,
                ),

                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.loyaltyProgram,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }
}

// ============================================================================
// POINTS BALANCE CARD
// ============================================================================

// Displays current pointsr, and level badge
class _PointsBalanceCard extends StatelessWidget {
  final int currentPoints;
  final String level;
  final double padding;

  const _PointsBalanceCard({
    required this.currentPoints,
    required this.level,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.availablePoints,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentPoints.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.points,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROGRESS TO NEXT LEVEL
// ============================================================================

// Shows progress bar and points needed to reach next level
class _ProgressToNextLevel extends StatelessWidget {
  final int currentPoints;
  final int nextLevelPoints;
  final String currentLevel;
  final String nextLevel;
  final double progress;
  final double padding;
  final AppLocalizations l10n;

  const _ProgressToNextLevel({
    required this.currentPoints,
    required this.nextLevelPoints,
    required this.currentLevel,
    required this.nextLevel,
    required this.progress,
    required this.padding,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final pointsNeeded = nextLevelPoints - currentPoints;

    return Container(
      margin: ResponsiveUtils.getResponsiveCardPadding(context),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progressToNextLevel(nextLevel),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$pointsNeeded pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentPoints / $nextLevelPoints ${l10n.points}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (pointsNeeded > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.needPointsToUnlock(pointsNeeded, nextLevel),
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
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// EARN POINTS SECTION
// ============================================================================

class _EarnPointsSection extends StatelessWidget {
  final List<LoyaltyReward> rewards;
  final AppLocalizations l10n;

  const _EarnPointsSection({required this.rewards, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              l10n.earnPoints,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...List.generate(rewards.length, (index) {
            final isLast = index == rewards.length - 1;
            return Column(
              children: [
                _RewardTile(reward: rewards[index], l10n: l10n),
                if (!isLast) Divider(height: 1, indent: 60),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final LoyaltyReward reward;
  final AppLocalizations l10n;

  const _RewardTile({required this.reward, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              reward.getLabel(context),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REFERRAL CARD
// ============================================================================

class _ReferralCard extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ReferralCard({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.referAFriend,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        l10n.shareAndEarnPoints,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TRANSACTION HISTORY SLIVER
// ============================================================================

class _TransactionHistorySliver extends StatelessWidget {
  final List<LoyaltyTransaction> transactions;
  final bool isLoadingMore;
  final bool hasMore;
  final int totalElements;
  final AppLocalizations l10n;

  const _TransactionHistorySliver({
    required this.transactions,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalElements,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty && !isLoadingMore) {
      return SliverToBoxAdapter(child: _buildEmptyState(l10n));
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.history,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (totalElements > 0)
                    Text(
                      totalElements.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            ...List.generate(transactions.length, (index) {
              final isLast = index == transactions.length - 1;
              return Column(
                children: [
                  _TransactionTile(
                    transaction: transactions[index],
                    l10n: l10n,
                  ),
                  if (!isLast) Divider(height: 1, indent: 60),
                ],
              );
            }),
            if (isLoadingMore)
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
              ),
            if (!hasMore && transactions.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    l10n.allTransactionsLoaded,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.grey400),
            SizedBox(height: 12),
            Text(
              l10n.noTransactions,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TRANSACTION TILE
// ============================================================================

class _TransactionTile extends StatelessWidget {
  final LoyaltyTransaction transaction;
  final AppLocalizations l10n;

  const _TransactionTile({required this.transaction, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, icon, description) = _getStyle(transaction.type, l10n);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  transaction.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.formattedPoints,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStyle(
    TransactionType type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case TransactionType.trajet:
        return (
          Color(0xFF10B981),
          Icons.check_circle_rounded,
          l10n.rideCompleted,
        );
      case TransactionType.parrainage:
        return (Color(0xFF3B82F6), Icons.people_rounded, l10n.referralBonus);
      case TransactionType.rating:
        return (Color(0xFFFBBF24), Icons.star_rounded, l10n.ratingBonus);
      case TransactionType.debit:
        return (
          Color(0xFFEF4444),
          Icons.remove_circle_rounded,
          l10n.pointsUsed,
        );
    }
  }
}