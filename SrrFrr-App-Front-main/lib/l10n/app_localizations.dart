import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SRR FRR'**
  String get appName;

  /// No description provided for @welcomeToSrrfrr.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SRR FRR'**
  String get welcomeToSrrfrr;

  /// No description provided for @yourRideYourWay.
  ///
  /// In en, this message translates to:
  /// **'Your ride, your way'**
  String get yourRideYourWay;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @termsConditionsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our Terms of Use and Privacy Policy'**
  String get termsConditionsNotice;

  /// No description provided for @loginFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials and try again.'**
  String get loginFailedMessage;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterPhoneToReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a verification code via WhatsApp'**
  String get enterPhoneToReceiveOtp;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @enterCodeAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phoneNumber} and your new password'**
  String enterCodeAndNewPassword(String phoneNumber);

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @oneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get oneUppercaseLetter;

  /// No description provided for @oneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get oneLowercaseLetter;

  /// No description provided for @oneNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get oneNumber;

  /// No description provided for @oneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'One special character (!@#\$%^&*)'**
  String get oneSpecialCharacter;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset!'**
  String get passwordReset;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully.\nYou can now login with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @dontForgetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget your new password'**
  String get dontForgetNewPassword;

  /// No description provided for @otpSentViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Code sent via WhatsApp'**
  String get otpSentViaWhatsApp;

  /// No description provided for @incorrectCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get incorrectCode;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @fillYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Fill in your information to get started'**
  String get fillYourInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterYourFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterYourLastName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectYourGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get selectYourGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get email;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailPlaceholder;

  /// No description provided for @minimumPassword.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get minimumPassword;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype your password'**
  String get retypePassword;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'terms of use'**
  String get termsOfUse;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @touchToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get touchToAddPhoto;

  /// No description provided for @touchToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get touchToChangePhoto;

  /// No description provided for @chooseYourInterface.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Interface'**
  String get chooseYourInterface;

  /// No description provided for @srrfrrRegular.
  ///
  /// In en, this message translates to:
  /// **'SRR FRR'**
  String get srrfrrRegular;

  /// No description provided for @standardInterface.
  ///
  /// In en, this message translates to:
  /// **'Standard interface'**
  String get standardInterface;

  /// No description provided for @srrfrrLadies.
  ///
  /// In en, this message translates to:
  /// **'SRR FRR Ladies'**
  String get srrfrrLadies;

  /// No description provided for @femaleDriversOnly.
  ///
  /// In en, this message translates to:
  /// **'Female drivers only'**
  String get femaleDriversOnly;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms of use'**
  String get pleaseAcceptTerms;

  /// No description provided for @pleaseChooseInterface.
  ///
  /// In en, this message translates to:
  /// **'Please choose your interface'**
  String get pleaseChooseInterface;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get pleaseFillAllFields;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get verifyYourNumber;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phoneNumber}'**
  String enterCodeSentTo(String phoneNumber);

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @codeSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully'**
  String get codeSentSuccessfully;

  /// No description provided for @aNewCodeHasBeenSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent'**
  String get aNewCodeHasBeenSent;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registrationSuccess;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}!'**
  String welcome(String name);

  /// No description provided for @yourAccountIsReady.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready'**
  String get yourAccountIsReady;

  /// No description provided for @startTraveling.
  ///
  /// In en, this message translates to:
  /// **'Start Traveling'**
  String get startTraveling;

  /// No description provided for @verifiedDrivers.
  ///
  /// In en, this message translates to:
  /// **'Verified drivers'**
  String get verifiedDrivers;

  /// No description provided for @secureEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Secure environment'**
  String get secureEnvironment;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// No description provided for @wideChoiceOfRides.
  ///
  /// In en, this message translates to:
  /// **'Wide choice of rides'**
  String get wideChoiceOfRides;

  /// No description provided for @securePayments.
  ///
  /// In en, this message translates to:
  /// **'Secure payments'**
  String get securePayments;

  /// No description provided for @verifiedFemaleDrivers.
  ///
  /// In en, this message translates to:
  /// **'Verified female drivers'**
  String get verifiedFemaleDrivers;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account with a strong password'**
  String get secureYourAccount;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password required'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password required'**
  String get newPasswordRequired;

  /// No description provided for @confirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get confirmationRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get errorChangingPassword;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @registrationProgress.
  ///
  /// In en, this message translates to:
  /// **'Registration progress: step {current} of {total}'**
  String registrationProgress(int current, int total);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearanceAndInterface.
  ///
  /// In en, this message translates to:
  /// **'Appearance and Interface'**
  String get appearanceAndInterface;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @languageChangeInfo.
  ///
  /// In en, this message translates to:
  /// **'The app will update immediately to reflect the new language'**
  String get languageChangeInfo;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @interfaceType.
  ///
  /// In en, this message translates to:
  /// **'Interface Type'**
  String get interfaceType;

  /// No description provided for @regularInterface.
  ///
  /// In en, this message translates to:
  /// **'SrrFrr Regular Interface'**
  String get regularInterface;

  /// No description provided for @ladiesInterface.
  ///
  /// In en, this message translates to:
  /// **'SrrFrr Ladies Interface'**
  String get ladiesInterface;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @receiveAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive all notifications'**
  String get receiveAllNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @notificationSounds.
  ///
  /// In en, this message translates to:
  /// **'Notification sounds'**
  String get notificationSounds;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @notificationVibration.
  ///
  /// In en, this message translates to:
  /// **'Notification vibration'**
  String get notificationVibration;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data and Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @notificationsSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved'**
  String get notificationsSaved;

  /// No description provided for @savingError.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get savingError;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @notificationPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'SrrFrr needs notification permission to send you important updates about your rides, driver status, and messages.'**
  String get notificationPermissionExplanation;

  /// No description provided for @mustEnableInSettings.
  ///
  /// In en, this message translates to:
  /// **'You must enable notifications in system settings'**
  String get mustEnableInSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} - Coming Soon'**
  String featureComingSoon(String feature);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @actionIsIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible'**
  String get actionIsIrreversible;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account will be permanently deleted after a 30-day grace period. All your personal data will be anonymized.'**
  String get accountDeletionWarning;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @whyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Why are you deleting your account?'**
  String get whyDeleteAccount;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @iUnderstandIrreversible.
  ///
  /// In en, this message translates to:
  /// **'I understand that this action is irreversible'**
  String get iUnderstandIrreversible;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed'**
  String get accountDeletionFailed;

  /// No description provided for @errorOccurredPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurredPleaseTryAgain;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @yourAlertsAndMessages.
  ///
  /// In en, this message translates to:
  /// **'Your alerts and messages'**
  String get yourAlertsAndMessages;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @completedRides.
  ///
  /// In en, this message translates to:
  /// **'Completed rides'**
  String get completedRides;

  /// No description provided for @loyaltyProgram.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Program'**
  String get loyaltyProgram;

  /// No description provided for @pointsAndRewards.
  ///
  /// In en, this message translates to:
  /// **'Points and rewards'**
  String get pointsAndRewards;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @supportAndFaq.
  ///
  /// In en, this message translates to:
  /// **'Support and FAQ'**
  String get supportAndFaq;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionAndInformation.
  ///
  /// In en, this message translates to:
  /// **'Version and information'**
  String get versionAndInformation;

  /// No description provided for @driverMode.
  ///
  /// In en, this message translates to:
  /// **'Driver Mode'**
  String get driverMode;

  /// No description provided for @switching.
  ///
  /// In en, this message translates to:
  /// **'Switching...'**
  String get switching;

  /// No description provided for @departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// No description provided for @yourCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get yourCurrentPosition;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// No description provided for @selectDepartureAndDestination.
  ///
  /// In en, this message translates to:
  /// **'Please select departure and destination'**
  String get selectDepartureAndDestination;

  /// No description provided for @sendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Sending request...'**
  String get sendingRequest;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locating;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location error'**
  String get locationError;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @searchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search a place'**
  String get searchPlace;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on map'**
  String get selectOnMap;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search an address'**
  String get searchAddress;

  /// No description provided for @orSelectOnMap.
  ///
  /// In en, this message translates to:
  /// **'or select on the map'**
  String get orSelectOnMap;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @selectPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Select pickup location'**
  String get selectPickupLocation;

  /// No description provided for @selectDestinationLocation.
  ///
  /// In en, this message translates to:
  /// **'Select destination location'**
  String get selectDestinationLocation;

  /// No description provided for @tapMapOrMoveMarker.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or move the marker'**
  String get tapMapOrMoveMarker;

  /// No description provided for @zoomForPrecision.
  ///
  /// In en, this message translates to:
  /// **'Zoom for more precision'**
  String get zoomForPrecision;

  /// No description provided for @retrievingAddress.
  ///
  /// In en, this message translates to:
  /// **'Retrieving address...'**
  String get retrievingAddress;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @rideDetails.
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// No description provided for @rideType.
  ///
  /// In en, this message translates to:
  /// **'Ride Type'**
  String get rideType;

  /// No description provided for @autoDetected.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected'**
  String get autoDetected;

  /// No description provided for @cityToCity.
  ///
  /// In en, this message translates to:
  /// **'City to City'**
  String get cityToCity;

  /// No description provided for @inCity.
  ///
  /// In en, this message translates to:
  /// **'In City'**
  String get inCity;

  /// No description provided for @intercityTripDetected.
  ///
  /// In en, this message translates to:
  /// **'Intercity trip detected: {pickupCity} → {destinationCity}'**
  String intercityTripDetected(String pickupCity, String destinationCity);

  /// No description provided for @numberOfSeats.
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get numberOfSeats;

  /// No description provided for @seatsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} passenger{plural} selected'**
  String seatsSelected(int count, String plural);

  /// No description provided for @proposePrice.
  ///
  /// In en, this message translates to:
  /// **'Propose a price'**
  String get proposePrice;

  /// No description provided for @minimumPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum price: {price} DH'**
  String minimumPrice(int price);

  /// No description provided for @confirmRide.
  ///
  /// In en, this message translates to:
  /// **'Confirm Ride'**
  String get confirmRide;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash payment to driver'**
  String get cashPayment;

  /// No description provided for @freeRide.
  ///
  /// In en, this message translates to:
  /// **'Free Ride'**
  String get freeRide;

  /// No description provided for @freeRideWithPoints.
  ///
  /// In en, this message translates to:
  /// **'Free ride with your points'**
  String get freeRideWithPoints;

  /// No description provided for @insufficientPoints.
  ///
  /// In en, this message translates to:
  /// **'Insufficient: {required}pts required, you have {available}pts'**
  String insufficientPoints(int required, int available);

  /// No description provided for @youHavePoints.
  ///
  /// In en, this message translates to:
  /// **'You have {points}pts (1pt = 1DH)'**
  String youHavePoints(int points);

  /// No description provided for @freeRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Free ride'**
  String get freeRideTitle;

  /// No description provided for @availablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available points'**
  String get availablePoints;

  /// No description provided for @afterThisRide.
  ///
  /// In en, this message translates to:
  /// **'After this ride'**
  String get afterThisRide;

  /// No description provided for @pointsWillBeDeducted.
  ///
  /// In en, this message translates to:
  /// **'{points} points will be deducted (1pt = 1DH)'**
  String pointsWillBeDeducted(int points);

  /// No description provided for @driverOffers.
  ///
  /// In en, this message translates to:
  /// **'Driver Offers'**
  String get driverOffers;

  /// No description provided for @driversAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} driver{plural} available'**
  String driversAvailable(int count, String plural);

  /// No description provided for @adjustYourOffer.
  ///
  /// In en, this message translates to:
  /// **'Adjust your offer'**
  String get adjustYourOffer;

  /// No description provided for @applyPrice.
  ///
  /// In en, this message translates to:
  /// **'Apply Price'**
  String get applyPrice;

  /// No description provided for @waitingForDriverOffers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver offers...'**
  String get waitingForDriverOffers;

  /// No description provided for @canAdjustPriceIn.
  ///
  /// In en, this message translates to:
  /// **'You can adjust the price in {seconds}s if no offers'**
  String canAdjustPriceIn(int seconds);

  /// No description provided for @canAdjustPriceNow.
  ///
  /// In en, this message translates to:
  /// **'You can now adjust your price'**
  String get canAdjustPriceNow;

  /// No description provided for @searchingDrivers.
  ///
  /// In en, this message translates to:
  /// **'Searching for drivers'**
  String get searchingDrivers;

  /// No description provided for @nearbyDriversWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Nearby drivers will appear here'**
  String get nearbyDriversWillAppear;

  /// No description provided for @offersExpireAfter60s.
  ///
  /// In en, this message translates to:
  /// **'Offers expire after 60 seconds'**
  String get offersExpireAfter60s;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'rides'**
  String get rides;

  /// No description provided for @counterOffer.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer'**
  String get counterOffer;

  /// No description provided for @initialPrice.
  ///
  /// In en, this message translates to:
  /// **'Initial price'**
  String get initialPrice;

  /// No description provided for @driverCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Driver counter-offer'**
  String get driverCounterOffer;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @confirmingRide.
  ///
  /// In en, this message translates to:
  /// **'Confirming ride...'**
  String get confirmingRide;

  /// No description provided for @rideConfirmationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Ride confirmation timeout. Please try again.'**
  String get rideConfirmationTimeout;

  /// No description provided for @errorAcceptingDriver.
  ///
  /// In en, this message translates to:
  /// **'Error accepting driver'**
  String get errorAcceptingDriver;

  /// No description provided for @driverDeclined.
  ///
  /// In en, this message translates to:
  /// **'Driver declined'**
  String get driverDeclined;

  /// No description provided for @offerExpired.
  ///
  /// In en, this message translates to:
  /// **'Offer expired'**
  String get offerExpired;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride request has been cancelled.'**
  String get requestCancelled;

  /// No description provided for @errorCancellingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling request'**
  String get errorCancellingRequest;

  /// No description provided for @newOfferSent.
  ///
  /// In en, this message translates to:
  /// **'New offer sent: {price} DH'**
  String newOfferSent(int price);

  /// No description provided for @errorSendingOffer.
  ///
  /// In en, this message translates to:
  /// **'Error sending offer'**
  String get errorSendingOffer;

  /// No description provided for @noOffersAdjustPrice.
  ///
  /// In en, this message translates to:
  /// **'No offers yet. Try adjusting your price!'**
  String get noOffersAdjustPrice;

  /// No description provided for @useLastOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Please use the OTP code that was sent earlier'**
  String get useLastOtpSent;

  /// No description provided for @waitBeforeResending.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} seconds before requesting a new code'**
  String waitBeforeResending(int seconds);

  /// No description provided for @pleaseWaitBeforeResending.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting a new code'**
  String get pleaseWaitBeforeResending;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get tooManyAttempts;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get invalidPhoneNumber;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failedToSendOtp;

  /// No description provided for @otpSendIssue.
  ///
  /// In en, this message translates to:
  /// **'There was an issue sending the code. You can try resending it'**
  String get otpSendIssue;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// No description provided for @viewPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Your personal information'**
  String get viewPersonalInfo;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Mohamed'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Alami'**
  String get lastNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name required'**
  String get lastNameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'{field} too short (minimum 2 characters)'**
  String nameTooShort(String field);

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'{field} too long (maximum 50 characters)'**
  String nameTooLong(String field);

  /// No description provided for @invalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Invalid characters'**
  String get invalidCharacters;

  /// No description provided for @noChangesDetected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected'**
  String get noChangesDetected;

  /// No description provided for @infoForReservations.
  ///
  /// In en, this message translates to:
  /// **'This information will be used for your reservations and verifications'**
  String get infoForReservations;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to change your profile photo. Please allow access in settings.'**
  String get cameraAccessNeeded;

  /// No description provided for @galleryAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Gallery access is needed to change your profile photo. Please allow access in settings.'**
  String get galleryAccessNeeded;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile photo'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @errorUpdatingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error updating photo'**
  String get errorUpdatingPhoto;

  /// No description provided for @editPassword.
  ///
  /// In en, this message translates to:
  /// **'Edit Password'**
  String get editPassword;

  /// No description provided for @passwordRequirementsMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordRequirementsMustContain;

  /// No description provided for @editPhone.
  ///
  /// In en, this message translates to:
  /// **'Edit Phone'**
  String get editPhone;

  /// No description provided for @editPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit phone number'**
  String get editPhoneNumber;

  /// No description provided for @enterNewPhoneAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new phone number and current password'**
  String get enterNewPhoneAndPassword;

  /// No description provided for @newPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get newPhoneNumber;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number required'**
  String get phoneNumberRequired;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format (ex: 0612345678)'**
  String get invalidPhoneFormat;

  /// No description provided for @verificationCodeWillBeSent.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to this number'**
  String get verificationCodeWillBeSent;

  /// No description provided for @enterCodeSentToPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phone}'**
  String enterCodeSentToPhone(String phone);

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {time}'**
  String codeExpiresIn(String time);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @phoneNumberChanged.
  ///
  /// In en, this message translates to:
  /// **'Phone number changed successfully'**
  String get phoneNumberChanged;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtpCode;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP code sent'**
  String get otpSent;

  /// No description provided for @phoneNumberSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'The new number is the same as the current number'**
  String get phoneNumberSameAsCurrent;

  /// No description provided for @standardInterfaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete interface with all available drivers'**
  String get standardInterfaceDescription;

  /// No description provided for @ladiesInterfaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Dedicated interface with female drivers only for more comfort'**
  String get ladiesInterfaceDescription;

  /// No description provided for @aboutLadiesInterface.
  ///
  /// In en, this message translates to:
  /// **'About Ladies Interface'**
  String get aboutLadiesInterface;

  /// No description provided for @ladiesInterfaceInfo.
  ///
  /// In en, this message translates to:
  /// **'This option allows you to travel only with certified female drivers. You can change the interface at any time.'**
  String get ladiesInterfaceInfo;

  /// No description provided for @interfaceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Interface updated successfully'**
  String get interfaceUpdated;

  /// No description provided for @errorUpdatingInterface.
  ///
  /// In en, this message translates to:
  /// **'Error updating interface'**
  String get errorUpdatingInterface;

  /// No description provided for @ladiesInterfaceBadge.
  ///
  /// In en, this message translates to:
  /// **'Ladies Interface'**
  String get ladiesInterfaceBadge;

  /// No description provided for @driverModeBadge.
  ///
  /// In en, this message translates to:
  /// **'Driver Mode'**
  String get driverModeBadge;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get confirmLogout;

  /// No description provided for @enterPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to confirm logout:'**
  String get enterPasswordToConfirm;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get logoutError;

  /// No description provided for @editProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileInfo;

  /// No description provided for @firstNameLastName.
  ///
  /// In en, this message translates to:
  /// **'First name, last name'**
  String get firstNameLastName;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get accountSecurity;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhoneNumber;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'gallery'**
  String get gallery;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @secureAccountWithStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Secure your account with a strong password'**
  String get secureAccountWithStrongPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter'**
  String get passwordNeedsLowercase;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordNeedsNumber;

  /// No description provided for @passwordNeedsSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get passwordNeedsSpecialChar;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get passwordChangeFailed;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordReqMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordReqMinChars;

  /// No description provided for @passwordReqUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get passwordReqUppercase;

  /// No description provided for @passwordReqLowercase.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get passwordReqLowercase;

  /// No description provided for @passwordReqNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get passwordReqNumber;

  /// No description provided for @passwordReqSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'One special character (!@#\$%^&*)'**
  String get passwordReqSpecialChar;

  /// No description provided for @otpCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP code required'**
  String get otpCodeRequired;

  /// No description provided for @otpCodeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get otpCodeMustBe6Digits;

  /// No description provided for @errorRequestingOtp.
  ///
  /// In en, this message translates to:
  /// **'Error requesting OTP'**
  String get errorRequestingOtp;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get profileUpdateFailed;

  /// No description provided for @locatingYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Locating your position...'**
  String get locatingYourPosition;

  /// No description provided for @continueToOptions.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToOptions;

  /// No description provided for @errorLocationService.
  ///
  /// In en, this message translates to:
  /// **'Location service error'**
  String get errorLocationService;

  /// No description provided for @pleaseSelectBothLocations.
  ///
  /// In en, this message translates to:
  /// **'Please select departure and destination'**
  String get pleaseSelectBothLocations;

  /// No description provided for @unableToCalculateDistance.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate trip distance'**
  String get unableToCalculateDistance;

  /// No description provided for @chooseRideType.
  ///
  /// In en, this message translates to:
  /// **'Choose a ride type'**
  String get chooseRideType;

  /// No description provided for @minimumPriceIs.
  ///
  /// In en, this message translates to:
  /// **'Minimum price: {price} DH'**
  String minimumPriceIs(int price);

  /// No description provided for @insufficientPointsForFreeRide.
  ///
  /// In en, this message translates to:
  /// **'Insufficient points: {requiredPoints}pts required, you have {available}pts'**
  String insufficientPointsForFreeRide(int requiredPoints, int available);

  /// No description provided for @connectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get connectingToServer;

  /// No description provided for @unableToConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server'**
  String get unableToConnectToServer;

  /// No description provided for @selectingLocationFor.
  ///
  /// In en, this message translates to:
  /// **'Selecting location for {target}'**
  String selectingLocationFor(String target);

  /// No description provided for @tapOrDragMarker.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or drag the marker'**
  String get tapOrDragMarker;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @selectingPickup.
  ///
  /// In en, this message translates to:
  /// **'departure'**
  String get selectingPickup;

  /// No description provided for @selectingDestination.
  ///
  /// In en, this message translates to:
  /// **'destination'**
  String get selectingDestination;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @carLabel.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carLabel;

  /// No description provided for @carSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard vehicle'**
  String get carSubtitle;

  /// No description provided for @motorcycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycleLabel;

  /// No description provided for @motorcycleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two-wheeled vehicle'**
  String get motorcycleSubtitle;

  /// No description provided for @truckLabel.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truckLabel;

  /// No description provided for @truckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial vehicle'**
  String get truckSubtitle;

  /// No description provided for @newApplication.
  ///
  /// In en, this message translates to:
  /// **'New Application'**
  String get newApplication;

  /// No description provided for @driverRegistration.
  ///
  /// In en, this message translates to:
  /// **'Driver Registration'**
  String get driverRegistration;

  /// No description provided for @cinInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'CIN Information'**
  String get cinInformationTitle;

  /// No description provided for @cinInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide your identity documents'**
  String get cinInformationSubtitle;

  /// No description provided for @cinRectoPhoto.
  ///
  /// In en, this message translates to:
  /// **'CIN Front Photo'**
  String get cinRectoPhoto;

  /// No description provided for @cinVersoPhoto.
  ///
  /// In en, this message translates to:
  /// **'CIN Back Photo'**
  String get cinVersoPhoto;

  /// No description provided for @selfieWithCIN.
  ///
  /// In en, this message translates to:
  /// **'Selfie with CIN'**
  String get selfieWithCIN;

  /// No description provided for @cinCode.
  ///
  /// In en, this message translates to:
  /// **'CIN Code'**
  String get cinCode;

  /// No description provided for @cinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: AB123456'**
  String get cinCodeHint;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @vehicleInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformationTitle;

  /// No description provided for @vehicleInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Details of your vehicle'**
  String get vehicleInformationSubtitle;

  /// No description provided for @vehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photo'**
  String get vehiclePhoto;

  /// No description provided for @vehicleRegistrationRecto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration Front'**
  String get vehicleRegistrationRecto;

  /// No description provided for @vehicleRegistrationVerso.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration Back'**
  String get vehicleRegistrationVerso;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @registrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 12345-A-67'**
  String get registrationNumberHint;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @brandHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Toyota'**
  String get brandHint;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @modelHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Corolla'**
  String get modelHint;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @colorHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: White'**
  String get colorHint;

  /// No description provided for @productionYear.
  ///
  /// In en, this message translates to:
  /// **'Production Year'**
  String get productionYear;

  /// No description provided for @productionYearHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 2020'**
  String get productionYearHint;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please verify your information before submitting'**
  String get reviewSubtitle;

  /// No description provided for @cinInformationSection.
  ///
  /// In en, this message translates to:
  /// **'CIN Information'**
  String get cinInformationSection;

  /// No description provided for @vehicleInformationSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformationSection;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'✓ Uploaded'**
  String get uploaded;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get vehicleTypeLabel;

  /// No description provided for @registrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationNumberLabel;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @vehiclePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photo'**
  String get vehiclePhotoLabel;

  /// No description provided for @vehicleRegistrationRectoLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Front'**
  String get vehicleRegistrationRectoLabel;

  /// No description provided for @vehicleRegistrationVersoLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Back'**
  String get vehicleRegistrationVersoLabel;

  /// No description provided for @verificationNotice.
  ///
  /// In en, this message translates to:
  /// **'Your application will be verified within 24-48 hours'**
  String get verificationNotice;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @tapToTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to take a photo'**
  String get tapToTakePhoto;

  /// No description provided for @cinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'CIN Code'**
  String get cinCodeLabel;

  /// No description provided for @expirationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDateLabel;

  /// No description provided for @cinRectoLabel.
  ///
  /// In en, this message translates to:
  /// **'CIN Front'**
  String get cinRectoLabel;

  /// No description provided for @cinVersoLabel.
  ///
  /// In en, this message translates to:
  /// **'CIN Back'**
  String get cinVersoLabel;

  /// No description provided for @selfieLabel.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get selfieLabel;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @submittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully'**
  String get submittedSuccessfully;

  /// No description provided for @submissionError.
  ///
  /// In en, this message translates to:
  /// **'Error during submission'**
  String get submissionError;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @totalRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get totalRides;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalAmount;

  /// No description provided for @ridesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{loaded} of {total} rides loaded'**
  String ridesLoaded(int loaded, int total);

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get statusStarted;

  /// No description provided for @paymentAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentAll;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get paymentWallet;

  /// No description provided for @paymentCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentCreditCard;

  /// No description provided for @paymentLoyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get paymentLoyaltyPoints;

  /// No description provided for @paymentFreeRide.
  ///
  /// In en, this message translates to:
  /// **'Free Ride'**
  String get paymentFreeRide;

  /// No description provided for @vehicleAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get vehicleAll;

  /// No description provided for @vehicleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleCar;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get vehicleTruck;

  /// No description provided for @sortPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price (high to low)'**
  String get sortPriceHighToLow;

  /// No description provided for @sortPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price (low to high)'**
  String get sortPriceLowToHigh;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get sortDistance;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @rateDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate driver'**
  String get rateDriver;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @thankYouForRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get thankYouForRating;

  /// No description provided for @complaintSent.
  ///
  /// In en, this message translates to:
  /// **'Complaint sent successfully'**
  String get complaintSent;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noRidesTitle.
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesTitle;

  /// No description provided for @noRidesDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust your filters or check back later'**
  String get noRidesDescription;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearAllFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @searchDriver.
  ///
  /// In en, this message translates to:
  /// **'Search for a driver...'**
  String get searchDriver;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceRange;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxPrice;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @passengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// No description provided for @driverRating.
  ///
  /// In en, this message translates to:
  /// **'Driver rating'**
  String get driverRating;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get notRated;

  /// No description provided for @rated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get rated;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get started;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get creditCard;

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty points'**
  String get loyaltyPoints;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @totalRidesLabel.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get totalRidesLabel;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortByLabel;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @vehicleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get vehicleStandard;

  /// No description provided for @vehiclePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get vehiclePremium;

  /// No description provided for @vehicleLadiesOnly.
  ///
  /// In en, this message translates to:
  /// **'Ladies-only'**
  String get vehicleLadiesOnly;

  /// No description provided for @sortDateNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date (newest first)'**
  String get sortDateNewestFirst;

  /// No description provided for @sortDateOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date (oldest first)'**
  String get sortDateOldestFirst;

  /// No description provided for @viewTripLocation.
  ///
  /// In en, this message translates to:
  /// **'Trip Location'**
  String get viewTripLocation;

  /// No description provided for @passengerLabel.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passengerLabel;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @fareDetails.
  ///
  /// In en, this message translates to:
  /// **'Fare Details'**
  String get fareDetails;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @rateThisTrip.
  ///
  /// In en, this message translates to:
  /// **'Rate this trip'**
  String get rateThisTrip;

  /// No description provided for @rateButton.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateButton;

  /// No description provided for @complaintButton.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaintButton;

  /// No description provided for @statusCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompletedBadge;

  /// No description provided for @statusCancelledBadge.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelledBadge;

  /// No description provided for @statusInProgressBadge.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgressBadge;

  /// No description provided for @noTripsFound.
  ///
  /// In en, this message translates to:
  /// **'No trips found'**
  String get noTripsFound;

  /// No description provided for @tripsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your trips will appear here'**
  String get tripsWillAppearHere;

  /// No description provided for @passengerDefault.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passengerDefault;

  /// No description provided for @driverDefault.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverDefault;

  /// No description provided for @filtersAndSort.
  ///
  /// In en, this message translates to:
  /// **'Filters and Sort'**
  String get filtersAndSort;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'{count} active filter(s)'**
  String activeFilters(int count);

  /// No description provided for @noActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'No active filters'**
  String get noActiveFilters;

  /// No description provided for @driverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Driver name'**
  String get driverNameHint;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @allPriceRanges.
  ///
  /// In en, this message translates to:
  /// **'All price ranges'**
  String get allPriceRanges;

  /// No description provided for @addPriceFilter.
  ///
  /// In en, this message translates to:
  /// **'Add price filter'**
  String get addPriceFilter;

  /// No description provided for @statusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFilter;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @cancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledStatus;

  /// No description provided for @paymentFilter.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentFilter;

  /// No description provided for @allPayment.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPayment;

  /// No description provided for @walletPayment.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletPayment;

  /// No description provided for @creditCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get creditCardPayment;

  /// No description provided for @loyaltyPointsPayment.
  ///
  /// In en, this message translates to:
  /// **'Loyalty points'**
  String get loyaltyPointsPayment;

  /// No description provided for @freeRidePayment.
  ///
  /// In en, this message translates to:
  /// **'Free ride'**
  String get freeRidePayment;

  /// No description provided for @vehicleFilter.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleFilter;

  /// No description provided for @allVehicles.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allVehicles;

  /// No description provided for @carVehicle.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carVehicle;

  /// No description provided for @motorcycleVehicle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycleVehicle;

  /// No description provided for @truckVehicle.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truckVehicle;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @resetAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset all filters'**
  String get resetAllFilters;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPeriod;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @progressToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Progress to {nextLevel}'**
  String progressToNextLevel(String nextLevel);

  /// No description provided for @needPointsToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Need {pointsNeeded} more points to unlock {nextLevel} benefits'**
  String needPointsToUnlock(int pointsNeeded, String nextLevel);

  /// No description provided for @earnPoints.
  ///
  /// In en, this message translates to:
  /// **'Earn Points'**
  String get earnPoints;

  /// No description provided for @earnPointsByRide.
  ///
  /// In en, this message translates to:
  /// **'Points for each ride'**
  String get earnPointsByRide;

  /// No description provided for @earnPointsByReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral points'**
  String get earnPointsByReferral;

  /// No description provided for @earnPointsByRating.
  ///
  /// In en, this message translates to:
  /// **'Points for rating'**
  String get earnPointsByRating;

  /// No description provided for @referAFriend.
  ///
  /// In en, this message translates to:
  /// **'Refer a Friend'**
  String get referAFriend;

  /// No description provided for @shareAndEarnPoints.
  ///
  /// In en, this message translates to:
  /// **'Share and earn points'**
  String get shareAndEarnPoints;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @allTransactionsLoaded.
  ///
  /// In en, this message translates to:
  /// **'All transactions loaded'**
  String get allTransactionsLoaded;

  /// No description provided for @rideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ride completed'**
  String get rideCompleted;

  /// No description provided for @referralBonus.
  ///
  /// In en, this message translates to:
  /// **'Referral bonus'**
  String get referralBonus;

  /// No description provided for @ratingBonus.
  ///
  /// In en, this message translates to:
  /// **'Rating bonus'**
  String get ratingBonus;

  /// No description provided for @pointsUsed.
  ///
  /// In en, this message translates to:
  /// **'Points used'**
  String get pointsUsed;

  /// No description provided for @levelBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get levelBronze;

  /// No description provided for @levelSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get levelSilver;

  /// No description provided for @levelGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get levelGold;

  /// No description provided for @levelPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get levelPlatinum;

  /// No description provided for @levelDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get levelDiamond;

  /// No description provided for @dataRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Data refreshed'**
  String get dataRefreshed;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorRefreshingData.
  ///
  /// In en, this message translates to:
  /// **'Error refreshing data'**
  String get errorRefreshingData;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @pleaseSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get pleaseSelectOption;

  /// No description provided for @ratePassenger.
  ///
  /// In en, this message translates to:
  /// **'Rate passenger'**
  String get ratePassenger;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with {name}?'**
  String howWasYourExperience(String name);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category:'**
  String get selectCategory;

  /// No description provided for @noOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get noOptionsAvailable;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @invitationRegistered.
  ///
  /// In en, this message translates to:
  /// **'Invitation registered! Share the link with your friend.'**
  String get invitationRegistered;

  /// No description provided for @phoneNotEligible.
  ///
  /// In en, this message translates to:
  /// **'This number is not eligible for referral'**
  String get phoneNotEligible;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @errorCopyingLink.
  ///
  /// In en, this message translates to:
  /// **'Error copying link.'**
  String get errorCopyingLink;

  /// No description provided for @linkSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Link shared successfully!'**
  String get linkSharedSuccess;

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing.'**
  String get errorSharing;

  /// No description provided for @earnPointsPerFriend.
  ///
  /// In en, this message translates to:
  /// **'Earn 50 points per friend'**
  String get earnPointsPerFriend;

  /// No description provided for @referralInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your friend\'s number to register it, then share the link with them.'**
  String get referralInfoMessage;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @savePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Save phone number'**
  String get savePhoneNumber;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @referralLink.
  ///
  /// In en, this message translates to:
  /// **'Referral link'**
  String get referralLink;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @referralShareMessage.
  ///
  /// In en, this message translates to:
  /// **'🎉 Join me on SRRFRR!\n\nI use SRRFRR for my trips and I think you might be interested too!\n\n🎁 Download the app and get 50 welcome points!\n🚗 It\'s simple, fast and secure\n\nDownload now: {link}\n\nSee you soon on SRRFRR! 🚙'**
  String referralShareMessage(String link);

  /// No description provided for @referralInvitationSubject.
  ///
  /// In en, this message translates to:
  /// **'SRRFRR Invitation'**
  String get referralInvitationSubject;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @searchInFaq.
  ///
  /// In en, this message translates to:
  /// **'Search in FAQ...'**
  String get searchInFaq;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @ourTeamIsHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'Our team is here to help you'**
  String get ourTeamIsHereToHelp;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri: 9AM-6PM'**
  String get businessHours;

  /// No description provided for @sendComplaint.
  ///
  /// In en, this message translates to:
  /// **'Send a complaint'**
  String get sendComplaint;

  /// No description provided for @describeYourProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem and our team will respond quickly'**
  String get describeYourProblem;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryOtherKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try other keywords'**
  String get tryOtherKeywords;

  /// No description provided for @pleaseDescribeProblem.
  ///
  /// In en, this message translates to:
  /// **'Please describe your problem'**
  String get pleaseDescribeProblem;

  /// No description provided for @provideMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (minimum 10 characters)'**
  String get provideMoreDetails;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @technicalIssue.
  ///
  /// In en, this message translates to:
  /// **'Technical issue'**
  String get technicalIssue;

  /// No description provided for @accountingIssue.
  ///
  /// In en, this message translates to:
  /// **'Accounting issue'**
  String get accountingIssue;

  /// No description provided for @safetyIssue.
  ///
  /// In en, this message translates to:
  /// **'Safety issue'**
  String get safetyIssue;

  /// No description provided for @drivingIssue.
  ///
  /// In en, this message translates to:
  /// **'Driving issue'**
  String get drivingIssue;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeYourProblemInDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem in detail. Our team will get back to you as soon as possible.'**
  String get describeYourProblemInDetail;

  /// No description provided for @trajectoryRef.
  ///
  /// In en, this message translates to:
  /// **'Trajectory reference #{ref}'**
  String trajectoryRef(String ref);

  /// No description provided for @sendReclamation.
  ///
  /// In en, this message translates to:
  /// **'Send reclamation'**
  String get sendReclamation;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem'**
  String get describeProblem;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 10 characters required'**
  String get minCharacters;

  /// No description provided for @exampleReclamation.
  ///
  /// In en, this message translates to:
  /// **'Example: I had an issue with my last trip where the driver took a longer route than necessary, which increased the cost of the ride. I would like this to be reviewed and for measures to be taken to prevent this from happening again.'**
  String get exampleReclamation;

  /// No description provided for @sendComplaintButton.
  ///
  /// In en, this message translates to:
  /// **'Send complaint'**
  String get sendComplaintButton;

  /// No description provided for @faqAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account and Registration'**
  String get faqAccountTitle;

  /// No description provided for @faqAccount1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I create an account?'**
  String get faqAccount1Q;

  /// No description provided for @faqAccount1A.
  ///
  /// In en, this message translates to:
  /// **'To create an account, download the SRRFRR app, enter your phone number, verify the OTP code sent by SMS, then complete your profile with your personal information.'**
  String get faqAccount1A;

  /// No description provided for @faqAccount2Q.
  ///
  /// In en, this message translates to:
  /// **'Can I use the same account as passenger and driver?'**
  String get faqAccount2Q;

  /// No description provided for @faqAccount2A.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can switch between passenger and driver modes in the app settings. To become a driver, you must submit an application with your documents.'**
  String get faqAccount2A;

  /// No description provided for @faqAccount3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I change my phone number?'**
  String get faqAccount3Q;

  /// No description provided for @faqAccount3A.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Profile > Edit Phone Number. You will need to verify the new number with an OTP code.'**
  String get faqAccount3A;

  /// No description provided for @faqBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Rides'**
  String get faqBookingTitle;

  /// No description provided for @faqBooking1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I book a ride?'**
  String get faqBooking1Q;

  /// No description provided for @faqBooking1A.
  ///
  /// In en, this message translates to:
  /// **'On the home screen, enter your destination, choose the vehicle type, check the estimated price, then tap \'Confirm Request\'. A driver will accept your request in a few moments.'**
  String get faqBooking1A;

  /// No description provided for @faqBooking2Q.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a ride?'**
  String get faqBooking2Q;

  /// No description provided for @faqBooking2A.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can cancel a ride before a driver accepts without fees. After acceptance, cancellation fees may apply.'**
  String get faqBooking2A;

  /// No description provided for @faqBooking3Q.
  ///
  /// In en, this message translates to:
  /// **'How does Ladies-only mode work?'**
  String get faqBooking3Q;

  /// No description provided for @faqBooking3A.
  ///
  /// In en, this message translates to:
  /// **'Ladies-only mode allows female passengers to be matched only with female drivers. Enable this option in your profile settings.'**
  String get faqBooking3A;

  /// No description provided for @faqPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get faqPaymentTitle;

  /// No description provided for @faqPayment1Q.
  ///
  /// In en, this message translates to:
  /// **'What payment methods are accepted?'**
  String get faqPayment1Q;

  /// No description provided for @faqPayment1A.
  ///
  /// In en, this message translates to:
  /// **'We accept cash and credit card payments. You can choose your preferred payment method when booking.'**
  String get faqPayment1A;

  /// No description provided for @faqPayment2Q.
  ///
  /// In en, this message translates to:
  /// **'How do loyalty points work?'**
  String get faqPayment2Q;

  /// No description provided for @faqPayment2A.
  ///
  /// In en, this message translates to:
  /// **'You earn points with each completed ride, when referring friends, and by using the app regularly. These points can be redeemed for discounts on your rides.'**
  String get faqPayment2A;

  /// No description provided for @faqPayment3Q.
  ///
  /// In en, this message translates to:
  /// **'Can I get a receipt for my ride?'**
  String get faqPayment3Q;

  /// No description provided for @faqPayment3A.
  ///
  /// In en, this message translates to:
  /// **'Yes, all your receipts are available in the ride history. You can download them or receive them by email.'**
  String get faqPayment3A;

  /// No description provided for @faqSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get faqSafetyTitle;

  /// No description provided for @faqSafety1Q.
  ///
  /// In en, this message translates to:
  /// **'How does SRRFRR ensure my safety?'**
  String get faqSafety1Q;

  /// No description provided for @faqSafety1A.
  ///
  /// In en, this message translates to:
  /// **'All drivers are verified with their official documents. You can share your ride in real-time with loved ones and report any issues via the app.'**
  String get faqSafety1A;

  /// No description provided for @faqSafety2Q.
  ///
  /// In en, this message translates to:
  /// **'What should I do if there\'s a problem during a ride?'**
  String get faqSafety2Q;

  /// No description provided for @faqSafety2A.
  ///
  /// In en, this message translates to:
  /// **'Use the \'Emergency\' button in the app to immediately contact our security team. You can also call authorities directly if necessary.'**
  String get faqSafety2A;

  /// No description provided for @faqSafety3Q.
  ///
  /// In en, this message translates to:
  /// **'Is my personal data protected?'**
  String get faqSafety3Q;

  /// No description provided for @faqSafety3A.
  ///
  /// In en, this message translates to:
  /// **'Yes, we use bank-level encryption to protect all your personal and financial data. We never share your information with third parties.'**
  String get faqSafety3A;

  /// No description provided for @faqDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Becoming a Driver'**
  String get faqDriverTitle;

  /// No description provided for @faqDriver1Q.
  ///
  /// In en, this message translates to:
  /// **'What are the requirements to become a driver?'**
  String get faqDriver1Q;

  /// No description provided for @faqDriver1A.
  ///
  /// In en, this message translates to:
  /// **'You must have a valid driver\'s license, ID card, a vehicle in good condition with valid registration, and be at least 21 years old.'**
  String get faqDriver1A;

  /// No description provided for @faqDriver2Q.
  ///
  /// In en, this message translates to:
  /// **'How long does driver account validation take?'**
  String get faqDriver2Q;

  /// No description provided for @faqDriver2A.
  ///
  /// In en, this message translates to:
  /// **'Document verification usually takes 24 to 48 hours. You will receive a notification once your account is validated.'**
  String get faqDriver2A;

  /// No description provided for @faqDriver3Q.
  ///
  /// In en, this message translates to:
  /// **'How are my earnings calculated?'**
  String get faqDriver3Q;

  /// No description provided for @faqDriver3A.
  ///
  /// In en, this message translates to:
  /// **'Your earnings are calculated based on distance traveled, trip time, and current demand. SRRFRR takes a 15% commission on each ride.'**
  String get faqDriver3A;

  /// No description provided for @faqDriver4Q.
  ///
  /// In en, this message translates to:
  /// **'When can I withdraw my earnings?'**
  String get faqDriver4Q;

  /// No description provided for @faqDriver4A.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your earnings anytime via your driver wallet. Withdrawals are processed within 1 to 3 business days.'**
  String get faqDriver4A;

  /// No description provided for @faqTechTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical Issues'**
  String get faqTechTitle;

  /// No description provided for @faqTech1Q.
  ///
  /// In en, this message translates to:
  /// **'The app can\'t find my location'**
  String get faqTech1Q;

  /// No description provided for @faqTech1A.
  ///
  /// In en, this message translates to:
  /// **'Check that you have enabled location services for the app in your phone settings. Also ensure you have an active internet connection.'**
  String get faqTech1A;

  /// No description provided for @faqTech2Q.
  ///
  /// In en, this message translates to:
  /// **'I\'m not receiving the OTP code'**
  String get faqTech2Q;

  /// No description provided for @faqTech2A.
  ///
  /// In en, this message translates to:
  /// **'Verify that you entered the correct phone number and have network coverage. If the problem persists, use the \'Resend code\' option after 60 seconds.'**
  String get faqTech2A;

  /// No description provided for @faqTech3Q.
  ///
  /// In en, this message translates to:
  /// **'The app closes unexpectedly'**
  String get faqTech3Q;

  /// No description provided for @faqTech3A.
  ///
  /// In en, this message translates to:
  /// **'Try updating the app to the latest version, restart your phone, and ensure you have enough storage space available.'**
  String get faqTech3A;

  /// No description provided for @walletBalanceTransactions.
  ///
  /// In en, this message translates to:
  /// **'Balance and transactions'**
  String get walletBalanceTransactions;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage my subscription'**
  String get manageSubscription;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @passengerMode.
  ///
  /// In en, this message translates to:
  /// **'Passenger Mode'**
  String get passengerMode;

  /// No description provided for @ladiesInterfaceDriverBadge.
  ///
  /// In en, this message translates to:
  /// **'SRR FRR Ladies Driver'**
  String get ladiesInterfaceDriverBadge;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @notRegisteredTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a Driver'**
  String get notRegisteredTitle;

  /// No description provided for @notRegisteredDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn your trips into income and join our community of drivers'**
  String get notRegisteredDescription;

  /// No description provided for @startRegistration.
  ///
  /// In en, this message translates to:
  /// **'Start Registration'**
  String get startRegistration;

  /// No description provided for @pendingVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Verification'**
  String get pendingVerificationTitle;

  /// No description provided for @pendingVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your application.\nYou will receive a notification once validated'**
  String get pendingVerificationDescription;

  /// No description provided for @verificationTimeframe.
  ///
  /// In en, this message translates to:
  /// **'Verification usually takes 24 to 48 business hours'**
  String get verificationTimeframe;

  /// No description provided for @processingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get processingTime;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to home'**
  String get returnHome;

  /// No description provided for @validatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get validatedTitle;

  /// No description provided for @validatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your driver account\nhas been successfully validated'**
  String get validatedDescription;

  /// No description provided for @welcomeDrivers.
  ///
  /// In en, this message translates to:
  /// **'Welcome among the drivers'**
  String get welcomeDrivers;

  /// No description provided for @welcomeDriversDescription.
  ///
  /// In en, this message translates to:
  /// **'You are now a verified SRR FRR driver and can start accepting rides'**
  String get welcomeDriversDescription;

  /// No description provided for @verifiedStatus.
  ///
  /// In en, this message translates to:
  /// **'Verified status'**
  String get verifiedStatus;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Certified driver badge'**
  String get verifiedBadge;

  /// No description provided for @flexibleIncome.
  ///
  /// In en, this message translates to:
  /// **'Flexible income'**
  String get flexibleIncome;

  /// No description provided for @flexibleIncomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn according to your availability'**
  String get flexibleIncomeDesc;

  /// No description provided for @insuredProtection.
  ///
  /// In en, this message translates to:
  /// **'Insured protection'**
  String get insuredProtection;

  /// No description provided for @insuredProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Full coverage during rides'**
  String get insuredProtectionDesc;

  /// No description provided for @startDriving.
  ///
  /// In en, this message translates to:
  /// **'Start driving'**
  String get startDriving;

  /// No description provided for @rejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Not Approved'**
  String get rejectedTitle;

  /// No description provided for @rejectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your application needs adjustments.\nYou can submit a new application'**
  String get rejectedDescription;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get rejectionReason;

  /// No description provided for @defaultRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Incomplete or invalid documents. Please verify your information and submit compliant documents.'**
  String get defaultRejectionReason;

  /// No description provided for @attractiveIncome.
  ///
  /// In en, this message translates to:
  /// **'Attractive income'**
  String get attractiveIncome;

  /// No description provided for @attractiveIncomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your rates and maximize your earnings'**
  String get attractiveIncomeDesc;

  /// No description provided for @totalFreedom.
  ///
  /// In en, this message translates to:
  /// **'Total freedom'**
  String get totalFreedom;

  /// No description provided for @totalFreedomDesc.
  ///
  /// In en, this message translates to:
  /// **'Work according to your schedule'**
  String get totalFreedomDesc;

  /// No description provided for @guaranteedSafety.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed safety'**
  String get guaranteedSafety;

  /// No description provided for @guaranteedSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete protection for every ride'**
  String get guaranteedSafetyDesc;

  /// No description provided for @verifyingStatus.
  ///
  /// In en, this message translates to:
  /// **'Verifying status...'**
  String get verifyingStatus;

  /// No description provided for @myVehicle.
  ///
  /// In en, this message translates to:
  /// **'My Vehicle'**
  String get myVehicle;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @driverWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get driverWallet;

  /// No description provided for @totalRidesDriver.
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRidesDriver;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @historyDriver.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyDriver;

  /// No description provided for @supportDriver.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportDriver;

  /// No description provided for @onlineMode.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineMode;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineMode;

  /// No description provided for @readyToAccept.
  ///
  /// In en, this message translates to:
  /// **'Ready to accept rides'**
  String get readyToAccept;

  /// No description provided for @activateToReceive.
  ///
  /// In en, this message translates to:
  /// **'Activate to receive requests'**
  String get activateToReceive;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get goOnline;

  /// No description provided for @goOffline.
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get goOffline;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get noRequests;

  /// No description provided for @searchingNearby.
  ///
  /// In en, this message translates to:
  /// **'Searching for nearby passengers...'**
  String get searchingNearby;

  /// No description provided for @notificationsActive.
  ///
  /// In en, this message translates to:
  /// **'Notifications active'**
  String get notificationsActive;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineStatus;

  /// No description provided for @goOnlineToReceive.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive requests'**
  String get goOnlineToReceive;

  /// No description provided for @activeRequests.
  ///
  /// In en, this message translates to:
  /// **'Active Requests'**
  String get activeRequests;

  /// No description provided for @counterOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a counter-offer'**
  String get counterOfferTitle;

  /// No description provided for @passengerOffer.
  ///
  /// In en, this message translates to:
  /// **'Passenger offer:'**
  String get passengerOffer;

  /// No description provided for @yourCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Your counter-offer'**
  String get yourCounterOffer;

  /// No description provided for @enterYourPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter your price'**
  String get enterYourPrice;

  /// No description provided for @fairPriceTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Propose a fair price based on distance and time'**
  String get fairPriceTip;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get sendOffer;

  /// No description provided for @negotiateButton.
  ///
  /// In en, this message translates to:
  /// **'Negotiate'**
  String get negotiateButton;

  /// No description provided for @refuseButton.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuseButton;

  /// No description provided for @acceptRide.
  ///
  /// In en, this message translates to:
  /// **'Accept ride'**
  String get acceptRide;

  /// No description provided for @waitingForResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Response'**
  String get waitingForResponse;

  /// No description provided for @secondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining'**
  String secondsRemaining(int seconds);

  /// No description provided for @cancelOffer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Offer'**
  String get cancelOffer;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @unknownAddress.
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get unknownAddress;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get walletTitle;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @codesTab.
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get codesTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @rechargeWallet.
  ///
  /// In en, this message translates to:
  /// **'Recharge Wallet'**
  String get rechargeWallet;

  /// No description provided for @monthDetails.
  ///
  /// In en, this message translates to:
  /// **'Month Details'**
  String get monthDetails;

  /// No description provided for @grossEarnings.
  ///
  /// In en, this message translates to:
  /// **'Gross earnings'**
  String get grossEarnings;

  /// No description provided for @commissions.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get commissions;

  /// No description provided for @netEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net earnings'**
  String get netEarnings;

  /// No description provided for @costPerRide.
  ///
  /// In en, this message translates to:
  /// **'Cost per ride'**
  String get costPerRide;

  /// No description provided for @effectiveRate.
  ///
  /// In en, this message translates to:
  /// **'Effective rate'**
  String get effectiveRate;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'DH'**
  String get currencySymbol;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @transactionTypeCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get transactionTypeCredit;

  /// No description provided for @transactionTypeDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get transactionTypeDebit;

  /// No description provided for @transactionTypeCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get transactionTypeCommission;

  /// No description provided for @transactionTypeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get transactionTypeSubscription;

  /// No description provided for @transactionTypeInit.
  ///
  /// In en, this message translates to:
  /// **'Initialization'**
  String get transactionTypeInit;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @perRide.
  ///
  /// In en, this message translates to:
  /// **'Per Ride'**
  String get perRide;

  /// No description provided for @totalDebits.
  ///
  /// In en, this message translates to:
  /// **'Total Debits'**
  String get totalDebits;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @netThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Net this month'**
  String get netThisMonth;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total transactions'**
  String get totalTransactions;

  /// No description provided for @generateNewCode.
  ///
  /// In en, this message translates to:
  /// **'Generate New Code'**
  String get generateNewCode;

  /// No description provided for @activeCodes.
  ///
  /// In en, this message translates to:
  /// **'Active Codes'**
  String get activeCodes;

  /// No description provided for @expiredCodes.
  ///
  /// In en, this message translates to:
  /// **'Expired Codes'**
  String get expiredCodes;

  /// No description provided for @noRechargeCodes.
  ///
  /// In en, this message translates to:
  /// **'No recharge codes'**
  String get noRechargeCodes;

  /// No description provided for @generateCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a code to recharge\nyour wallet'**
  String get generateCodeDescription;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @deleteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Code'**
  String get deleteCodeTitle;

  /// No description provided for @deleteCodeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recharge code?'**
  String get deleteCodeConfirmation;

  /// No description provided for @codeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Code deleted'**
  String get codeDeleted;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @generateCodeOption.
  ///
  /// In en, this message translates to:
  /// **'Generate a Code'**
  String get generateCodeOption;

  /// No description provided for @generateCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay at agency with a code'**
  String get generateCodeSubtitle;

  /// No description provided for @creditCardOption.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCardOption;

  /// No description provided for @creditCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure online payment'**
  String get creditCardSubtitle;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (DH)'**
  String get amount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 500'**
  String get amountHint;

  /// No description provided for @generateCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Present this code at agency to make payment'**
  String get generateCodeInfo;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @codeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Code Generated'**
  String get codeGenerated;

  /// No description provided for @presentCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Present this code at agency to\nrecharge your wallet'**
  String get presentCodeInfo;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @cardPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPaymentTitle;

  /// No description provided for @securePaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Secure payment • Immediate recharge'**
  String get securePaymentInfo;

  /// No description provided for @redirectingPayment.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to secure payment...'**
  String get redirectingPayment;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTitle;

  /// No description provided for @plansTab.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTab;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noActiveSubscription;

  /// No description provided for @choosePlanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to unlock\nall benefits'**
  String get choosePlanPrompt;

  /// No description provided for @ridesUsed.
  ///
  /// In en, this message translates to:
  /// **'Rides used'**
  String get ridesUsed;

  /// No description provided for @coursesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Courses this month'**
  String get coursesThisMonth;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'UNLIMITED'**
  String get unlimited;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subscriptionExpired;

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresInDays(int days);

  /// No description provided for @renewsInDays.
  ///
  /// In en, this message translates to:
  /// **'Renews in {days} days'**
  String renewsInDays(int days);

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelSubscriptionDialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription?'**
  String get cancelSubscriptionDialog;

  /// No description provided for @cancelSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Your {planName} subscription will be cancelled immediately'**
  String cancelSubscriptionWarning(String planName);

  /// No description provided for @subscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get subscriptionCancelled;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get choosePlan;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @amountPerMonth.
  ///
  /// In en, this message translates to:
  /// **'DH/month'**
  String get amountPerMonth;

  /// No description provided for @activeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get activeSubscription;

  /// No description provided for @changeToPlan.
  ///
  /// In en, this message translates to:
  /// **'Change to this plan'**
  String get changeToPlan;

  /// No description provided for @chooseThisPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose this plan'**
  String get chooseThisPlan;

  /// No description provided for @takeAdvantage.
  ///
  /// In en, this message translates to:
  /// **'🎉 Take advantage of offer'**
  String get takeAdvantage;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @confirmSubscription.
  ///
  /// In en, this message translates to:
  /// **'Confirm subscription'**
  String get confirmSubscription;

  /// No description provided for @subscribeToPlan.
  ///
  /// In en, this message translates to:
  /// **'You will subscribe to the {planName} plan'**
  String subscribeToPlan(String planName);

  /// No description provided for @newPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newPlan;

  /// No description provided for @changeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Change subscription'**
  String get changeSubscription;

  /// No description provided for @switchFromTo.
  ///
  /// In en, this message translates to:
  /// **'Switch from {fromPlan} to {toPlan}'**
  String switchFromTo(String fromPlan, String toPlan);

  /// No description provided for @changeEffectiveImmediately.
  ///
  /// In en, this message translates to:
  /// **'Change effective immediately'**
  String get changeEffectiveImmediately;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated!'**
  String get subscriptionActivated;

  /// No description provided for @subscriptionChanged.
  ///
  /// In en, this message translates to:
  /// **'Subscription changed!'**
  String get subscriptionChanged;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noHistory;

  /// No description provided for @historyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Your past subscriptions\nwill appear here'**
  String get historyPrompt;

  /// No description provided for @itemsOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} / {total}'**
  String itemsOfTotal(int count, int total);

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @rideLimit.
  ///
  /// In en, this message translates to:
  /// **'Ride limit'**
  String get rideLimit;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @vip247.
  ///
  /// In en, this message translates to:
  /// **'VIP 24/7'**
  String get vip247;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @canChangeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Can I change subscription?'**
  String get canChangeSubscription;

  /// No description provided for @changeSubscriptionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can change at any time. Changes take effect immediately.'**
  String get changeSubscriptionAnswer;

  /// No description provided for @exceedLimitQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens if I exceed my limit?'**
  String get exceedLimitQuestion;

  /// No description provided for @exceedLimitAnswer.
  ///
  /// In en, this message translates to:
  /// **'For Basic and Premium, you won\'t be able to accept rides until renewal.'**
  String get exceedLimitAnswer;

  /// No description provided for @howRenewalWorks.
  ///
  /// In en, this message translates to:
  /// **'How does renewal work?'**
  String get howRenewalWorks;

  /// No description provided for @renewalAnswer.
  ///
  /// In en, this message translates to:
  /// **'Subscription renews automatically each month. You can cancel at any time.'**
  String get renewalAnswer;

  /// No description provided for @canGetRefund.
  ///
  /// In en, this message translates to:
  /// **'Can I get a refund?'**
  String get canGetRefund;

  /// No description provided for @refundAnswer.
  ///
  /// In en, this message translates to:
  /// **'Refund possible within 7 days if no rides have been taken.'**
  String get refundAnswer;

  /// No description provided for @commissionModel.
  ///
  /// In en, this message translates to:
  /// **'Commission Model'**
  String get commissionModel;

  /// No description provided for @preferCommission.
  ///
  /// In en, this message translates to:
  /// **'Prefer commission model?'**
  String get preferCommission;

  /// No description provided for @commissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'8% per ride instead of subscription. Ideal for low ride volume.'**
  String get commissionExplanation;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @commissionModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission Model'**
  String get commissionModalTitle;

  /// No description provided for @commissionPerRide.
  ///
  /// In en, this message translates to:
  /// **'Pay 8% commission per ride'**
  String get commissionPerRide;

  /// No description provided for @commissionFeature1.
  ///
  /// In en, this message translates to:
  /// **'8% commission per ride'**
  String get commissionFeature1;

  /// No description provided for @commissionFeature2.
  ///
  /// In en, this message translates to:
  /// **'No monthly fees'**
  String get commissionFeature2;

  /// No description provided for @commissionFeature3.
  ///
  /// In en, this message translates to:
  /// **'Unlimited rides'**
  String get commissionFeature3;

  /// No description provided for @commissionExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 100 DH ride → 8 DH commission'**
  String get commissionExample;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @daysForMonth.
  ///
  /// In en, this message translates to:
  /// **'{days} days for 1 month'**
  String daysForMonth(int days);

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special offer for your\nfirst subscription!'**
  String get specialOffer;

  /// No description provided for @errorLoadingPlans.
  ///
  /// In en, this message translates to:
  /// **'Error loading plans'**
  String get errorLoadingPlans;

  /// No description provided for @errorSubscription.
  ///
  /// In en, this message translates to:
  /// **'Error during subscription'**
  String get errorSubscription;

  /// No description provided for @errorCancellation.
  ///
  /// In en, this message translates to:
  /// **'Error during cancellation'**
  String get errorCancellation;

  /// No description provided for @errorChanging.
  ///
  /// In en, this message translates to:
  /// **'Error changing subscription'**
  String get errorChanging;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get errorLoadingHistory;

  /// No description provided for @rideLimitBasic.
  ///
  /// In en, this message translates to:
  /// **'60 rides/month'**
  String get rideLimitBasic;

  /// No description provided for @rideLimitPremium.
  ///
  /// In en, this message translates to:
  /// **'150 rides/month'**
  String get rideLimitPremium;

  /// No description provided for @rideLimitPro.
  ///
  /// In en, this message translates to:
  /// **'Unlimited courses'**
  String get rideLimitPro;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get notificationsMarkedAsRead;

  /// No description provided for @notificationsMarkError.
  ///
  /// In en, this message translates to:
  /// **'Error marking notifications'**
  String get notificationsMarkError;

  /// No description provided for @notificationsNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsNoNotifications;

  /// No description provided for @notificationsNoNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t received\nany notifications yet'**
  String get notificationsNoNotificationsMessage;

  /// No description provided for @notificationsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get notificationsLoading;

  /// No description provided for @notificationsLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get notificationsLoadingMore;

  /// No description provided for @notificationsPaginationInfo.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} notifications'**
  String notificationsPaginationInfo(int current, int total);

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'I have arrived'**
  String get arrivedAtPickup;

  /// No description provided for @startingRide.
  ///
  /// In en, this message translates to:
  /// **'Start the ride'**
  String get startingRide;

  /// No description provided for @finishRide.
  ///
  /// In en, this message translates to:
  /// **'Finish the ride'**
  String get finishRide;

  /// No description provided for @coming.
  ///
  /// In en, this message translates to:
  /// **'I\'m coming!'**
  String get coming;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @etaMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String etaMinutes(int minutes);

  /// No description provided for @rideInitilisation.
  ///
  /// In en, this message translates to:
  /// **'Initializing ride...'**
  String get rideInitilisation;

  /// No description provided for @sendEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Send evaluation'**
  String get sendEvaluation;

  /// No description provided for @rateUser.
  ///
  /// In en, this message translates to:
  /// **'Rate {user}'**
  String rateUser(String user);

  /// No description provided for @thankYouForYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForYourFeedback;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get cancelRide;

  /// No description provided for @confirmationSentToPassenger.
  ///
  /// In en, this message translates to:
  /// **'Confirmation sent to passenger'**
  String get confirmationSentToPassenger;

  /// No description provided for @rideStarted.
  ///
  /// In en, this message translates to:
  /// **'Ride started - Heading to: Destination'**
  String get rideStarted;

  /// No description provided for @phoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNotAvailable;

  /// No description provided for @cannotOpenPhoneApp.
  ///
  /// In en, this message translates to:
  /// **'Cannot open phone app'**
  String get cannotOpenPhoneApp;

  /// No description provided for @userInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User information not available'**
  String get userInfoNotAvailable;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location not available yet'**
  String get locationNotAvailable;

  /// No description provided for @cannotOpenNavigation.
  ///
  /// In en, this message translates to:
  /// **'Cannot open navigation app'**
  String get cannotOpenNavigation;

  /// No description provided for @rideInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Ride information not available'**
  String get rideInfoNotAvailable;

  /// No description provided for @rideCancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled'**
  String get rideCancelled;

  /// No description provided for @cancellationError.
  ///
  /// In en, this message translates to:
  /// **'Error during cancellation'**
  String get cancellationError;

  /// No description provided for @ratingError.
  ///
  /// In en, this message translates to:
  /// **'Error submitting rating'**
  String get ratingError;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit app'**
  String get pressAgainToExit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
