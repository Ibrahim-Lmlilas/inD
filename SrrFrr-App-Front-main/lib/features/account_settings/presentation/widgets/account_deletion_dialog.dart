// account_deletion_dialog.dart
// 
// Confirmation dialog for account deletion with password verification

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isConfirmed) {
      _showError(l10n.iUnderstandIrreversible);
      return;
    }

    // Return data to caller
    Navigator.of(context).pop({
      'password': _passwordController.text.trim(),
      'reason': _reasonController.text.trim(),
      'confirmed': _isConfirmed,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Text(
                        l10n.deleteAccount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Warning message
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.actionIsIrreversible,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.accountDeletionWarning,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Password field
                Text(
                  l10n.password,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: l10n.enterPassword,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                        HapticFeedback.selectionClick();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.passwordRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Reason field (optional)
                Text(
                  l10n.reasonOptional,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  maxLength: 255,
                  decoration: InputDecoration(
                    hintText: l10n.whyDeleteAccount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Confirmation checkbox
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isConfirmed = !_isConfirmed);
                      HapticFeedback.selectionClick();
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isConfirmed,
                              onChanged: (value) {
                                setState(() => _isConfirmed = value ?? false);
                                HapticFeedback.selectionClick();
                              },
                              activeColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.iUnderstandIrreversible,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXL),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                          side: BorderSide(color: AppColors.borderColor),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.delete,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
