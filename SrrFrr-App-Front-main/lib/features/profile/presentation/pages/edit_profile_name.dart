// Edit Profile Page
//
// Allows users to view and update their first name and last name
// Supports both view-only mode (isEditing: false) and edit mode (isEditing: true)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

class EditProfilePage extends StatefulWidget {
  final String source;
  final bool isEditing;

  const EditProfilePage({
    super.key,
    this.source = 'passenger',
    this.isEditing = false,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  UserProvider get provider => context.read<UserProvider>();

  bool _isLoading = false;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditing;
    _firstNameController.text = provider.currentUser?.firstName ?? '';
    _lastNameController.text = provider.currentUser?.lastName ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, String fieldName) {
    if (!_isEditMode) return null; // Skip validation in view mode

    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return fieldName == l10n.firstName
          ? l10n.firstNameRequired
          : l10n.lastNameRequired;
    }
    if (value.length < 2) {
      return l10n.nameTooShort(fieldName);
    }
    if (value.length > 50) {
      return l10n.nameTooLong(fieldName);
    }
    // Only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value)) {
      return l10n.invalidCharacters;
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    // Check if any changes were made
    if (_firstNameController.text.trim() == provider.currentUser?.firstName &&
        _lastNameController.text.trim() == provider.currentUser?.lastName) {
      SnackBarService(context).showInfo(l10n.noChangesDetected);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final apiService = context.read<ApiService>();
      // final response = await apiService.updateProfile(
      //   firstName: _firstNameController.text.trim(),
      //   lastName: _lastNameController.text.trim(),
      // );

      if (!mounted) return;

      // if (response['success'] == true) {
      // Update user provider
      // final userProvider = context.read<UserProvider>();
      // await userProvider.refreshUser();

      //   SnackBarService(context).showSuccess(l10n.profileUpdatedSuccess);

      //   await Future.delayed(const Duration(milliseconds: 500));
      //   if (mounted) {
      //     context.pop();
      //   }
      // } else {
      //   logError('edit_profile_page', response['message']);
      //   SnackBarService(context).showError(l10n.profileUpdateFailed);
      // }
    } catch (e) {
      if (!mounted) return;
      SnackBarService(context).showError('Error updating profile');
      logError('edit_profile_page', e.toString());
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
          _isEditMode ? l10n.editProfile : l10n.personalInformation,
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
              _isEditMode ? l10n.updatePersonalInfo : l10n.viewPersonalInfo,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // First Name
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              readOnly: !_isEditMode,
              enabled: _isEditMode,
              validator: (value) => _validateName(value, l10n.firstName),
              style: TextStyle(
                color: _isEditMode
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: _isEditMode ? FontWeight.w500 : FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: l10n.firstName,
                hintText: l10n.firstNameHint,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: _isEditMode
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                filled: !_isEditMode,
                fillColor: !_isEditMode ? AppColors.grey200 : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: _isEditMode ? AppColors.grey300 : AppColors.grey300,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              readOnly: !_isEditMode,
              enabled: _isEditMode,
              validator: (value) => _validateName(value, l10n.lastName),
              style: TextStyle(
                color: _isEditMode
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: _isEditMode ? FontWeight.w500 : FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: l10n.lastName,
                hintText: l10n.lastNameHint,
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: _isEditMode
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                filled: !_isEditMode,
                fillColor: !_isEditMode ? AppColors.grey200 : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: _isEditMode ? AppColors.grey300 : AppColors.grey300,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Box
            if (_isEditMode)
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
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.infoForReservations,
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

            if (_isEditMode) const SizedBox(height: 32),

            // Save Button (only in edit mode)
            if (_isEditMode)
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
}
