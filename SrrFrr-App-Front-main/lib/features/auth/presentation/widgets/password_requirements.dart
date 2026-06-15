// Reusable Password Requirements Widget
//
// Displays password validation requirements with real-time feedback
// Used in registration and password reset flows

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/input_validators.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementsWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                l10n.passwordRequirements,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildRequirement(
            l10n.atLeast8Characters,
            password.length >= InputValidators.minPasswordLength,
          ),
          _buildRequirement(
            l10n.oneUppercaseLetter,
            password.contains(RegExp(r'[A-Z]')),
          ),
          _buildRequirement(
            l10n.oneLowercaseLetter,
            password.contains(RegExp(r'[a-z]')),
          ),
          _buildRequirement(
            l10n.oneNumber,
            password.contains(RegExp(r'[0-9]')),
          ),
          _buildRequirement(
            l10n.oneSpecialCharacter,
            password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isMet ? AppColors.success : AppColors.textSecondary,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
