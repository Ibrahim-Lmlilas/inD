// Edit Password Page
//
// Allows users to change their account password
// Validates password strength and confirmation match

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/profile/data/services/profile_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class EditPasswordPage extends StatefulWidget {
  final String source;

  const EditPasswordPage({super.key, this.source = 'passenger'});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.currentPasswordRequired;
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.newPasswordRequired;
    }
    if (value.length < 8) {
      return l10n.atLeast8Characters;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.oneUppercaseLetter;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return l10n.oneLowercaseLetter;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.oneNumber;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return l10n.oneSpecialCharacter;
    }
    if (value == _currentPasswordController.text) {
      return l10n.newPasswordMustBeDifferent;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.confirmationRequired;
    }
    if (value != _newPasswordController.text) {
      return l10n.passwordsDontMatch;
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ProfileService>();
      final response = await apiService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        SnackBarService(context).showSuccess(l10n.passwordChangedSuccessfully);

        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          context.pop();
        }
      } else {
        SnackBarService(context).showError(l10n.errorChangingPassword);
        // logError('edit_password', response['message'] ?? 'Unknown error');
      }
    } catch (e) {
      if (!mounted) return;
      // logCritical('edit_password', 'Exception: $e');
      SnackBarService(context).showError(l10n.errorChangingPassword);
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
          l10n.editPassword,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.secureYourAccount,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              validator: _validateCurrentPassword,
              decoration: InputDecoration(
                labelText: l10n.currentPassword,
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword,
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // New Password
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              validator: _validateNewPassword,
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              onChanged: (_) => _formKey.currentState?.validate(),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              onChanged: (_) => _formKey.currentState?.validate(),
            ),
            const SizedBox(height: 24),

            // Password Requirements
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
                  Text(
                    l10n.passwordRequirementsMustContain,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement(l10n.atLeast8Characters),
                  _buildRequirement(l10n.oneUppercaseLetter),
                  _buildRequirement(l10n.oneLowercaseLetter),
                  _buildRequirement(l10n.oneNumber),
                  _buildRequirement(l10n.oneSpecialCharacter),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}