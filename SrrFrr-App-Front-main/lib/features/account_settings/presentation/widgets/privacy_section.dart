// Privacy Section Widget
// Settings for privacy and data management

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/navigation_tile.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class PrivacySection extends StatelessWidget {
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTerms;
  final VoidCallback onDeleteAccount;
  final double padding;

  const PrivacySection({
    super.key,
    required this.onPrivacyPolicy,
    required this.onTerms,
    required this.onDeleteAccount,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
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
          children: [
            NavigationTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: onPrivacyPolicy,
            ),
            Divider(height: 1, indent: 68, color: AppColors.dividerColor),
            NavigationTile(
              icon: Icons.description_outlined,
              title: l10n.termsAndConditions,
              onTap: onTerms,
            ),
            Divider(height: 1, indent: 68, color: AppColors.dividerColor),
            NavigationTile(
              icon: Icons.delete_outline,
              title: l10n.deleteMyAccount,
              titleColor: AppColors.error,
              onTap: onDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}