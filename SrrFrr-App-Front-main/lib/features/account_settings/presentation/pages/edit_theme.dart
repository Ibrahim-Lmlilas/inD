// Theme Page
//
// Allows users to select app theme (Light, Dark, System)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ThemePage extends StatefulWidget {
  final String source;

  const ThemePage({super.key, this.source = 'passenger'});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String _selectedTheme = 'light'; // 'light', 'dark', 'system'

  @override
  void initState() {
    super.initState();
    // TODO: Load current theme from shared preferences or provider
    _selectedTheme = 'light';
  }

  Future<void> _handleSave() async {
    // TODO: Save theme preference to shared preferences
    // TODO: Update app theme using provider/bloc
    SnackBarService(
      context,
    ).showSuccess('Thème "${_getThemeLabel(_selectedTheme)}" appliqué');

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.pop(true);
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      case 'system':
        return 'Système';
      default:
        return 'Clair';
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Thème',
          style: TextStyle(
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
            'Personnalisez l\'apparence de l\'application',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Light Theme Option
          _buildThemeOption(
            value: 'light',
            icon: Icons.light_mode,
            title: 'Clair',
            description: 'Interface lumineuse pour une meilleure visibilité',
            gradient: [Colors.white, const Color(0xFFF3F4F6)],
            iconColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),

          // Dark Theme Option
          _buildThemeOption(
            value: 'dark',
            icon: Icons.dark_mode,
            title: 'Sombre',
            description: 'Réduit la fatigue oculaire en faible luminosité',
            gradient: [const Color(0xFF1F2937), const Color(0xFF111827)],
            iconColor: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 16),

          // System Theme Option
          _buildThemeOption(
            value: 'system',
            icon: Icons.brightness_auto,
            title: 'Système',
            description:
                'Suit automatiquement les paramètres de votre appareil',
            gradient: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
            iconColor: Colors.white,
          ),
          const SizedBox(height: 24),

          // Info Box
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
                    'Le thème système s\'adapte automatiquement selon l\'heure et vos préférences système',
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

          // Save Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                ),
              ),
              child: const Text(
                'Appliquer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String value,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required Color iconColor,
  }) {
    final isSelected = _selectedTheme == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedTheme = value);
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
              child: Icon(icon, size: 28, color: iconColor),
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
