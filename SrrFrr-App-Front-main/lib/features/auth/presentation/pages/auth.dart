// Authentication Page
//
// Main entry point for user authentication in the SRR FRR app.
// Provides phone number and password login functionality.
//
// Features:
// - Phone number input with Moroccan country code (+212)
// - Password input with visibility toggle
// - Form validation with error states
// - Responsive layout for all screen sizes
// - Smooth animations for page entrance

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/extensions/localization_extension.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/input_validators.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/shared/widgets/car_logo.dart';
import 'package:srrfrr_app_front/shared/widgets/common_widgets.dart';
import 'package:srrfrr_app_front/shared/widgets/app_logo_2.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPhoneValid = false;
  bool _isPasswordValid = false;
  bool _showPhoneError = false;
  bool _showPasswordError = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneValid = InputValidators.validatePhoneNumber(value);
      if (_showPhoneError) _showPhoneError = false;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _isPasswordValid = InputValidators.validatePassword(value);
      if (_showPasswordError) _showPasswordError = false;
    });
  }

  Future<void> _handleLogin() async {
    final phoneText = _phoneController.text.trim();
    final passwordText = _passwordController.text;

    bool hasError = false;

    if (phoneText.isEmpty || !InputValidators.validatePhoneNumber(phoneText)) {
      setState(() => _showPhoneError = true);
      hasError = true;
    }

    if (passwordText.isEmpty ||
        !InputValidators.validatePassword(passwordText)) {
      setState(() => _showPasswordError = true);
      hasError = true;
    }

    if (hasError) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.login(phoneText, passwordText);

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        setState(() => _isLoading = false);
        SnackBarService(context).showError(context.l10n.loginFailedMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarService(context).showError(context.l10n.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600
                        ? (screenWidth - 400) / 2
                        : AppSizes.paddingL,
                    vertical: AppSizes.paddingM,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeaderSection(isSmallScreen),
                      _buildIllustrationSection(isSmallScreen),
                      _buildWelcomeSection(l10n),
                      _buildActionSection(l10n),
                      _buildLanguageSelector(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildLanguageSelector() {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLanguage = languageProvider.currentLanguage ?? Language.french;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.paddingM,
        bottom: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLanguageButton(
            Language.french,
            currentLanguage,
            languageProvider,
          ),
          const SizedBox(width: AppSizes.paddingL),
          _buildLanguageButton(
            Language.english,
            currentLanguage,
            languageProvider,
          ),
          const SizedBox(width: AppSizes.paddingL),
          _buildLanguageButton(
            Language.arabic,
            currentLanguage,
            languageProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    Language language,
    Language currentLanguage,
    LanguageProvider provider,
  ) {
    final isSelected = language == currentLanguage;

    return GestureDetector(
      onTap: () => provider.changeLanguage(language),
      child: Text(
        language.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          decoration: isSelected
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(
        top: isSmallScreen ? AppSizes.paddingM : AppSizes.paddingXL,
        bottom: AppSizes.paddingM,
      ),
      child: const AppLogo2(width: 140, height: 70),
    );
  }

  Widget _buildIllustrationSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? AppSizes.paddingL : AppSizes.paddingXL,
      ),
      child: Hero(
        tag: 'car_illustration',
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const CarLogo(),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
      child: Column(
        children: [
          Text(
            l10n.welcomeToSrrfrr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            l10n.yourRideYourWay,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
      child: Column(
        children: [
          CommonWidgets.buildPhoneField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            onChanged: _onPhoneChanged,
            showError: _showPhoneError,
            isValid: _isPhoneValid,
            onClear: () {
              _phoneController.clear();
              setState(() {
                _isPhoneValid = false;
                _showPhoneError = false;
              });
            },
          ),
          const SizedBox(height: AppSizes.paddingM),
          CommonWidgets.buildPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            onChanged: _onPasswordChanged,
            isPasswordVisible: _isPasswordVisible,
            onToggleVisibility: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
            showError: _showPasswordError,
            isValid: _isPasswordValid,
            onSubmitted: _handleLogin,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/password-reset'),
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary
                  ..withValues(alpha: 0.6),
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.connecting,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      l10n.login,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          CommonWidgets.buildSecondaryButton(
            text: l10n.createAccount,
            onPressed: () => context.push('/registration'),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Text(
              l10n.termsConditionsNotice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
