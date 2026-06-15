// KYC Input Widget
//
// Combined registration form collecting all user information in one step:
// - Profile picture (optional)
// - First name and last name
// - Gender selection
// - Phone number
// - Password and confirmation
// - Email (optional)
// - Terms and conditions acceptance

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class KycInputWidgets {
  // Builds the complete KYC input content
  static Widget buildKycInputContent({
    required BuildContext context,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController phoneController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController emailController,
    required FocusNode firstNameFocusNode,
    required FocusNode lastNameFocusNode,
    required FocusNode phoneFocusNode,
    required FocusNode passwordFocusNode,
    required FocusNode confirmPasswordFocusNode,
    required FocusNode emailFocusNode,
    required String? selectedGender,
    required InterfaceType? selectedInterface,
    required String? profilePhotoPath,
    required bool showFirstNameError,
    required bool showLastNameError,
    required bool showPhoneError,
    required bool showGenderError,
    required bool showPasswordError,
    required bool showConfirmPasswordError,
    required bool isPasswordVisible,
    required bool isConfirmPasswordVisible,
    required bool termsAccepted,
    required bool isLoading,
    required bool canProceed,
    required String missingFieldsMessage,
    required Function(String) onFirstNameChanged,
    required Function(String) onLastNameChanged,
    required Function(String) onPhoneChanged,
    required Function(String?) onGenderChanged,
    required Function(InterfaceType?) onInterfaceChanged,
    required Function(String) onPasswordChanged,
    required Function(String) onConfirmPasswordChanged,
    required Function(String) onEmailChanged,
    required VoidCallback onTogglePasswordVisibility,
    required VoidCallback onToggleConfirmPasswordVisibility,
    required Function(bool) onTermsChanged,
    required Function(String?) onPhotoSelected,
    required VoidCallback onProceedToNext,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context),
          const SizedBox(height: AppSizes.paddingXL),

          // Profile Photo (Optional)
          _buildProfilePhotoSection(
            context: context,
            profilePhotoPath: profilePhotoPath,
            onPhotoSelected: onPhotoSelected,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // First Name
          _buildTextField(
            context: context,
            controller: firstNameController,
            focusNode: firstNameFocusNode,
            label: l10n.firstName,
            hint: l10n.enterYourFirstName,
            icon: Icons.person_outline,
            showError: showFirstNameError,
            onChanged: onFirstNameChanged,
            onFieldSubmitted: (_) => lastNameFocusNode.requestFocus(),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Last Name
          _buildTextField(
            context: context,
            controller: lastNameController,
            focusNode: lastNameFocusNode,
            label: l10n.lastName,
            hint: l10n.enterYourLastName,
            icon: Icons.person_outline,
            showError: showLastNameError,
            onChanged: onLastNameChanged,
            onFieldSubmitted: (_) => phoneFocusNode.requestFocus(),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Gender Dropdown
          _buildGenderDropdown(
            context: context,
            selectedGender: selectedGender,
            showError: showGenderError,
            onChanged: onGenderChanged,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Interface Selection (only for female users)
          if (selectedGender == 'female') ...[
            _buildInterfaceSelection(
              context: context,
              selectedInterface: selectedInterface,
              onChanged: onInterfaceChanged,
            ),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // Phone Number
          _buildPhoneField(
            context: context,
            controller: phoneController,
            focusNode: phoneFocusNode,
            showError: showPhoneError,
            onChanged: onPhoneChanged,
            onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Email (Optional)
          _buildTextField(
            context: context,
            controller: emailController,
            focusNode: emailFocusNode,
            label: l10n.email,
            hint: l10n.emailPlaceholder,
            icon: Icons.email_outlined,
            showError: false,
            onChanged: onEmailChanged,
            onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Password
          _buildPasswordField(
            context: context,
            controller: passwordController,
            focusNode: passwordFocusNode,
            label: l10n.password,
            hint: l10n.minimumPassword,
            showError: showPasswordError,
            isPasswordVisible: isPasswordVisible,
            onChanged: onPasswordChanged,
            onToggleVisibility: onTogglePasswordVisibility,
            onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Confirm Password
          _buildPasswordField(
            context: context,
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            label: l10n.confirmPassword,
            hint: l10n.retypePassword,
            showError: showConfirmPasswordError,
            isPasswordVisible: isConfirmPasswordVisible,
            onChanged: onConfirmPasswordChanged,
            onToggleVisibility: onToggleConfirmPasswordVisibility,
            onFieldSubmitted: (_) {
              if (canProceed && !isLoading) {
                onProceedToNext();
              }
            },
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Password Requirements
          _buildPasswordRequirements(context, passwordController.text),
          const SizedBox(height: AppSizes.paddingL),

          // Terms and Conditions
          _buildTermsCheckbox(
            context: context,
            termsAccepted: termsAccepted,
            onChanged: onTermsChanged,
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // Missing Fields Message (if button disabled)
          if (!canProceed && missingFieldsMessage.isNotEmpty) ...[
            _buildMissingFieldsInfo(context, missingFieldsMessage),
            const SizedBox(height: AppSizes.paddingM),
          ],

          // Continue Button
          _buildContinueButton(
            context: context,
            canProceed: canProceed,
            isLoading: isLoading,
            onProceed: onProceedToNext,
          ),
          const SizedBox(height: AppSizes.paddingL),
        ],
      ),
    );
  }

  // Header section
  static Widget _buildHeaderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.createYourAccount,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          l10n.fillYourInformation,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Profile photo section
  static Widget _buildProfilePhotoSection({
    required BuildContext context,
    required String? profilePhotoPath,
    required Function(String?) onPhotoSelected,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.paddingS),
        Center(
          child: GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (image != null) {
                onPhotoSelected(image.path);
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey100,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: profilePhotoPath != null
                  ? ClipOval(
                      child: Image.file(
                        File(profilePhotoPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.camera_alt, size: 40, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Center(
          child: Text(
            profilePhotoPath != null
                ? l10n.touchToChangePhoto
                : l10n.touchToAddPhoto,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // Generic text field
  static Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool showError,
    required Function(String) onChanged,
    required Function(String) onFieldSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError
                    ? AppColors.error
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: showError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Phone field with +212 prefix
  static Widget _buildPhoneField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool showError,
    required Function(String) onChanged,
    required Function(String) onFieldSubmitted,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.phoneNumber,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: '612345678',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+212',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 20,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError
                    ? AppColors.error
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: showError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Gender dropdown
static Widget _buildGenderDropdown({
    required BuildContext context,
    required String? selectedGender,
    required bool showError,
    required Function(String?) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gender,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        DropdownButtonFormField2<String>(
          value: selectedGender,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            prefixIcon: Icon(
              selectedGender == 'male'
                  ? Icons.male
                  : selectedGender == 'female'
                  ? Icons.female
                  : Icons.person_outline,
              size: 20,
              color: selectedGender == 'male'
                  ? AppColors.primary
                  : Color(0xFFE91E63),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError
                    ? AppColors.error
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: showError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
          ),
          hint: Text(
            l10n.selectYourGender,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'male',
              child: Row(
                children: [
                  // Icon(Icons.male, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(l10n.male),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'female',
              child: Row(
                children: [
                  // Icon(Icons.female, size: 20, color: Color(0xFFE91E63)),
                  const SizedBox(width: 12),
                  Text(l10n.female),
                ],
              ),
            ),
          ],
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Interface selection for female users
  static Widget _buildInterfaceSelection({
    required BuildContext context,
    required InterfaceType? selectedInterface,
    required Function(InterfaceType?) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseYourInterface,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),

        // Regular interface option
        _buildInterfaceOption(
          context: context,
          interfaceType: InterfaceType.regular,
          title: l10n.srrfrrRegular,
          subtitle: l10n.standardInterface,
          isSelected: selectedInterface == InterfaceType.regular,
          onTap: () => onChanged(InterfaceType.regular),
        ),
        const SizedBox(height: AppSizes.paddingS),

        // Ladies interface option
        _buildInterfaceOption(
          context: context,
          interfaceType: InterfaceType.ladies,
          title: l10n.srrfrrLadies,
          subtitle: l10n.femaleDriversOnly,
          isSelected: selectedInterface == InterfaceType.ladies,
          onTap: () => onChanged(InterfaceType.ladies),
        ),
      ],
    );
  }

  static Widget _buildInterfaceOption({
    required BuildContext context,
    required InterfaceType interfaceType,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = interfaceType == InterfaceType.ladies
        ? const Color(0xFFE91E63)
        : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            Icon(
              interfaceType == InterfaceType.ladies
                  ? Icons.female
                  : Icons.directions_car,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  // Password field
  static Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool showError,
    required bool isPasswordVisible,
    required Function(String) onChanged,
    required VoidCallback onToggleVisibility,
    required Function(String) onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isPasswordVisible,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            letterSpacing: isPasswordVisible ? 0 : 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
              letterSpacing: 0,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              size: 20,
              color: focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError
                    ? AppColors.error
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: showError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: showError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Password requirements
  static Widget _buildPasswordRequirements(
    BuildContext context,
    String password,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordRequirements,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildRequirementItem(l10n.atLeast8Characters, hasMinLength),
          _buildRequirementItem(l10n.oneUppercaseLetter, hasUpperCase),
          _buildRequirementItem(l10n.oneLowercaseLetter, hasLowerCase),
          _buildRequirementItem(l10n.oneNumber, hasNumber),
          _buildRequirementItem(l10n.oneSpecialCharacter, hasSpecialChar),
        ],
      ),
    );
  }

  static Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.paddingS),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isMet ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Terms checkbox with clickable link
  static Widget _buildTermsCheckbox({
    required BuildContext context,
    required bool termsAccepted,
    required Function(bool) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => onChanged(!termsAccepted),
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: termsAccepted
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: termsAccepted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: termsAccepted ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: termsAccepted
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusXS),
              ),
              child: termsAccepted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Prevent checkbox toggle when tapping the link
                  _showTermsAndConditions(context);
                },
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: l10n.iAcceptThe),
                      TextSpan(
                        text: l10n.termsOfUse,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show terms and conditions in a modal bottom sheet
  static void _showTermsAndConditions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSizes.paddingM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.termsOfUse,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: l10n.close,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: _buildTermsContent(context),
                ),
              ),

              // Close button at bottom
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      l10n.close,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build terms content - placeholder for actual terms
  static Widget _buildTermsContent(BuildContext context) {
    // This is a placeholder. You would replace this with actual terms content
    // potentially stored in localized strings or fetched from a backend
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTermsSection(
          context,
          'General Terms of Use',
          'By using the SRR FRR application, you agree to be bound by these terms of use. If you do not accept these terms, please do not use our service.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Use of Service',
          'SRR FRR is a ridesharing platform that connects drivers and passengers. You agree to use the service responsibly and in accordance with applicable laws.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'User Responsibilities',
          'You are responsible for maintaining the confidentiality of your account and all activities under your account. You agree to provide accurate and up-to-date information.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Safety and Conduct',
          'All drivers must possess a valid driver\'s license and appropriate insurance. Passengers and drivers agree to follow road safety rules.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Payments and Fees',
          'Rates are calculated based on distance and travel time. Payments are processed securely through our platform. Service fees may apply.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Cancellation Policy',
          'Cancellations can be made according to our cancellation policy. Fees may apply for late or repeated cancellations.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Personal Data Protection',
          'Your personal data is collected and processed in accordance with our privacy policy and GDPR. We are committed to protecting your privacy and the security of your information.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Limitation of Liability',
          'SRR FRR acts as an intermediary between drivers and passengers. We strive to provide reliable service but cannot guarantee continuous service availability. SRR FRR cannot be held liable for direct or indirect damages resulting from use of the service.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Modifications to Terms',
          'We reserve the right to modify these terms at any time. Users will be notified of significant changes via in-app notification. Continued use of the service after modification constitutes acceptance of the new terms.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Termination',
          'You may terminate your account at any time from the app settings. SRR FRR reserves the right to suspend or terminate your account in case of violation of these terms.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildTermsSection(
          context,
          'Applicable Law',
          'These terms are governed by Moroccan law. Any dispute relating to the interpretation or execution of these terms will be submitted to the competent courts of Morocco.',
        ),
        const SizedBox(height: AppSizes.paddingL),
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'These terms of use were last updated on September 15, 2024.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL),
      ],
    );
  }

  // Build individual terms section
  static Widget _buildTermsSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  static Widget _buildContinueButton({
    required BuildContext context,
    required bool canProceed,
    required bool isLoading,
    required VoidCallback onProceed,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: canProceed && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: canProceed && !isLoading ? onProceed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed && !isLoading
              ? AppColors.primary
              : Colors.grey.shade300,
          foregroundColor: canProceed && !isLoading
              ? Colors.white
              : Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // Missing fields information widget
  static Widget _buildMissingFieldsInfo(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
