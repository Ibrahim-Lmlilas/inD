// Appearance Section Widget
// Settings for language, theme, and interface type

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/widgets/navigation_tile.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

class AppearanceSection extends StatelessWidget {
  final void Function(String) onNavigate;
  final bool isFemaleUser;
  final bool isLadiesInterface;
  final double padding;

  const AppearanceSection({
    super.key,
    required this.onNavigate,
    required this.isFemaleUser,
    required this.isLadiesInterface,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageProvider = context.watch<LanguageProvider>();
    final currentLanguage = languageProvider.currentLanguage ?? Language.french;

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
              icon: Icons.language,
              title: l10n.language,
              subtitle: currentLanguage.displayName,
              onTap: () => onNavigate('/system/edit-language'),
            ),
            Divider(height: 1, indent: 68, color: AppColors.dividerColor),
            NavigationTile(
              icon: Icons.brightness_6,
              title: l10n.theme,
              subtitle: l10n.light,
              onTap: () => onNavigate('/system/edit-theme'),
            ),
            if (isFemaleUser) ...[
              Divider(height: 1, indent: 68, color: AppColors.dividerColor),
              NavigationTile(
                icon: isLadiesInterface ? Icons.female : Icons.directions_car,
                title: l10n.interfaceType,
                subtitle: isLadiesInterface
                    ? l10n.ladiesInterface
                    : l10n.regularInterface,
                onTap: () => onNavigate('/system/edit-interface'),
                iconColor: isLadiesInterface ? const Color(0xFFEC4899) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
