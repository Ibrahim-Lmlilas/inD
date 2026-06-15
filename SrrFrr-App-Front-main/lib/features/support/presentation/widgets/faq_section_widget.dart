// FAQ Section Widget
// Displays a collapsible section of FAQ items

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/support/data/models/support_models.dart';

class FaqSectionWidget extends StatelessWidget {
  final FaqSection section;
  final String? expandedFaqId;
  final Function(String) onToggleExpansion;

  const FaqSectionWidget({
    super.key,
    required this.section,
    required this.expandedFaqId,
    required this.onToggleExpansion,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'directions_car':
        return Icons.directions_car;
      case 'payment':
        return Icons.payment;
      case 'security':
        return Icons.security;
      case 'how_to_reg':
        return Icons.how_to_reg;
      case 'build':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    _getIconData(section.icon),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = section.items[index];
              final isExpanded = expandedFaqId == item.id;

              return _FaqItemWidget(
                item: item,
                isExpanded: isExpanded,
                onTap: () => onToggleExpansion(item.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqItemWidget extends StatelessWidget {
  final FaqItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FaqItemWidget({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                item.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}