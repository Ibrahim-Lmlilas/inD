// Password Reset Page - Using OtpInputWidget
//
// Two-step password reset flow:
// 1. User enters phone number → OTP sent via WhatsApp
// 2. User enters 6-digit OTP + new password + confirm password → Password reset
// 3. Success screen with login redirect

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/input_validators.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/shared/widgets/common_widgets.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/password_requirements.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';

enum PasswordResetStep { phoneInput, otpAndPassword, success }

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage>
    with TickerProviderStateMixin {
  // Controllers
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final _phoneFocusNode = FocusNode();
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Animation Controllers
  late AnimationController _successAnimationController;
  late AnimationController _shakeController;

  // Animations
  late Animation<double> _successScaleAnimation;
  late Animation<double> _shakeAnimation;

  // State
  PasswordResetStep _currentStep = PasswordResetStep.phoneInput;
  bool _showPhoneError = false;
  bool _showPasswordError = false;
  bool _showConfirmPasswordError = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasOtpError = false;
  String? _otpErrorMessage;
  int _remainingSeconds = 0;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _successAnimationController.dispose();
    _shakeController.dispose();

    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _initializeAnimations() {
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (_otpFocusNodes[i].hasFocus && _hasOtpError) {
          _clearOtpError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentStep != PasswordResetStep.success
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () {
                  if (_currentStep == PasswordResetStep.phoneInput) {
                    context.pop();
                  } else if (_currentStep == PasswordResetStep.otpAndPassword) {
                    _goToPreviousStep();
                  }
                },
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: _buildCurrentStep(l10n),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case PasswordResetStep.phoneInput:
        return _buildPhoneInputStep(l10n);
      case PasswordResetStep.otpAndPassword:
        return _buildOtpAndPasswordStep(l10n);
      case PasswordResetStep.success:
        return _buildSuccessStep(l10n);
    }
  }

  Widget _buildPhoneInputStep(AppLocalizations l10n) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.paddingXL),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              l10n.resetPassword,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              l10n.enterPhoneToReceiveOtp,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL * 2),
            CommonWidgets.buildPhoneField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              onChanged: (value) => setState(() => _showPhoneError = false),
              showError: _showPhoneError,
              isValid: InputValidators.validatePhoneNumber(
                _phoneController.text,
              ),
              onClear: () {
                _phoneController.clear();
                setState(() => _showPhoneError = false);
              },
            ),
            const SizedBox(height: AppSizes.paddingXL),
            CommonWidgets.buildPrimaryButton(
              text: l10n.sendCode,
              onPressed: authProvider.isLoading ? null : _sendOtp,
              isLoading: authProvider.isLoading,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSizes.paddingS),
                    Text(
                      l10n.backToLogin,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final phoneError = InputValidators.getPhoneError(phone);
    if (phoneError != null) {
      setState(() => _showPhoneError = true);
      SnackBarService(context).showError(phoneError);
      return;
    }

    _phoneNumber = '+212$phone';
    final result = await context.read<AuthProvider>().sendPasswordResetOtp(
      phone,
    );

    if (result != null && result.success && mounted) {
      logSuccess('[PasswordReset]', 'OTP sent successfully');
      _startOtpTimer();
      setState(() => _currentStep = PasswordResetStep.otpAndPassword);
      SnackBarService(context).showSuccess(context.l10n.otpSentViaWhatsApp);
    } else if (mounted) {
      final authProvider = context.read<AuthProvider>();
      final errorMessage =
          authProvider.errorMessage ?? context.l10n.errorOccurred;
      SnackBarService(context).showError(errorMessage);
      logError('[PasswordReset]', 'Failed to send OTP: $errorMessage');
    }
  }

  Widget _buildOtpAndPasswordStep(AppLocalizations l10n) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.paddingXL),
            Text(
              l10n.resetPassword,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              l10n.enterCodeAndNewPassword(_phoneNumber!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL * 2),
            Text(
              l10n.verificationCode,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Use the reusable OtpInputWidget
            OtpInputWidget(
              controllers: _otpControllers,
              focusNodes: _otpFocusNodes,
              hasError: _hasOtpError,
              errorMessage: _otpErrorMessage,
              remainingSeconds: _remainingSeconds,
              shakeAnimation: _shakeAnimation,
              shakeController: _shakeController,
              onInputChange: _handleOTPInputChange,
              onResend: _resendOtp,
              onClear: () {
                for (var controller in _otpControllers) {
                  controller.clear();
                }
                _otpFocusNodes[0].requestFocus();
              },
            ),

            const SizedBox(height: AppSizes.paddingXL),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.grey300)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: Text(
                    l10n.newPassword,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.grey300)),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXL),
            CommonWidgets.buildPasswordField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              onChanged: (value) => setState(() => _showPasswordError = false),
              isPasswordVisible: _isPasswordVisible,
              onToggleVisibility: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              showError: _showPasswordError,
              isValid: InputValidators.validatePassword(
                _passwordController.text,
              ),
              hintText: l10n.newPassword,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CommonWidgets.buildPasswordField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              onChanged: (value) =>
                  setState(() => _showConfirmPasswordError = false),
              isPasswordVisible: _isConfirmPasswordVisible,
              onToggleVisibility: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
              showError: _showConfirmPasswordError,
              isValid: InputValidators.validatePasswordConfirmation(
                _passwordController.text,
                _confirmPasswordController.text,
              ),
              hintText: l10n.confirmPassword,
            ),
            const SizedBox(height: AppSizes.paddingL),
            if (_passwordController.text.isNotEmpty)
              PasswordRequirementsWidget(password: _passwordController.text),
            const SizedBox(height: AppSizes.paddingXL),
            Container(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _canSubmitReset() && !authProvider.isLoading
                    ? () {
                        HapticFeedback.lightImpact();
                        _resetPassword();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _canSubmitReset() && !authProvider.isLoading
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  foregroundColor: _canSubmitReset() && !authProvider.isLoading
                      ? Colors.white
                      : Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  elevation: _canSubmitReset() && !authProvider.isLoading
                      ? 2
                      : 0,
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, size: 20),
                          const SizedBox(width: AppSizes.paddingS),
                          Text(l10n.resetPassword),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleOTPInputChange(String value, int index) {
    if (value.isNotEmpty) {
      HapticFeedback.lightImpact();
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clearOtpError() {
    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
    });
  }

  void _showOtpError(String message) {
    setState(() {
      _hasOtpError = true;
      _otpErrorMessage = message;
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
    HapticFeedback.heavyImpact();
  }
  
  bool _isOtpComplete() => _otpControllers.every((c) => c.text.isNotEmpty);

  bool _canSubmitReset() {
    return _isOtpComplete() &&
        InputValidators.validatePassword(_passwordController.text) &&
        InputValidators.validatePasswordConfirmation(
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }

  void _startOtpTimer() {
    setState(() => _remainingSeconds = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        return true;
      }
      return false;
    });
  }

  Future<void> _resendOtp() async {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
    });
    await _sendOtp();
  }

  Future<void> _resetPassword() async {
    final l10n = context.l10n;
    if (!_canSubmitReset()) return;

    final otp = _otpControllers.map((c) => c.text).join();
    final newPassword = _passwordController.text;

    final passwordError = InputValidators.getPasswordError(newPassword);
    if (passwordError != null) {
      SnackBarService(context).showError(passwordError);
      setState(() => _showPasswordError = true);
      return;
    }

    final confirmError = InputValidators.getPasswordConfirmationError(
      newPassword,
      _confirmPasswordController.text,
    );
    if (confirmError != null) {
      SnackBarService(context).showError(confirmError);
      setState(() => _showConfirmPasswordError = true);
      return;
    }

    if (_phoneNumber == null) {
      SnackBarService(context).showError(l10n.errorOccurred);
      return;
    }

    logInfo('[PasswordReset]', 'Attempting password reset');
    final success = await context.read<AuthProvider>().resetPassword(
      phoneNumber: _phoneNumber!,
      otp: otp,
      newPassword: newPassword,
    );

    if (success && mounted) {
      logSuccess('[PasswordReset]', 'Password reset successful');
      setState(() => _currentStep = PasswordResetStep.success);
      _successAnimationController.forward();
      SnackBarService(context).showSuccess(l10n.passwordChangedSuccessfully);
    } else if (mounted) {
      final authProvider = context.read<AuthProvider>();
      final errorMessage = authProvider.errorMessage ?? l10n.incorrectCode;
      _showOtpError(errorMessage);
      SnackBarService(context).showError(errorMessage);
      logError('[PasswordReset]', 'Reset failed: $errorMessage');
    }
  }

  Widget _buildSuccessStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.paddingXL * 3),
        ScaleTransition(
          scale: _successScaleAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL * 2),
        Text(
          l10n.passwordReset,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          l10n.passwordResetSuccess,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingXL),
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.success, size: 24),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Text(
                  l10n.dontForgetNewPassword,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL * 2),
        CommonWidgets.buildPrimaryButton(
          text: l10n.login,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
      ],
    );
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = PasswordResetStep.phoneInput;
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _passwordController.clear();
      _confirmPasswordController.clear();
      _hasOtpError = false;
      _otpErrorMessage = null;
      _showPasswordError = false;
      _showConfirmPasswordError = false;
    });
  }
}
