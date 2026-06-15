// Subscription History Tab Widget
// lib/features/subscription/presentation/widgets/subscription_tabs/subscription_history_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:srrfrr_app_front/features/subscription/presentation/widgets/cards/subscription_history.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class SubscriptionHistoryTab extends StatefulWidget {
  final SubscriptionProvider provider;
  final double padding;

  const SubscriptionHistoryTab({
    super.key,
    required this.provider,
    required this.padding,
  });

  @override
  State<SubscriptionHistoryTab> createState() => _SubscriptionHistoryTabState();
}

class _SubscriptionHistoryTabState extends State<SubscriptionHistoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.provider.subscriptionHistory.isEmpty) {
        widget.provider.fetchSubscriptionHistory(isInitial: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!widget.provider.isLoadingMore &&
            widget.provider.hasMore &&
            !widget.provider.isLoading) {
          widget.provider.loadMoreHistory();
        }
      }
    });
  }

  Future<void> _refreshHistory() async {
    HapticFeedback.lightImpact();
    await widget.provider.fetchSubscriptionHistory(isInitial: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.provider.isLoading &&
        widget.provider.subscriptionHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (widget.provider.subscriptionHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(widget.padding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  size: 48,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noHistory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.historyPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      color: AppColors.primary,
      child: Column(
        children: [
          if (widget.provider.totalElements > 0)
            Padding(
              padding: EdgeInsets.all(widget.padding),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.itemsOfTotal(
                    widget.provider.subscriptionHistory.length,
                    widget.provider.totalElements,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(widget.padding),
              itemCount:
                  widget.provider.subscriptionHistory.length +
                  (widget.provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.provider.subscriptionHistory.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                  );
                }

                final subscription = widget.provider.subscriptionHistory[index];
                return SubscriptionHistoryCard(
                  subscription: subscription,
                  padding: widget.padding,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
