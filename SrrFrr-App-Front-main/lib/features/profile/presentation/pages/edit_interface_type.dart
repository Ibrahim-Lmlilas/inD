// Interface Type Page
//
// Allows users to switch between Regular and Ladies interface
// Automatically loads current interface type from UserProvider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/providers/user_provider.dart';

class InterfaceTypePage extends StatefulWidget {
  final String source;

  const InterfaceTypePage({super.key, this.source = 'passenger'});

  @override
  State<InterfaceTypePage> createState() => _InterfaceTypePageState();
}

class _InterfaceTypePageState extends State<InterfaceTypePage> {
  late String _selectedInterface;
  bool _isLoading = false;
  String? _initialInterface;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    final isLadies = currentUser?.interfaceType == InterfaceType.ladies;
    _selectedInterface = isLadies ? 'ladies' : 'regular';
    _initialInterface = _selectedInterface;
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final newIsLadies = _selectedInterface == 'ladies';
    final currentIsLadies = _initialInterface == 'ladies';

    if (newIsLadies == currentIsLadies) {
      SnackBarService(context).showInfo(l10n.noChangesDetected);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Update interface type through UserProvider
      final newType = newIsLadies
          ? InterfaceType.ladies
          : InterfaceType.regular;
      final success = await userProvider.updateInterfaceType(newType);

      if (!mounted) return;

      if (success) {
        SnackBarService(context).showSuccess(l10n.interfaceUpdated);

        // Small delay to let the theme update visibly
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;
        context.pop(true);
      } else {
        SnackBarService(context).showError(l10n.errorUpdatingInterface);
      }
    } catch (e) {
      if (!mounted) return;
      logError('InterfaceTypePage', 'Error updating interface: $e');
      SnackBarService(context).showError(l10n.errorUpdatingInterface);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          l10n.interfaceType,
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
            l10n.chooseYourInterface,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Regular Interface Option
          _buildInterfaceOption(
            value: 'regular',
            icon: Icons.directions_car,
            title: l10n.standardInterface,
            description: l10n.standardInterfaceDescription,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),

          // Ladies Interface Option
          _buildInterfaceOption(
            value: 'ladies',
            icon: Icons.female,
            title: l10n.ladiesInterface,
            description: l10n.ladiesInterfaceDescription,
            color: AppColors.primaryPink,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.aboutLadiesInterface,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ladiesInterfaceInfo,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
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
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.save,
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

  Widget _buildInterfaceOption({
    required String value,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedInterface == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedInterface = value);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? color : AppColors.textSecondary,
              ),
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
                      color: isSelected ? color : AppColors.textPrimary,
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
              Icon(Icons.check_circle, color: color, size: 28)
            else
              Icon(Icons.circle_outlined, color: AppColors.grey400, size: 28),
          ],
        ),
      ),
    );
  }
}