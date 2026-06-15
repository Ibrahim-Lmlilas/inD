/// Notification Loading Widgets
///
/// Provides loading states for notifications page.

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

/// Full-page loading indicator
class NotificationLoadingState extends StatelessWidget {
  const NotificationLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement des notifications...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator for pagination (bottom of list)
class NotificationLoadingMoreIndicator extends StatelessWidget {
  const NotificationLoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
