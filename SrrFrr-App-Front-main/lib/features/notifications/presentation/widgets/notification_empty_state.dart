/// Notification Empty State Widget
///
/// Displays a friendly empty state when there are no notifications.

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

/// Empty state widget for notifications list
class NotificationEmptyState extends StatelessWidget {
  final double padding;

  const NotificationEmptyState({super.key, this.padding = 16.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EmptyStateIcon(),
            const SizedBox(height: 32),
            const _EmptyStateTitle(),
            const SizedBox(height: 12),
            const _EmptyStateMessage(),
          ],
        ),
      ),
    );
  }
}

/// Icon container for empty state
class _EmptyStateIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_none_rounded,
        size: 60,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Title for empty state
class _EmptyStateTitle extends StatelessWidget {
  const _EmptyStateTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Aucune notification',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }
}

/// Message for empty state
class _EmptyStateMessage extends StatelessWidget {
  const _EmptyStateMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Vous n\'avez pas encore reçu\nde notifications',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
