// Navigation Tile Widget
// Reusable tile for navigating to settings pages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

class NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const NavigationTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (iconColor ?? titleColor ?? AppColors.primary)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? titleColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
