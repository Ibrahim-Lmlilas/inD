import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/input_validators.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

import 'package:srrfrr_app_front/features/auth/presentation/widgets/kyc_input.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/otp_verification.dart';
import 'package:srrfrr_app_front/features/auth/presentation/widgets/common.dart';

class RegistrationPage extends StatefulWidget {
  final String userType;

  const RegistrationPage({super.key, required this.userType});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String? _selectedGender;
  InterfaceType? _selectedInterface;
  String? _profilePhotoPath;
  bool _showFirstNameError = false;
  bool _showLastNameError = false;
  bool _showPhoneError = false;
  bool _showGenderError = false;
  bool _showPasswordError = false;
  bool _showConfirmPasswordError = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;

  int _remainingSeconds = 43;
  bool _hasOtpError = false;
  String? _otpErrorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _setupFocusListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
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

  void _disposeControllers() {
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _emailFocusNode.dispose();

    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
  }

  bool _validateName(String name) {
    return name.trim().length >= 2;
  }

  bool _validatePhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 8 && cleanPhone.length <= 10;
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _canProceedFromKyc() {
    return _validateName(_firstNameController.text) &&
        _validateName(_lastNameController.text) &&
        _selectedGender != null &&
        _validatePhoneNumber(_phoneController.text) &&
        InputValidators.validatePassword(_passwordController.text) &&
        _passwordController.text == _confirmPasswordController.text &&
        _validateEmail(_emailController.text) &&
        _termsAccepted &&
        (_selectedGender != 'female' || _selectedInterface != null);
  }

  bool _isOtpComplete() {
    return _otpControllers.every((c) => c.text.isNotEmpty);
  }

  Future<void> _proceedFromKyc() async {
    bool hasErrors = false;
    final l10n = context.l10n;

    if (!_validateName(_firstNameController.text)) {
      setState(() => _showFirstNameError = true);
      hasErrors = true;
    }
    if (!_validateName(_lastNameController.text)) {
      setState(() => _showLastNameError = true);
      hasErrors = true;
    }
    if (_selectedGender == null) {
      setState(() => _showGenderError = true);
      hasErrors = true;
    }
    if (!_validatePhoneNumber(_phoneController.text)) {
      setState(() => _showPhoneError = true);
      hasErrors = true;
    }
    if (!InputValidators.validatePassword(_passwordController.text)) {
      setState(() => _showPasswordError = true);
      hasErrors = true;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _showConfirmPasswordError = true);
      hasErrors = true;
    }
    if (!_termsAccepted) {
      SnackBarService(context).showError(l10n.pleaseAcceptTerms);
      hasErrors = true;
    }
    if (_selectedGender == 'female' && _selectedInterface == null) {
      SnackBarService(context).showError(l10n.pleaseChooseInterface);
      hasErrors = true;
    }

    if (hasErrors) {
      SnackBarService(context).showError(l10n.pleaseFillAllFields);
      return;
    }

    final provider = context.read<AuthProvider>();
    final gender = _selectedGender == 'male' ? Gender.male : Gender.female;

    provider.setKycInformation(
      phoneNumber: '+212${_phoneController.text.trim()}',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: gender,
      password: _passwordController.text,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      termsAccepted: _termsAccepted,
    );

    if (_selectedInterface != null) {
      provider.setUserInterfaceType(_selectedInterface!);
    }

    final success = await provider.proceedFromKyc();

    if (mounted) {
      _resetOtpState();

      if (success) {
        _startOtpTimer();
        SnackBarService(context).showSuccess(l10n.otpSentViaWhatsApp);
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            final warningMessage = _getUserOtpWarning(
              l10n,
              provider.errorMessage,
            );
            SnackBarService(context).showWarning(warningMessage);
          }
        });
        _startOtpTimer();
      }
    }
  }

  String _getUserOtpWarning(AppLocalizations l10n, String? errorMessage) {
    if (errorMessage == null) return l10n.errorOccurred;

    final lowerError = errorMessage.toLowerCase();

    if (lowerError.contains('maximum resend') ||
        lowerError.contains('use the last otp')) {
      return l10n.useLastOtpSent;
    }

    if (lowerError.contains('blocked') ||
        lowerError.contains('temporarily') ||
        lowerError.contains('must wait') ||
        lowerError.contains('wait')) {
      final match = RegExp(r'(\d+)\s*seconds?').firstMatch(lowerError);
      if (match != null) {
        final seconds = match.group(1);
        return l10n.waitBeforeResending(int.parse(seconds!));
      }
      return l10n.pleaseWaitBeforeResending;
    }

    if (lowerError.contains('maximum') && lowerError.contains('attempts')) {
      return l10n.tooManyAttempts;
    }

    if (lowerError.contains('invalid phone') ||
        lowerError.contains('phone number format')) {
      return l10n.invalidPhoneNumber;
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return l10n.networkError;
    }

    if (lowerError.contains('whatsapp') ||
        lowerError.contains('failed to send')) {
      return l10n.failedToSendOtp;
    }

    return l10n.otpSendIssue;
  }

  void _resetOtpState() {
    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
      _remainingSeconds = 43;
    });

    for (var controller in _otpControllers) {
      controller.clear();
    }

    _shakeController.reset();
  }

  List<String> _getMissingFields() {
    final missing = <String>[];
    final l10n = context.l10n;

    if (!_validateName(_firstNameController.text)) {
      missing.add(l10n.firstName);
    }
    if (!_validateName(_lastNameController.text)) {
      missing.add(l10n.lastName);
    }
    if (_selectedGender == null) {
      missing.add(l10n.gender);
    }
    if (!_validatePhoneNumber(_phoneController.text)) {
      missing.add(l10n.phoneNumber);
    }
    if (!InputValidators.validatePassword(_passwordController.text)) {
      missing.add(l10n.password);
    }
    if (_passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      missing.add(l10n.confirmPassword);
    }
    if (!_termsAccepted) {
      missing.add(l10n.termsOfUse);
    }
    if (_selectedGender == 'female' && _selectedInterface == null) {
      missing.add(l10n.chooseYourInterface);
    }

    return missing;
  }

  String _getMissingFieldsMessage() {
    final l10n = context.l10n;
    final missing = _getMissingFields();

    if (missing.isEmpty) return '';

    if (missing.length == 1) {
      return '${l10n.pleaseFillAllFields}: ${missing[0]}';
    }

    if (missing.length == 2) {
      return '${l10n.pleaseFillAllFields}: ${missing[0]} & ${missing[1]}';
    }

    final lastField = missing.last;
    final otherFields = missing.sublist(0, missing.length - 1).join(', ');
    return '${l10n.pleaseFillAllFields}: $otherFields & $lastField';
  }

  void _startOtpTimer() {
    setState(() => _remainingSeconds = 43);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _remainingSeconds > 0) {
        final provider = context.read<AuthProvider>();
        if (provider.currentRegistrationStep ==
            RegistrationStep.otpVerification) {
          setState(() => _remainingSeconds--);
          return true;
        }
      }
      return false;
    });
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

  Future<void> _verifyOTP() async {
    final l10n = context.l10n;

    if (!_isOtpComplete()) return;

    setState(() => _clearOtpError());
    HapticFeedback.mediumImpact();

    final code = _otpControllers.map((c) => c.text).join();
    final provider = context.read<AuthProvider>();
    final success = await provider.verifyOtpAndRegister(code);

    if (!success && mounted) {
      _showOtpError(provider.errorMessage ?? l10n.incorrectCode);
    } else if (success && mounted) {
      HapticFeedback.heavyImpact();
      context.go('/registration-success');
    }
  }

  void _showOtpError(String message) {
    setState(() {
      _hasOtpError = true;
      _otpErrorMessage = message;
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
    HapticFeedback.heavyImpact();
  }

  void _clearOtpError() {
    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
    });
  }

  Future<void> _resendOTP() async {
    final l10n = context.l10n;
    final provider = context.read<AuthProvider>();
    final success = await provider.resendOtp();

    if (success && mounted) {
      setState(() {
        _remainingSeconds = 43;
        _clearOtpError();
      });
      _startOtpTimer();
      SnackBarService(context).showSuccess(l10n.aNewCodeHasBeenSent);
    }
  }

  void _moveToPreviousStep() {
    final provider = context.read<AuthProvider>();

    if (provider.currentRegistrationStep == RegistrationStep.kycInput) {
      context.pop();
    } else {
      provider.goToPreviousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return _buildRegistrationScreen(provider);
      },
    );
  }

  Widget _buildRegistrationScreen(AuthProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RegistrationCommonWidgets.buildAppBar(
        context: context,
        onBackPressed: _moveToPreviousStep,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet
                    ? (screenWidth - 400) / 2
                    : AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              child: RegistrationCommonWidgets.buildProgressIndicator(
                context: context,
                currentStep: provider.currentStepNumber,
                totalSteps: provider.totalRegistrationSteps,
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? (screenWidth - 400) / 2
                          : AppSizes.paddingL,
                      vertical:
                          provider.currentRegistrationStep ==
                              RegistrationStep.otpVerification
                          ? AppSizes.paddingM
                          : AppSizes.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.currentRegistrationStep ==
                            RegistrationStep.otpVerification)
                          const SizedBox(height: 80),
                        Expanded(child: _buildCurrentStepContent(provider)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(AuthProvider provider) {
    switch (provider.currentRegistrationStep) {
      case RegistrationStep.kycInput:
        return KycInputWidgets.buildKycInputContent(
          context: context,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          phoneController: _phoneController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          emailController: _emailController,
          firstNameFocusNode: _firstNameFocusNode,
          lastNameFocusNode: _lastNameFocusNode,
          phoneFocusNode: _phoneFocusNode,
          passwordFocusNode: _passwordFocusNode,
          confirmPasswordFocusNode: _confirmPasswordFocusNode,
          emailFocusNode: _emailFocusNode,
          selectedGender: _selectedGender,
          selectedInterface: _selectedInterface,
          profilePhotoPath: _profilePhotoPath,
          showFirstNameError: _showFirstNameError,
          showLastNameError: _showLastNameError,
          showPhoneError: _showPhoneError,
          showGenderError: _showGenderError,
          showPasswordError: _showPasswordError,
          showConfirmPasswordError: _showConfirmPasswordError,
          isPasswordVisible: _isPasswordVisible,
          isConfirmPasswordVisible: _isConfirmPasswordVisible,
          termsAccepted: _termsAccepted,
          isLoading: provider.isLoading,
          canProceed: _canProceedFromKyc(),
          missingFieldsMessage: _getMissingFieldsMessage(),
          onFirstNameChanged: (v) =>
              setState(() => _showFirstNameError = false),
          onLastNameChanged: (v) => setState(() => _showLastNameError = false),
          onPhoneChanged: (v) => setState(() => _showPhoneError = false),
          onGenderChanged: (v) => setState(() {
            _selectedGender = v;
            _showGenderError = false;
            if (v != 'female') {
              _selectedInterface = null;
            }
          }),
          onInterfaceChanged: (v) => setState(() => _selectedInterface = v),
          onPasswordChanged: (v) => setState(() => _showPasswordError = false),
          onConfirmPasswordChanged: (v) =>
              setState(() => _showConfirmPasswordError = false),
          onEmailChanged: (v) => setState(() {}),
          onTogglePasswordVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          onToggleConfirmPasswordVisibility: () => setState(
            () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
          ),
          onTermsChanged: (v) => setState(() => _termsAccepted = v),
          onPhotoSelected: (path) => setState(() => _profilePhotoPath = path),
          onProceedToNext: _proceedFromKyc,
        );

      case RegistrationStep.otpVerification:
        return OtpVerificationWidgets.buildOtpVerificationContent(
          context: context,
          phoneNumber: provider.tempPhoneNumber ?? '',
          otpControllers: _otpControllers,
          otpFocusNodes: _otpFocusNodes,
          hasOtpError: _hasOtpError,
          otpErrorMessage: _otpErrorMessage,
          remainingSeconds: _remainingSeconds,
          isLoading: provider.isLoading,
          shakeAnimation: _shakeAnimation,
          shakeController: _shakeController,
          onOtpInputChange: _handleOTPInputChange,
          onVerifyOtp: _verifyOTP,
          onResendOtp: _resendOTP,
        );

      case RegistrationStep.registrationSuccess:
      case RegistrationStep.completed:
        return const SizedBox.shrink();
    }
  }
}
