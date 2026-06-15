/// Notification Pagination Info Widget
///
/// Displays pagination information at the top of notifications list.

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

/// Pagination info bar showing current count and total
class NotificationPaginationInfo extends StatelessWidget {
  final int currentCount;
  final int totalCount;
  final double padding;

  const NotificationPaginationInfo({
    super.key,
    required this.currentCount,
    required this.totalCount,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$currentCount sur $totalCount notifications',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
