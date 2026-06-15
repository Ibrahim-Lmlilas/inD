// Reusable OTP Input Widget
//
// A standalone, reusable OTP input component that can be embedded
// in any page requiring OTP verification (registration, password reset, etc.)
//
// Features:
// - 6-digit OTP input fields with auto-focus navigation (left to right only)
// - Error state with shake animation
// - Timer countdown with resend button
// - Clear button to reset all fields
// - Fully customizable via parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class OtpInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final String? errorMessage;
  final int remainingSeconds;
  final Animation<double> shakeAnimation;
  final AnimationController shakeController;
  final Function(String, int) onInputChange;
  final VoidCallback onResend;
  final VoidCallback onClear;

  const OtpInputWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    this.errorMessage,
    required this.remainingSeconds,
    required this.shakeAnimation,
    required this.shakeController,
    required this.onInputChange,
    required this.onResend,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const padding = 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // OTP Input Fields with shake animation - ALWAYS LTR
        Directionality(
          textDirection: TextDirection.ltr,
          child: AnimatedBuilder(
            animation: shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  shakeAnimation.value *
                      8 *
                      ((shakeController.status == AnimationStatus.forward)
                          ? 1
                          : -1),
                  0,
                ),
                child: _buildOtpInputSection(padding),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Error message
        if (hasError) ...[
          _buildErrorMessage(context, l10n, padding),
          const SizedBox(height: 16),
        ],

        // Timer / Resend / Clear section
        _buildActionsSection(context, l10n, padding),
      ],
    );
  }

  Widget _buildOtpInputSection(double padding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const fieldSpacing = 6.0;
        const totalSpacing = fieldSpacing * 5;
        final fieldSize = (availableWidth - totalSpacing - (padding * 2)) / 6;
        const maxFieldSize = 56.0;
        final finalFieldSize = fieldSize > maxFieldSize
            ? maxFieldSize
            : fieldSize;

        return Center(
          child: Wrap(
            spacing: fieldSpacing,
            alignment: WrapAlignment.center,
            children: List.generate(6, (index) {
              return SizedBox(
                width: finalFieldSize,
                height: finalFieldSize,
                child: _buildOtpField(context, index),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildOtpField(BuildContext context, int index) {
    final isCompleted = controllers[index].text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? AppColors.error.withValues(alpha: 0.2)
                : isCompleted
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: hasError ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: hasError
              ? AppColors.error
              : isCompleted
              ? AppColors.primary
              : AppColors.textPrimary,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide(
              color: hasError
                  ? AppColors.error
                  : isCompleted
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.grey.shade300,
              width: hasError || isCompleted ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.primary,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          onInputChange(value, index);
          // Only move forward, never backward
          if (value.isNotEmpty && index < focusNodes.length - 1) {
            focusNodes[index + 1].requestFocus();
            HapticFeedback.selectionClick();
          } else if (value.isNotEmpty && index == focusNodes.length - 1) {
            focusNodes[index].unfocus();
            HapticFeedback.selectionClick();
          }
        },
        onTap: () {
          controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: controllers[index].text.length,
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    AppLocalizations l10n,
    double padding,
  ) {
    return Container(
      padding: EdgeInsets.all(padding * 0.8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          SizedBox(width: padding * 0.6),
          Flexible(
            child: Text(
              errorMessage ?? l10n.incorrectCode,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    AppLocalizations l10n,
    double padding,
  ) {
    final hasContent = controllers.any(
      (controller) => controller.text.isNotEmpty,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Timer or Resend button
        if (remainingSeconds > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
                SizedBox(width: padding / 2),
                Text(
                  l10n.resendCodeIn(remainingSeconds),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onResend();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.resendCode),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: EdgeInsets.symmetric(
                horizontal: padding * 2,
                vertical: padding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
          ),

        // Clear button (only show if there's content)
        if (hasContent)
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onClear();
            },
            icon: const Icon(Icons.clear_rounded, size: 18),
            label: Text(l10n.clear),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              padding: EdgeInsets.symmetric(
                horizontal: padding * 2,
                vertical: padding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
          ),
      ],
    );
  }
}
