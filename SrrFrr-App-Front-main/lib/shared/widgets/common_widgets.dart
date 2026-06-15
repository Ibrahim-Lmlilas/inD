/// Common Widgets
/// 
/// Reusable UI components used across the application

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class CommonWidgets {
  CommonWidgets._();

  /// Standard decorated text field with consistent styling
  static Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    required ValueChanged<String> onChanged,
    bool showError = false,
    bool isValid = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    Widget? suffixIcon,
    Widget? prefixWidget,
    int? maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          prefixIcon: prefixWidget ??
              Icon(
                prefixIcon,
                color: focusNode.hasFocus || controller.text.isNotEmpty
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(
              color: showError
                  ? AppColors.error
                  : isValid
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
              width: showError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(
              color: showError ? AppColors.error : AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingM,
            horizontal: AppSizes.paddingL,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Phone number field with Moroccan prefix (+212)
  static Widget buildPhoneField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    bool showError = false,
    bool isValid = false,
    VoidCallback? onClear,
  }) {
    return buildTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: 'Numéro de téléphone',
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
      showError: showError,
      isValid: isValid,
      keyboardType: TextInputType.phone,
      prefixWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_outlined,
              color: focusNode.hasFocus || controller.text.isNotEmpty
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSizes.paddingS),
            const Text(
              '+212',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Container(
              width: 1,
              height: 20,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
      suffixIcon: controller.text.isNotEmpty && onClear != null
          ? IconButton(
              icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
              onPressed: onClear,
            )
          : null,
    );
  }

  /// Password field with visibility toggle
  static Widget buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    bool showError = false,
    bool isValid = false,
    String hintText = 'Mot de passe',
    VoidCallback? onSubmitted,
  }) {
    return buildTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      onChanged: onChanged,
      showError: showError,
      isValid: isValid,
      obscureText: !isPasswordVisible,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }

  /// Primary elevated button
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double height = 56,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: onPressed != null
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
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
      ),
    );
  }

  /// Secondary outlined button
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 56,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// Circular avatar with initial
  static Widget buildAvatar({
    required String initial,
    Color backgroundColor = const Color(0xFF4AC1F7),
    Color textColor = Colors.white,
    double size = 48,
    double fontSize = 20,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Standard card container
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Info card with icon, label, and value
  static Widget buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Loading indicator overlay
  static Widget buildLoadingOverlay({String message = 'Chargement...'}) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state widget
  static Widget buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.paddingL),
              action,
            ],
          ],
        ),
      ),
    );
  }
}