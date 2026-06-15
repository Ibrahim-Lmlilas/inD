/// Notifications Page - Multilingual Support
///
/// Displays paginated notifications with language-aware content.
/// Uses l10n for static UI text, backend translations for notification content.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/providers/notification_provider.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/widgets/notification_app_bar.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/widgets/notification_card.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/widgets/notification_loading.dart';
import 'package:srrfrr_app_front/features/notifications/presentation/widgets/notification_pagination_info.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Notifications page with pagination and real-time updates
class NotificationsPage extends StatefulWidget {
  /// Source mode: 'passenger' or 'driver'
  final String source;

  const NotificationsPage({super.key, this.source = 'passenger'});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  // Pagination state
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _setupTimeagoLocales();
    _setupScrollListener();

    // Load initial notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // TIMEAGO LOCALE SETUP
  // ==========================================================================

  void _setupTimeagoLocales() {
    // Configure timeago for all supported languages
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  // ==========================================================================
  // SCROLL LISTENER FOR PAGINATION
  // ==========================================================================

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final nearBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200;

      if (nearBottom && !_isLoadingMore) {
        _loadMoreNotifications();
      }
    });
  }

  // ==========================================================================
  // DATA LOADING
  // ==========================================================================

  Future<void> _loadInitialNotifications() async {
    if (!mounted) return;

    final provider = context.read<NotificationProvider>();
    await provider.loadNotificationHistory(
      _isDriverMode,
      page: 0,
      size: _pageSize,
    );
  }

  Future<void> _loadMoreNotifications() async {
    if (!mounted) return;

    final provider = context.read<NotificationProvider>();

    if (!provider.hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await provider.loadMoreNotifications(
      _isDriverMode,
      page: provider.currentPage + 1,
      size: _pageSize,
    );

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshNotifications() async {
    HapticFeedback.mediumImpact();
    await _loadInitialNotifications();
  }

  // ==========================================================================
  // USER ACTIONS
  // ==========================================================================

  Future<void> _markAllAsRead() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      HapticFeedback.lightImpact();

      final provider = context.read<NotificationProvider>();
      await provider.markAllAsRead();

      if (mounted) {
        SnackBarService(context).showSuccess(l10n.notificationsMarkedAsRead);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.notificationsMarkError);
      }
    }
  }

  Future<void> _onNotificationTap(String notificationId, bool isUnread) async {
    final l10n = AppLocalizations.of(context)!;

    HapticFeedback.lightImpact();

    if (isUnread) {
      try {
        final provider = context.read<NotificationProvider>();
        await provider.markAsRead(notificationId);
      } catch (e) {
        if (mounted) {
          SnackBarService(context).showError(l10n.notificationsMarkError);
        }
      }
    }

    // TODO: Navigate to relevant screen based on notification type
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  bool get _isDriverMode => widget.source == 'driver';

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NotificationAppBar(
        onBack: () => context.pop(),
        onMarkAllRead: _markAllAsRead,
        showMarkAllRead: context.select<NotificationProvider, bool>(
          (provider) => provider.hasUnread,
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          // Loading state
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const NotificationLoadingState();
          }

          // Empty state
          if (provider.notifications.isEmpty) {
            return NotificationEmptyState(padding: padding);
          }

          // Notifications list
          return Column(
            children: [
              // Pagination info
              NotificationPaginationInfo(
                currentCount: provider.notifications.length,
                totalCount: provider.totalElements,
                padding: padding,
              ),

              // Notification list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount:
                        provider.notifications.length +
                        (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at bottom
                      if (index == provider.notifications.length) {
                        return const NotificationLoadingMoreIndicator();
                      }

                      final notification = provider.notifications[index];

                      return NotificationCard(
                        notification: notification,
                        padding: padding,
                        onTap: () => _onNotificationTap(
                          notification.id,
                          notification.isUnread,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}