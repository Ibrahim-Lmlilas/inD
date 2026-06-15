// Enhanced Common Registration Widgets
//
// This file contains reusable UI components used across all registration steps.
// Components follow Material Design 3 guidelines and include:
// - Consistent styling and theming
// - Accessibility features and semantic labeling
// - Responsive design patterns
// - Comprehensive error handling
// - Optimized animations and transitions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';

// Collection of common widgets used throughout the registration flow
class RegistrationCommonWidgets {
  // Builds a modern application bar with enhanced back navigation
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required VoidCallback onBackPressed,
  }) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 22,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          onBackPressed();
        },
        tooltip: 'Retour',
        splashRadius: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Builds an enhanced progress indicator with smooth animations
  static Widget buildProgressIndicator({
    required BuildContext context,
    required int currentStep,
    required int totalSteps,
  }) {
    return Semantics(
      label:
          'Progression de l\'inscription: étape $currentStep sur $totalSteps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar with animated segments
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep - 1;
              final isCurrent = index == currentStep - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? AppSizes.paddingS : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      boxShadow: isCompleted || isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: AppSizes.paddingM),

          // Step counter with enhanced typography
          Text(
            'Étape $currentStep sur $totalSteps',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Builds a modern styled button with comprehensive state handling
  static Widget buildStyledButton({
    required BuildContext context,
    required String text,
    required bool isEnabled,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: isEnabled && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: FilledButton(
        onPressed: isEnabled && !isLoading
            ? () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              }
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: isEnabled && !isLoading
              ? AppColors.primary
              : Colors.grey.shade300,
          foregroundColor: isEnabled && !isLoading
              ? Colors.white
              : Colors.grey.shade500,
          elevation: isEnabled && !isLoading ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }

  // Builds a modern text field with comprehensive features
  static Widget buildStyledTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    required bool showError,
    required ValueChanged<String> onChanged,
    VoidCallback? onSubmitted,
    VoidCallback? onClearPressed,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? customPrefix,
  }) {
    final isCompleted = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: showError
                ? AppColors.error.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: showError ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon:
              customPrefix ??
              Icon(
                prefixIcon,
                color: focusNode.hasFocus || isCompleted
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22,
              ),
          suffixIcon: isCompleted && onClearPressed != null
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onClearPressed();
                  },
                  tooltip: 'Effacer',
                  splashRadius: 20,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide(
              color: showError
                  ? AppColors.error
                  : isCompleted
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              width: showError || isCompleted ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide(
              color: showError ? AppColors.error : AppColors.primary,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingL,
            horizontal: AppSizes.paddingL,
          ),
        ),
        onFieldSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      ),
    );
  }

  // Builds a help section with modern design and accessibility
  static Widget buildHelpSection({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: TextButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXL,
            vertical: AppSizes.paddingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Builds an information card with modern Material Design
  static Widget buildInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    Color? backgroundColor,
  }) {
    final bgColor =
        backgroundColor ?? AppColors.primary.withValues(alpha: 0.06);
    final borderColor = (backgroundColor ?? AppColors.primary).withValues(
      alpha: 0.15,
    );
    final iconBgColor = (backgroundColor ?? AppColors.primary).withValues(
      alpha: 0.15,
    );
    final iconColor = backgroundColor != null
        ? AppColors.textPrimary
        : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a modern selection card with enhanced interaction feedback
  static Widget buildSelectionCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final selectionColor = color ?? AppColors.primary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? selectionColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? selectionColor : Colors.grey.shade200,
                width: isSelected ? 2.5 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectionColor.withValues(alpha: 0.12)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? selectionColor
                        : AppColors.textSecondary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? selectionColor
                                  : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? selectionColor.withValues(alpha: 0.8)
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selectionColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
