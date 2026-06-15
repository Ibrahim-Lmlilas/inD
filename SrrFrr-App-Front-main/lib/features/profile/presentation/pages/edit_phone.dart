// Edit Phone Page
//
// Two-step phone number update:
// 1. Enter new phone number and current password
// 2. Verify OTP sent to new number using reusable OtpInputWidget

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:srrfrr_app_front/features/profile/data/services/profile_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class EditPhonePage extends StatefulWidget {
  final String source;

  const EditPhonePage({super.key, this.source = 'passenger'});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showOtpStep = false;
  String? _pendingPhoneNumber;

  // OTP state
  bool _hasOtpError = false;
  String? _otpErrorMessage;
  int _remainingSeconds = 0;

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
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
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

  String? _validatePhone(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.phoneNumberRequired;
    }
    // Moroccan phone format: 0XXXXXXXXX (10 digits)
    if (!RegExp(r'^0[5-7]\d{8}$').hasMatch(value)) {
      return l10n.invalidPhoneFormat;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    return null;
  }

  bool _isOtpComplete() {
    return _otpControllers.every((c) => c.text.isNotEmpty);
  }

  void _startOtpTimer() {
    setState(() => _remainingSeconds = 120); // 2 minutes
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _remainingSeconds > 0) {
        if (_showOtpStep) {
          setState(() => _remainingSeconds--);
          return true;
        }
      }
      return false;
    });
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

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ProfileService>();
      final response = await apiService.updatePhoneRequest(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _showOtpStep = true;
          _pendingPhoneNumber = _phoneController.text;
        });
        _startOtpTimer();
        SnackBarService(context).showSuccess(l10n.otpSent);
      } else {
        final message =
            response['message'] ==
                'New phone number is the same as current phone number'
            ? l10n.phoneNumberSameAsCurrent
            : (response['message'] ?? l10n.errorRequestingOtp);
        SnackBarService(context).showError(message);
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarService(context).showError(l10n.errorOccurred);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_isOtpComplete()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final otp = _otpControllers.map((c) => c.text).join();

    try {
      final apiService = context.read<ProfileService>();
      final response = await apiService.confirmUpdatePhone(
        phoneNumber: _pendingPhoneNumber!,
        otp: otp,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        SnackBarService(context).showSuccess(l10n.phoneNumberChanged);
        context.pop();
      } else {
        final errorMessage = response['message'] ?? l10n.invalidOtpCode;
        _showOtpError(errorMessage);
        SnackBarService(context).showError(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = l10n.errorOccurred;
      _showOtpError(errorMessage);
      SnackBarService(context).showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _clearOtpError();

    await _handleRequestOtp();
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
          l10n.editPhone,
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
            if (!_showOtpStep) ...[_buildPhoneStep()] else ...[_buildOtpStep()],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.enterNewPhoneAndPassword,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          decoration: InputDecoration(
            labelText: l10n.newPhoneNumber,
            hintText: '0612345678',
            prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 16),

        // Current Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          decoration: InputDecoration(
            labelText: l10n.currentPassword,
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info Box
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.verificationCodeWillBeSent,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Continue Button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRequestOtp,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.continueButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.enterCodeSentToPhone(_pendingPhoneNumber!),
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        // Use reusable OtpInputWidget
        OtpInputWidget(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
          hasError: _hasOtpError,
          errorMessage: _otpErrorMessage,
          remainingSeconds: _remainingSeconds,
          shakeAnimation: _shakeAnimation,
          shakeController: _shakeController,
          onInputChange: _handleOTPInputChange,
          onResend: _handleResendOtp,
          onClear: () {
            for (var controller in _otpControllers) {
              controller.clear();
            }
            _otpFocusNodes[0].requestFocus();
          },
        ),

        const SizedBox(height: 32),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isOtpComplete() && !_isLoading
                ? () {
                    HapticFeedback.lightImpact();
                    _handleVerifyOtp();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isOtpComplete() && !_isLoading
                  ? AppColors.primary
                  : Colors.grey.shade300,
              foregroundColor: _isOtpComplete() && !_isLoading
                  ? Colors.white
                  : Colors.grey.shade500,
              elevation: _isOtpComplete() && !_isLoading ? 2 : 0,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, size: 20),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        l10n.verify,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}