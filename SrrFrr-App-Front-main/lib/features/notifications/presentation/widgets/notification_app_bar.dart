/// Notification App Bar Widget
///
/// Custom app bar for notifications page with mark-all-as-read action.

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

/// App bar for notifications page
class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;
  final bool showMarkAllRead;

  const NotificationAppBar({
    super.key,
    required this.onBack,
    this.onMarkAllRead,
    this.showMarkAllRead = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: onBack,
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        if (showMarkAllRead)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            elevation: 8,
            onSelected: (value) {
              if (value == 'mark_all_read' && onMarkAllRead != null) {
                onMarkAllRead!();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tout marquer comme lu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
