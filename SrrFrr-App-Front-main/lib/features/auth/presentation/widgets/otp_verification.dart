// OTP Verification Widget - Updated to use OtpInputWidget
//
// This widget provides registration-specific OTP verification UI:
// - Full-page layout with header
// - Embedded reusable OtpInputWidget for the actual OTP input
// - Verify button

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';

class OtpVerificationWidgets {
  // Builds the complete OTP verification content for registration
  static Widget buildOtpVerificationContent({
    required BuildContext context,
    required String phoneNumber,
    required List<TextEditingController> otpControllers,
    required List<FocusNode> otpFocusNodes,
    required bool hasOtpError,
    required String? otpErrorMessage,
    required int remainingSeconds,
    required bool isLoading,
    required Animation<double> shakeAnimation,
    required AnimationController shakeController,
    required Function(String, int) onOtpInputChange,
    required VoidCallback onVerifyOtp,
    required VoidCallback onResendOtp,
  }) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          left: padding,
          right: padding,
          top: padding,
          bottom: MediaQuery.of(context).viewInsets.bottom + padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOtpHeaderSection(context, phoneNumber, padding, l10n),
            SizedBox(height: padding * 1.5),

            // Use the reusable OtpInputWidget
            OtpInputWidget(
              controllers: otpControllers,
              focusNodes: otpFocusNodes,
              hasError: hasOtpError,
              errorMessage: otpErrorMessage,
              remainingSeconds: remainingSeconds,
              shakeAnimation: shakeAnimation,
              shakeController: shakeController,
              onInputChange: onOtpInputChange,
              onResend: onResendOtp,
              onClear: () {
                for (var controller in otpControllers) {
                  controller.clear();
                }
                otpFocusNodes[0].requestFocus();
              },
            ),

            SizedBox(height: padding * 1.5),
            _buildModernVerifyButton(
              context: context,
              otpControllers: otpControllers,
              isLoading: isLoading,
              onVerifyOtp: onVerifyOtp,
              padding: padding,
              l10n: l10n,
            ),
            SizedBox(height: padding),
          ],
        ),
      ),
    );
  }

  static Widget _buildOtpHeaderSection(
    BuildContext context,
    String phoneNumber,
    double padding,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.verifyYourNumber,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: padding * 0.8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            children: [
              TextSpan(
                text: l10n.enterCodeSentTo(phoneNumber).split(phoneNumber)[0],
              ),
              TextSpan(
                text: phoneNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildModernVerifyButton({
    required BuildContext context,
    required List<TextEditingController> otpControllers,
    required bool isLoading,
    required VoidCallback onVerifyOtp,
    required double padding,
    required AppLocalizations l10n,
  }) {
    final isOtpComplete = otpControllers.every((c) => c.text.isNotEmpty);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isOtpComplete && !isLoading
            ? () {
                HapticFeedback.lightImpact();
                onVerifyOtp();
              }
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: isOtpComplete && !isLoading
              ? AppColors.primary
              : Colors.grey.shade300,
          foregroundColor: isOtpComplete && !isLoading
              ? Colors.white
              : Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          elevation: isOtpComplete && !isLoading ? 2 : 0,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, size: 20),
                  SizedBox(width: padding / 2),
                  Text(l10n.verifyCode),
                ],
              ),
      ),
    );
  }
}