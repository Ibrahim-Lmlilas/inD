// Language Page
//
// Allows users to select app language (French, English, Arabic)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/account_settings/data/models/account_models.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

class LanguagePage extends StatefulWidget {
  final String source;

  const LanguagePage({super.key, this.source = 'passenger'});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  Language? _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final languageProvider = context.read<LanguageProvider>();
    _selectedLanguage = languageProvider.currentLanguage ?? Language.french;
  }

  Future<void> _handleSave() async {
    if (_selectedLanguage == null) return;

    final l10n = context.l10n;

    setState(() => _isLoading = true);

    try {
      final languageProvider = context.read<LanguageProvider>();
      final userProvider = context.read<UserProvider>();

      await languageProvider.changeLanguage(_selectedLanguage!);

      if (userProvider.isAuthenticated) {
        await userProvider.syncLanguageWithBackend(_selectedLanguage!);
      }

      if (mounted) {
        SnackBarService(
          context,
        ).showSuccess(l10n.languageChanged(_selectedLanguage!.displayName));

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.savingError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.language,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.selectLanguage,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          _buildLanguageOption(
            language: Language.french,
            icon: '🇫🇷',
            title: 'Français',
            description: 'Langue française',
            gradient: [const Color(0xFF0055A4), const Color(0xFFEF4135)],
          ),
          const SizedBox(height: 16),

          _buildLanguageOption(
            language: Language.english,
            icon: '🇬🇧',
            title: 'English',
            description: 'English language',
            gradient: [const Color(0xFF012169), const Color(0xFFC8102E)],
          ),
          const SizedBox(height: 16),

          _buildLanguageOption(
            language: Language.arabic,
            icon: '🇲🇦',
            title: 'العربية',
            description: 'اللغة العربية',
            gradient: [const Color(0xFFC1272D), const Color(0xFF006233)],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.languageChangeInfo,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.apply,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required Language language,
    required String icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    final isSelected = _selectedLanguage == language;

    return InkWell(
      onTap: () {
        setState(() => _selectedLanguage = language);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 28)
            else
              Icon(Icons.circle_outlined, color: AppColors.grey400, size: 28),
          ],
        ),
      ),
    );
  }
}
