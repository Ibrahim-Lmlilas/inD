// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SRR FRR';

  @override
  String get welcomeToSrrfrr => 'Welcome to SRR FRR';

  @override
  String get yourRideYourWay => 'Your ride, your way';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get connecting => 'Connecting...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get termsConditionsNotice =>
      'By continuing, you accept our Terms of Use and Privacy Policy';

  @override
  String get loginFailedMessage =>
      'Login failed. Please check your credentials and try again.';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterPhoneToReceiveOtp =>
      'Enter your phone number to receive a verification code via WhatsApp';

  @override
  String get sendCode => 'Send Code';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String enterCodeAndNewPassword(String phoneNumber) {
    return 'Enter the code sent to $phoneNumber and your new password';
  }

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordRequirements => 'Password Requirements';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get oneUppercaseLetter => 'One uppercase letter';

  @override
  String get oneLowercaseLetter => 'One lowercase letter';

  @override
  String get oneNumber => 'One number';

  @override
  String get oneSpecialCharacter => 'One special character (!@#\$%^&*)';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get passwordReset => 'Password Reset!';

  @override
  String get passwordResetSuccess =>
      'Your password has been reset successfully.\nYou can now login with your new password.';

  @override
  String get dontForgetNewPassword => 'Don\'t forget your new password';

  @override
  String get otpSentViaWhatsApp => 'Code sent via WhatsApp';

  @override
  String get incorrectCode => 'Incorrect code';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get fillYourInformation => 'Fill in your information to get started';

  @override
  String get firstName => 'First Name';

  @override
  String get enterYourFirstName => 'Enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterYourLastName => 'Enter your last name';

  @override
  String get gender => 'Gender';

  @override
  String get selectYourGender => 'Select your gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get email => 'Email (optional)';

  @override
  String get emailPlaceholder => 'example@email.com';

  @override
  String get minimumPassword => 'Minimum 8 characters';

  @override
  String get retypePassword => 'Retype your password';

  @override
  String get iAcceptThe => 'I accept the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get continueButton => 'Continue';

  @override
  String get touchToAddPhoto => 'Tap to add a photo';

  @override
  String get touchToChangePhoto => 'Tap to change';

  @override
  String get chooseYourInterface => 'Choose Your Interface';

  @override
  String get srrfrrRegular => 'SRR FRR';

  @override
  String get standardInterface => 'Standard interface';

  @override
  String get srrfrrLadies => 'SRR FRR Ladies';

  @override
  String get femaleDriversOnly => 'Female drivers only';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get pleaseAcceptTerms => 'You must accept the terms of use';

  @override
  String get pleaseChooseInterface => 'Please choose your interface';

  @override
  String get pleaseFillAllFields => 'Please fill all fields correctly';

  @override
  String get verifyYourNumber => 'Verify Your Number';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Enter the 6-digit code sent to $phoneNumber';
  }

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get codeSentSuccessfully => 'Verification code sent successfully';

  @override
  String get aNewCodeHasBeenSent => 'A new code has been sent';

  @override
  String get registrationSuccess => 'Registration Successful!';

  @override
  String welcome(String name) {
    return 'Welcome $name!';
  }

  @override
  String get yourAccountIsReady => 'Your account is ready';

  @override
  String get startTraveling => 'Start Traveling';

  @override
  String get verifiedDrivers => 'Verified drivers';

  @override
  String get secureEnvironment => 'Secure environment';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get wideChoiceOfRides => 'Wide choice of rides';

  @override
  String get securePayments => 'Secure payments';

  @override
  String get verifiedFemaleDrivers => 'Verified female drivers';

  @override
  String get changePassword => 'Change Password';

  @override
  String get secureYourAccount => 'Secure your account with a strong password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get save => 'Save';

  @override
  String get currentPasswordRequired => 'Current password required';

  @override
  String get newPasswordRequired => 'New password required';

  @override
  String get confirmationRequired => 'Confirmation required';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get newPasswordMustBeDifferent => 'New password must be different';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get errorChangingPassword => 'Error changing password';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String registrationProgress(int current, int total) {
    return 'Registration progress: step $current of $total';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appearanceAndInterface => 'Appearance and Interface';

  @override
  String get apply => 'Apply';

  @override
  String get languageChangeInfo =>
      'The app will update immediately to reflect the new language';

  @override
  String get language => 'Language';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get interfaceType => 'Interface Type';

  @override
  String get regularInterface => 'SrrFrr Regular Interface';

  @override
  String get ladiesInterface => 'SrrFrr Ladies Interface';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get receiveAllNotifications => 'Receive all notifications';

  @override
  String get sound => 'Sound';

  @override
  String get notificationSounds => 'Notification sounds';

  @override
  String get vibration => 'Vibration';

  @override
  String get notificationVibration => 'Notification vibration';

  @override
  String get dataAndPrivacy => 'Data and Privacy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get notificationsSaved => 'Notification settings saved';

  @override
  String get savingError => 'Error saving';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get notificationPermissionExplanation =>
      'SrrFrr needs notification permission to send you important updates about your rides, driver status, and messages.';

  @override
  String get mustEnableInSettings =>
      'You must enable notifications in system settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String featureComingSoon(String feature) {
    return '$feature - Coming Soon';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get actionIsIrreversible => 'This action is irreversible';

  @override
  String get accountDeletionWarning =>
      'Your account will be permanently deleted after a 30-day grace period. All your personal data will be anonymized.';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get whyDeleteAccount => 'Why are you deleting your account?';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get iUnderstandIrreversible =>
      'I understand that this action is irreversible';

  @override
  String get delete => 'Delete';

  @override
  String get deleting => 'Deleting...';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully.';

  @override
  String get accountDeletionFailed => 'Account deletion failed';

  @override
  String get errorOccurredPleaseTryAgain =>
      'An error occurred. Please try again.';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get selectLanguage => 'Select your preferred language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get systemLanguage => 'System Language';

  @override
  String get account => 'Account';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get activity => 'Activity';

  @override
  String get yourAlertsAndMessages => 'Your alerts and messages';

  @override
  String get history => 'History';

  @override
  String get completedRides => 'Completed rides';

  @override
  String get loyaltyProgram => 'Loyalty Program';

  @override
  String get pointsAndRewards => 'Points and rewards';

  @override
  String get appPreferences => 'App preferences';

  @override
  String get help => 'Help';

  @override
  String get supportAndFaq => 'Support and FAQ';

  @override
  String get about => 'About';

  @override
  String get versionAndInformation => 'Version and information';

  @override
  String get driverMode => 'Driver Mode';

  @override
  String get switching => 'Switching...';

  @override
  String get departure => 'Departure';

  @override
  String get yourCurrentPosition => 'Your current position';

  @override
  String get arrival => 'Arrival';

  @override
  String get whereAreYouGoing => 'Where are you going?';

  @override
  String get selectDepartureAndDestination =>
      'Please select departure and destination';

  @override
  String get sendingRequest => 'Sending request...';

  @override
  String get locating => 'Locating...';

  @override
  String get locationError => 'Location error';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get destination => 'Destination';

  @override
  String get searchPlace => 'Search a place';

  @override
  String get selectOnMap => 'Select on map';

  @override
  String get searchAddress => 'Search an address';

  @override
  String get orSelectOnMap => 'or select on the map';

  @override
  String get loading => 'Loading...';

  @override
  String get selectPickupLocation => 'Select pickup location';

  @override
  String get selectDestinationLocation => 'Select destination location';

  @override
  String get tapMapOrMoveMarker => 'Tap the map or move the marker';

  @override
  String get zoomForPrecision => 'Zoom for more precision';

  @override
  String get retrievingAddress => 'Retrieving address...';

  @override
  String get confirm => 'Confirm';

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get rideType => 'Ride Type';

  @override
  String get autoDetected => 'Auto-detected';

  @override
  String get cityToCity => 'City to City';

  @override
  String get inCity => 'In City';

  @override
  String intercityTripDetected(String pickupCity, String destinationCity) {
    return 'Intercity trip detected: $pickupCity → $destinationCity';
  }

  @override
  String get numberOfSeats => 'Number of seats';

  @override
  String seatsSelected(int count, String plural) {
    return '$count passenger$plural selected';
  }

  @override
  String get proposePrice => 'Propose a price';

  @override
  String minimumPrice(int price) {
    return 'Minimum price: $price DH';
  }

  @override
  String get confirmRide => 'Confirm Ride';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get cashPayment => 'Cash payment to driver';

  @override
  String get freeRide => 'Free Ride';

  @override
  String get freeRideWithPoints => 'Free ride with your points';

  @override
  String insufficientPoints(int required, int available) {
    return 'Insufficient: ${required}pts required, you have ${available}pts';
  }

  @override
  String youHavePoints(int points) {
    return 'You have ${points}pts (1pt = 1DH)';
  }

  @override
  String get freeRideTitle => 'Free ride';

  @override
  String get availablePoints => 'Available points';

  @override
  String get afterThisRide => 'After this ride';

  @override
  String pointsWillBeDeducted(int points) {
    return '$points points will be deducted (1pt = 1DH)';
  }

  @override
  String get driverOffers => 'Driver Offers';

  @override
  String driversAvailable(int count, String plural) {
    return '$count driver$plural available';
  }

  @override
  String get adjustYourOffer => 'Adjust your offer';

  @override
  String get applyPrice => 'Apply Price';

  @override
  String get waitingForDriverOffers => 'Waiting for driver offers...';

  @override
  String canAdjustPriceIn(int seconds) {
    return 'You can adjust the price in ${seconds}s if no offers';
  }

  @override
  String get canAdjustPriceNow => 'You can now adjust your price';

  @override
  String get searchingDrivers => 'Searching for drivers';

  @override
  String get nearbyDriversWillAppear => 'Nearby drivers will appear here';

  @override
  String get offersExpireAfter60s => 'Offers expire after 60 seconds';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get rides => 'rides';

  @override
  String get counterOffer => 'Counter-offer';

  @override
  String get initialPrice => 'Initial price';

  @override
  String get driverCounterOffer => 'Driver counter-offer';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get confirmingRide => 'Confirming ride...';

  @override
  String get rideConfirmationTimeout =>
      'Ride confirmation timeout. Please try again.';

  @override
  String get errorAcceptingDriver => 'Error accepting driver';

  @override
  String get driverDeclined => 'Driver declined';

  @override
  String get offerExpired => 'Offer expired';

  @override
  String get requestCancelled => 'Ride request has been cancelled.';

  @override
  String get errorCancellingRequest => 'Error cancelling request';

  @override
  String newOfferSent(int price) {
    return 'New offer sent: $price DH';
  }

  @override
  String get errorSendingOffer => 'Error sending offer';

  @override
  String get noOffersAdjustPrice => 'No offers yet. Try adjusting your price!';

  @override
  String get useLastOtpSent => 'Please use the OTP code that was sent earlier';

  @override
  String waitBeforeResending(int seconds) {
    return 'Please wait $seconds seconds before requesting a new code';
  }

  @override
  String get pleaseWaitBeforeResending =>
      'Please wait before requesting a new code';

  @override
  String get tooManyAttempts => 'Too many attempts. Please try again later';

  @override
  String get invalidPhoneNumber => 'Invalid phone number format';

  @override
  String get networkError => 'Network error. Please check your connection';

  @override
  String get failedToSendOtp => 'Failed to send verification code';

  @override
  String get otpSendIssue =>
      'There was an issue sending the code. You can try resending it';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updatePersonalInfo => 'Update your personal information';

  @override
  String get viewPersonalInfo => 'Your personal information';

  @override
  String get firstNameHint => 'Ex: Mohamed';

  @override
  String get lastNameHint => 'Ex: Alami';

  @override
  String get firstNameRequired => 'First name required';

  @override
  String get lastNameRequired => 'Last name required';

  @override
  String nameTooShort(String field) {
    return '$field too short (minimum 2 characters)';
  }

  @override
  String nameTooLong(String field) {
    return '$field too long (maximum 50 characters)';
  }

  @override
  String get invalidCharacters => 'Invalid characters';

  @override
  String get noChangesDetected => 'No changes detected';

  @override
  String get infoForReservations =>
      'This information will be used for your reservations and verifications';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get cameraAccessNeeded =>
      'Camera access is needed to change your profile photo. Please allow access in settings.';

  @override
  String get galleryAccessNeeded =>
      'Gallery access is needed to change your profile photo. Please allow access in settings.';

  @override
  String get errorSelectingImage => 'Error selecting image';

  @override
  String get profilePhotoUpdated => 'Profile photo updated successfully';

  @override
  String get profilePhotoUpdateFailed => 'Failed to update profile photo';

  @override
  String get errorUpdatingPhoto => 'Error updating photo';

  @override
  String get editPassword => 'Edit Password';

  @override
  String get passwordRequirementsMustContain => 'Password must contain:';

  @override
  String get editPhone => 'Edit Phone';

  @override
  String get editPhoneNumber => 'Edit phone number';

  @override
  String get enterNewPhoneAndPassword =>
      'Enter your new phone number and current password';

  @override
  String get newPhoneNumber => 'New phone number';

  @override
  String get phoneNumberRequired => 'Phone number required';

  @override
  String get invalidPhoneFormat => 'Invalid format (ex: 0612345678)';

  @override
  String get verificationCodeWillBeSent =>
      'A verification code will be sent to this number';

  @override
  String enterCodeSentToPhone(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String get otpCode => 'OTP Code';

  @override
  String codeExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get verify => 'Verify';

  @override
  String get phoneNumberChanged => 'Phone number changed successfully';

  @override
  String get invalidOtpCode => 'Invalid OTP code';

  @override
  String get otpSent => 'OTP code sent';

  @override
  String get phoneNumberSameAsCurrent =>
      'The new number is the same as the current number';

  @override
  String get standardInterfaceDescription =>
      'Complete interface with all available drivers';

  @override
  String get ladiesInterfaceDescription =>
      'Dedicated interface with female drivers only for more comfort';

  @override
  String get aboutLadiesInterface => 'About Ladies Interface';

  @override
  String get ladiesInterfaceInfo =>
      'This option allows you to travel only with certified female drivers. You can change the interface at any time.';

  @override
  String get interfaceUpdated => 'Interface updated successfully';

  @override
  String get errorUpdatingInterface => 'Error updating interface';

  @override
  String get ladiesInterfaceBadge => 'Ladies Interface';

  @override
  String get driverModeBadge => 'Driver Mode';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Confirm logout';

  @override
  String get enterPasswordToConfirm =>
      'Please enter your password to confirm logout:';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get logoutError => 'Logout error';

  @override
  String get editProfileInfo => 'Edit profile';

  @override
  String get firstNameLastName => 'First name, last name';

  @override
  String get accountSecurity => 'Account security';

  @override
  String get changePhoneNumber => 'Change phone number';

  @override
  String get user => 'User';

  @override
  String get camera => 'camera';

  @override
  String get gallery => 'gallery';

  @override
  String get continue_ => 'Continue';

  @override
  String get secureAccountWithStrongPassword =>
      'Secure your account with a strong password';

  @override
  String get passwordMinLength => 'At least 8 characters';

  @override
  String get passwordNeedsUppercase => 'At least one uppercase letter';

  @override
  String get passwordNeedsLowercase => 'At least one lowercase letter';

  @override
  String get passwordNeedsNumber => 'At least one number';

  @override
  String get passwordNeedsSpecialChar => 'At least one special character';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get passwordChangeFailed => 'Error changing password';

  @override
  String get confirmPasswordRequired => 'Password confirmation required';

  @override
  String get passwordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get passwordReqMinChars => 'At least 8 characters';

  @override
  String get passwordReqUppercase => 'One uppercase letter';

  @override
  String get passwordReqLowercase => 'One lowercase letter';

  @override
  String get passwordReqNumber => 'One number';

  @override
  String get passwordReqSpecialChar => 'One special character (!@#\$%^&*)';

  @override
  String get otpCodeRequired => 'OTP code required';

  @override
  String get otpCodeMustBe6Digits => 'Code must be 6 digits';

  @override
  String get errorRequestingOtp => 'Error requesting OTP';

  @override
  String get profileUpdateFailed => 'Error updating profile';

  @override
  String get locatingYourPosition => 'Locating your position...';

  @override
  String get continueToOptions => 'Continue';

  @override
  String get errorLocationService => 'Location service error';

  @override
  String get pleaseSelectBothLocations =>
      'Please select departure and destination';

  @override
  String get unableToCalculateDistance => 'Unable to calculate trip distance';

  @override
  String get chooseRideType => 'Choose a ride type';

  @override
  String minimumPriceIs(int price) {
    return 'Minimum price: $price DH';
  }

  @override
  String insufficientPointsForFreeRide(int requiredPoints, int available) {
    return 'Insufficient points: ${requiredPoints}pts required, you have ${available}pts';
  }

  @override
  String get connectingToServer => 'Connecting to server...';

  @override
  String get unableToConnectToServer => 'Unable to connect to server';

  @override
  String selectingLocationFor(String target) {
    return 'Selecting location for $target';
  }

  @override
  String get tapOrDragMarker => 'Tap the map or drag the marker';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get selectingPickup => 'departure';

  @override
  String get selectingDestination => 'destination';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get carLabel => 'Car';

  @override
  String get carSubtitle => 'Standard vehicle';

  @override
  String get motorcycleLabel => 'Motorcycle';

  @override
  String get motorcycleSubtitle => 'Two-wheeled vehicle';

  @override
  String get truckLabel => 'Truck';

  @override
  String get truckSubtitle => 'Commercial vehicle';

  @override
  String get newApplication => 'New Application';

  @override
  String get driverRegistration => 'Driver Registration';

  @override
  String get cinInformationTitle => 'CIN Information';

  @override
  String get cinInformationSubtitle => 'Please provide your identity documents';

  @override
  String get cinRectoPhoto => 'CIN Front Photo';

  @override
  String get cinVersoPhoto => 'CIN Back Photo';

  @override
  String get selfieWithCIN => 'Selfie with CIN';

  @override
  String get cinCode => 'CIN Code';

  @override
  String get cinCodeHint => 'Ex: AB123456';

  @override
  String get expirationDate => 'Expiration Date';

  @override
  String get selectDate => 'Select a date';

  @override
  String get vehicleInformationTitle => 'Vehicle Information';

  @override
  String get vehicleInformationSubtitle => 'Details of your vehicle';

  @override
  String get vehiclePhoto => 'Vehicle Photo';

  @override
  String get vehicleRegistrationRecto => 'Vehicle Registration Front';

  @override
  String get vehicleRegistrationVerso => 'Vehicle Registration Back';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get registrationNumberHint => 'Ex: 12345-A-67';

  @override
  String get brand => 'Brand';

  @override
  String get brandHint => 'Ex: Toyota';

  @override
  String get model => 'Model';

  @override
  String get modelHint => 'Ex: Corolla';

  @override
  String get color => 'Color';

  @override
  String get colorHint => 'Ex: White';

  @override
  String get productionYear => 'Production Year';

  @override
  String get productionYearHint => 'Ex: 2020';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewSubtitle =>
      'Please verify your information before submitting';

  @override
  String get cinInformationSection => 'CIN Information';

  @override
  String get vehicleInformationSection => 'Vehicle Information';

  @override
  String get uploaded => '✓ Uploaded';

  @override
  String get vehicleTypeLabel => 'Type';

  @override
  String get registrationNumberLabel => 'Registration';

  @override
  String get brandLabel => 'Brand';

  @override
  String get modelLabel => 'Model';

  @override
  String get colorLabel => 'Color';

  @override
  String get yearLabel => 'Year';

  @override
  String get vehiclePhotoLabel => 'Vehicle Photo';

  @override
  String get vehicleRegistrationRectoLabel => 'Registration Front';

  @override
  String get vehicleRegistrationVersoLabel => 'Registration Back';

  @override
  String get verificationNotice =>
      'Your application will be verified within 24-48 hours';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get tapToTakePhoto => 'Tap to take a photo';

  @override
  String get cinCodeLabel => 'CIN Code';

  @override
  String get expirationDateLabel => 'Expiration Date';

  @override
  String get cinRectoLabel => 'CIN Front';

  @override
  String get cinVersoLabel => 'CIN Back';

  @override
  String get selfieLabel => 'Selfie';

  @override
  String get submitApplication => 'Submit Application';

  @override
  String get submittedSuccessfully => 'Application submitted successfully';

  @override
  String get submissionError => 'Error during submission';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get filters => 'Filters';

  @override
  String get totalRides => 'Rides';

  @override
  String get totalAmount => 'Total spent';

  @override
  String ridesLoaded(int loaded, int total) {
    return '$loaded of $total rides loaded';
  }

  @override
  String get statusAll => 'All';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusStarted => 'Started';

  @override
  String get paymentAll => 'All';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentWallet => 'Wallet';

  @override
  String get paymentCreditCard => 'Credit Card';

  @override
  String get paymentLoyaltyPoints => 'Loyalty Points';

  @override
  String get paymentFreeRide => 'Free Ride';

  @override
  String get vehicleAll => 'All';

  @override
  String get vehicleCar => 'Car';

  @override
  String get vehicleMotorcycle => 'Motorcycle';

  @override
  String get vehicleTruck => 'Truck';

  @override
  String get sortPriceHighToLow => 'Price (high to low)';

  @override
  String get sortPriceLowToHigh => 'Price (low to high)';

  @override
  String get sortDistance => 'Distance';

  @override
  String get viewDetails => 'View details';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get rateDriver => 'Rate driver';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get thankYouForRating => 'Thank you for your rating!';

  @override
  String get complaintSent => 'Complaint sent successfully';

  @override
  String get loadingError => 'Loading error';

  @override
  String get connectionError => 'Connection error';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noRidesTitle => 'No rides found';

  @override
  String get noRidesDescription => 'Adjust your filters or check back later';

  @override
  String get clearAllFilters => 'Clear all filters';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get searchDriver => 'Search for a driver...';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get priceRange => 'Price';

  @override
  String get minPrice => 'Min';

  @override
  String get maxPrice => 'Max';

  @override
  String get status => 'Status';

  @override
  String get payment => 'Payment';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get driver => 'Driver';

  @override
  String get date => 'Date';

  @override
  String get price => 'Price';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get fare => 'Fare';

  @override
  String get passengers => 'Passengers';

  @override
  String get driverRating => 'Driver rating';

  @override
  String get yourRating => 'Your rating';

  @override
  String get notRated => 'Not rated';

  @override
  String get rated => 'Rated';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get accepted => 'Accepted';

  @override
  String get started => 'In progress';

  @override
  String get wallet => 'Wallet';

  @override
  String get creditCard => 'Credit card';

  @override
  String get loyaltyPoints => 'Loyalty points';

  @override
  String get car => 'Car';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get truck => 'Truck';

  @override
  String get totalRidesLabel => 'Rides';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get statusLabel => 'Status';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get sortByLabel => 'Sort by';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get paymentCard => 'Card';

  @override
  String get vehicleStandard => 'Standard';

  @override
  String get vehiclePremium => 'Premium';

  @override
  String get vehicleLadiesOnly => 'Ladies-only';

  @override
  String get sortDateNewestFirst => 'Date (newest first)';

  @override
  String get sortDateOldestFirst => 'Date (oldest first)';

  @override
  String get viewTripLocation => 'Trip Location';

  @override
  String get passengerLabel => 'Passenger';

  @override
  String get driverLabel => 'Driver';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get fareDetails => 'Fare Details';

  @override
  String get totalLabel => 'Total';

  @override
  String get rateThisTrip => 'Rate this trip';

  @override
  String get rateButton => 'Rate';

  @override
  String get complaintButton => 'Complaint';

  @override
  String get statusCompletedBadge => 'Completed';

  @override
  String get statusCancelledBadge => 'Cancelled';

  @override
  String get statusInProgressBadge => 'In Progress';

  @override
  String get noTripsFound => 'No trips found';

  @override
  String get tripsWillAppearHere => 'Your trips will appear here';

  @override
  String get passengerDefault => 'Passenger';

  @override
  String get driverDefault => 'Driver';

  @override
  String get filtersAndSort => 'Filters and Sort';

  @override
  String activeFilters(int count) {
    return '$count active filter(s)';
  }

  @override
  String get noActiveFilters => 'No active filters';

  @override
  String get driverNameHint => 'Driver name';

  @override
  String get dateRange => 'Date Range';

  @override
  String get allPriceRanges => 'All price ranges';

  @override
  String get addPriceFilter => 'Add price filter';

  @override
  String get statusFilter => 'Status';

  @override
  String get allStatus => 'All';

  @override
  String get completedStatus => 'Completed';

  @override
  String get cancelledStatus => 'Cancelled';

  @override
  String get paymentFilter => 'Payment';

  @override
  String get allPayment => 'All';

  @override
  String get walletPayment => 'Wallet';

  @override
  String get creditCardPayment => 'Credit card';

  @override
  String get loyaltyPointsPayment => 'Loyalty points';

  @override
  String get freeRidePayment => 'Free ride';

  @override
  String get vehicleFilter => 'Vehicle';

  @override
  String get allVehicles => 'All';

  @override
  String get carVehicle => 'Car';

  @override
  String get motorcycleVehicle => 'Motorcycle';

  @override
  String get truckVehicle => 'Truck';

  @override
  String get sortBy => 'Sort by';

  @override
  String get resetAllFilters => 'Reset all filters';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get points => 'points';

  @override
  String progressToNextLevel(String nextLevel) {
    return 'Progress to $nextLevel';
  }

  @override
  String needPointsToUnlock(int pointsNeeded, String nextLevel) {
    return 'Need $pointsNeeded more points to unlock $nextLevel benefits';
  }

  @override
  String get earnPoints => 'Earn Points';

  @override
  String get earnPointsByRide => 'Points for each ride';

  @override
  String get earnPointsByReferral => 'Referral points';

  @override
  String get earnPointsByRating => 'Points for rating';

  @override
  String get referAFriend => 'Refer a Friend';

  @override
  String get shareAndEarnPoints => 'Share and earn points';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get allTransactionsLoaded => 'All transactions loaded';

  @override
  String get rideCompleted => 'Ride completed';

  @override
  String get referralBonus => 'Referral bonus';

  @override
  String get ratingBonus => 'Rating bonus';

  @override
  String get pointsUsed => 'Points used';

  @override
  String get levelBronze => 'Bronze';

  @override
  String get levelSilver => 'Silver';

  @override
  String get levelGold => 'Gold';

  @override
  String get levelPlatinum => 'Platinum';

  @override
  String get levelDiamond => 'Diamond';

  @override
  String get dataRefreshed => 'Data refreshed';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get errorRefreshingData => 'Error refreshing data';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get pleaseSelectOption => 'Please select an option';

  @override
  String get ratePassenger => 'Rate passenger';

  @override
  String howWasYourExperience(String name) {
    return 'How was your experience with $name?';
  }

  @override
  String get selectCategory => 'Select a category:';

  @override
  String get noOptionsAvailable => 'No options available';

  @override
  String get send => 'Send';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter a phone number';

  @override
  String get invitationRegistered =>
      'Invitation registered! Share the link with your friend.';

  @override
  String get phoneNotEligible => 'This number is not eligible for referral';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get errorCopyingLink => 'Error copying link.';

  @override
  String get linkSharedSuccess => 'Link shared successfully!';

  @override
  String get errorSharing => 'Error sharing.';

  @override
  String get earnPointsPerFriend => 'Earn 50 points per friend';

  @override
  String get referralInfoMessage =>
      'Enter your friend\'s number to register it, then share the link with them.';

  @override
  String get verifying => 'Verifying...';

  @override
  String get savePhoneNumber => 'Save phone number';

  @override
  String get or => 'OR';

  @override
  String get referralLink => 'Referral link';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String referralShareMessage(String link) {
    return '🎉 Join me on SRRFRR!\n\nI use SRRFRR for my trips and I think you might be interested too!\n\n🎁 Download the app and get 50 welcome points!\n🚗 It\'s simple, fast and secure\n\nDownload now: $link\n\nSee you soon on SRRFRR! 🚙';
  }

  @override
  String get referralInvitationSubject => 'SRRFRR Invitation';

  @override
  String get faq => 'FAQ';

  @override
  String get contact => 'Contact';

  @override
  String get searchInFaq => 'Search in FAQ...';

  @override
  String get contactUs => 'Contact us';

  @override
  String get ourTeamIsHereToHelp => 'Our team is here to help you';

  @override
  String get hours => 'Hours';

  @override
  String get businessHours => 'Mon-Fri: 9AM-6PM';

  @override
  String get sendComplaint => 'Send a complaint';

  @override
  String get describeYourProblem =>
      'Describe your problem and our team will respond quickly';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryOtherKeywords => 'Try other keywords';

  @override
  String get pleaseDescribeProblem => 'Please describe your problem';

  @override
  String get provideMoreDetails =>
      'Please provide more details (minimum 10 characters)';

  @override
  String get category => 'Category';

  @override
  String get technicalIssue => 'Technical issue';

  @override
  String get accountingIssue => 'Accounting issue';

  @override
  String get safetyIssue => 'Safety issue';

  @override
  String get drivingIssue => 'Driving issue';

  @override
  String get other => 'Other';

  @override
  String get description => 'Description';

  @override
  String get describeYourProblemInDetail =>
      'Describe your problem in detail. Our team will get back to you as soon as possible.';

  @override
  String trajectoryRef(String ref) {
    return 'Trajectory reference #$ref';
  }

  @override
  String get sendReclamation => 'Send reclamation';

  @override
  String get describeProblem => 'Describe your problem';

  @override
  String get minCharacters => 'Minimum 10 characters required';

  @override
  String get exampleReclamation =>
      'Example: I had an issue with my last trip where the driver took a longer route than necessary, which increased the cost of the ride. I would like this to be reviewed and for measures to be taken to prevent this from happening again.';

  @override
  String get sendComplaintButton => 'Send complaint';

  @override
  String get faqAccountTitle => 'Account and Registration';

  @override
  String get faqAccount1Q => 'How do I create an account?';

  @override
  String get faqAccount1A =>
      'To create an account, download the SRRFRR app, enter your phone number, verify the OTP code sent by SMS, then complete your profile with your personal information.';

  @override
  String get faqAccount2Q =>
      'Can I use the same account as passenger and driver?';

  @override
  String get faqAccount2A =>
      'Yes! You can switch between passenger and driver modes in the app settings. To become a driver, you must submit an application with your documents.';

  @override
  String get faqAccount3Q => 'How do I change my phone number?';

  @override
  String get faqAccount3A =>
      'Go to Settings > Profile > Edit Phone Number. You will need to verify the new number with an OTP code.';

  @override
  String get faqBookingTitle => 'Booking Rides';

  @override
  String get faqBooking1Q => 'How do I book a ride?';

  @override
  String get faqBooking1A =>
      'On the home screen, enter your destination, choose the vehicle type, check the estimated price, then tap \'Confirm Request\'. A driver will accept your request in a few moments.';

  @override
  String get faqBooking2Q => 'Can I cancel a ride?';

  @override
  String get faqBooking2A =>
      'Yes, you can cancel a ride before a driver accepts without fees. After acceptance, cancellation fees may apply.';

  @override
  String get faqBooking3Q => 'How does Ladies-only mode work?';

  @override
  String get faqBooking3A =>
      'Ladies-only mode allows female passengers to be matched only with female drivers. Enable this option in your profile settings.';

  @override
  String get faqPaymentTitle => 'Payment';

  @override
  String get faqPayment1Q => 'What payment methods are accepted?';

  @override
  String get faqPayment1A =>
      'We accept cash and credit card payments. You can choose your preferred payment method when booking.';

  @override
  String get faqPayment2Q => 'How do loyalty points work?';

  @override
  String get faqPayment2A =>
      'You earn points with each completed ride, when referring friends, and by using the app regularly. These points can be redeemed for discounts on your rides.';

  @override
  String get faqPayment3Q => 'Can I get a receipt for my ride?';

  @override
  String get faqPayment3A =>
      'Yes, all your receipts are available in the ride history. You can download them or receive them by email.';

  @override
  String get faqSafetyTitle => 'Safety';

  @override
  String get faqSafety1Q => 'How does SRRFRR ensure my safety?';

  @override
  String get faqSafety1A =>
      'All drivers are verified with their official documents. You can share your ride in real-time with loved ones and report any issues via the app.';

  @override
  String get faqSafety2Q =>
      'What should I do if there\'s a problem during a ride?';

  @override
  String get faqSafety2A =>
      'Use the \'Emergency\' button in the app to immediately contact our security team. You can also call authorities directly if necessary.';

  @override
  String get faqSafety3Q => 'Is my personal data protected?';

  @override
  String get faqSafety3A =>
      'Yes, we use bank-level encryption to protect all your personal and financial data. We never share your information with third parties.';

  @override
  String get faqDriverTitle => 'Becoming a Driver';

  @override
  String get faqDriver1Q => 'What are the requirements to become a driver?';

  @override
  String get faqDriver1A =>
      'You must have a valid driver\'s license, ID card, a vehicle in good condition with valid registration, and be at least 21 years old.';

  @override
  String get faqDriver2Q => 'How long does driver account validation take?';

  @override
  String get faqDriver2A =>
      'Document verification usually takes 24 to 48 hours. You will receive a notification once your account is validated.';

  @override
  String get faqDriver3Q => 'How are my earnings calculated?';

  @override
  String get faqDriver3A =>
      'Your earnings are calculated based on distance traveled, trip time, and current demand. SRRFRR takes a 15% commission on each ride.';

  @override
  String get faqDriver4Q => 'When can I withdraw my earnings?';

  @override
  String get faqDriver4A =>
      'You can withdraw your earnings anytime via your driver wallet. Withdrawals are processed within 1 to 3 business days.';

  @override
  String get faqTechTitle => 'Technical Issues';

  @override
  String get faqTech1Q => 'The app can\'t find my location';

  @override
  String get faqTech1A =>
      'Check that you have enabled location services for the app in your phone settings. Also ensure you have an active internet connection.';

  @override
  String get faqTech2Q => 'I\'m not receiving the OTP code';

  @override
  String get faqTech2A =>
      'Verify that you entered the correct phone number and have network coverage. If the problem persists, use the \'Resend code\' option after 60 seconds.';

  @override
  String get faqTech3Q => 'The app closes unexpectedly';

  @override
  String get faqTech3A =>
      'Try updating the app to the latest version, restart your phone, and ensure you have enough storage space available.';

  @override
  String get walletBalanceTransactions => 'Balance and transactions';

  @override
  String get manageSubscription => 'Manage my subscription';

  @override
  String get subscription => 'Subscription';

  @override
  String get passengerMode => 'Passenger Mode';

  @override
  String get ladiesInterfaceDriverBadge => 'SRR FRR Ladies Driver';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get notRegisteredTitle => 'Become a Driver';

  @override
  String get notRegisteredDescription =>
      'Turn your trips into income and join our community of drivers';

  @override
  String get startRegistration => 'Start Registration';

  @override
  String get pendingVerificationTitle => 'Under Verification';

  @override
  String get pendingVerificationDescription =>
      'Our team is reviewing your application.\nYou will receive a notification once validated';

  @override
  String get verificationTimeframe =>
      'Verification usually takes 24 to 48 business hours';

  @override
  String get processingTime => 'Processing Time';

  @override
  String get returnHome => 'Return to home';

  @override
  String get validatedTitle => 'Congratulations! 🎉';

  @override
  String get validatedDescription =>
      'Your driver account\nhas been successfully validated';

  @override
  String get welcomeDrivers => 'Welcome among the drivers';

  @override
  String get welcomeDriversDescription =>
      'You are now a verified SRR FRR driver and can start accepting rides';

  @override
  String get verifiedStatus => 'Verified status';

  @override
  String get verifiedBadge => 'Certified driver badge';

  @override
  String get flexibleIncome => 'Flexible income';

  @override
  String get flexibleIncomeDesc => 'Earn according to your availability';

  @override
  String get insuredProtection => 'Insured protection';

  @override
  String get insuredProtectionDesc => 'Full coverage during rides';

  @override
  String get startDriving => 'Start driving';

  @override
  String get rejectedTitle => 'Application Not Approved';

  @override
  String get rejectedDescription =>
      'Your application needs adjustments.\nYou can submit a new application';

  @override
  String get rejectionReason => 'Reason for rejection';

  @override
  String get defaultRejectionReason =>
      'Incomplete or invalid documents. Please verify your information and submit compliant documents.';

  @override
  String get attractiveIncome => 'Attractive income';

  @override
  String get attractiveIncomeDesc =>
      'Set your rates and maximize your earnings';

  @override
  String get totalFreedom => 'Total freedom';

  @override
  String get totalFreedomDesc => 'Work according to your schedule';

  @override
  String get guaranteedSafety => 'Guaranteed safety';

  @override
  String get guaranteedSafetyDesc => 'Complete protection for every ride';

  @override
  String get verifyingStatus => 'Verifying status...';

  @override
  String get myVehicle => 'My Vehicle';

  @override
  String get statistics => 'Statistics';

  @override
  String get driverWallet => 'Wallet';

  @override
  String get totalRidesDriver => 'Total Rides';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get earnings => 'Earnings';

  @override
  String get historyDriver => 'History';

  @override
  String get supportDriver => 'Support';

  @override
  String get onlineMode => 'Online';

  @override
  String get offlineMode => 'Offline';

  @override
  String get readyToAccept => 'Ready to accept rides';

  @override
  String get activateToReceive => 'Activate to receive requests';

  @override
  String get goOnline => 'Go Online';

  @override
  String get goOffline => 'Go Offline';

  @override
  String get noRequests => 'No Requests';

  @override
  String get searchingNearby => 'Searching for nearby passengers...';

  @override
  String get notificationsActive => 'Notifications active';

  @override
  String get offlineStatus => 'Offline Mode';

  @override
  String get goOnlineToReceive => 'Go online to receive requests';

  @override
  String get activeRequests => 'Active Requests';

  @override
  String get counterOfferTitle => 'Send a counter-offer';

  @override
  String get passengerOffer => 'Passenger offer:';

  @override
  String get yourCounterOffer => 'Your counter-offer';

  @override
  String get enterYourPrice => 'Enter your price';

  @override
  String get fairPriceTip =>
      'Tip: Propose a fair price based on distance and time';

  @override
  String get sendOffer => 'Send offer';

  @override
  String get negotiateButton => 'Negotiate';

  @override
  String get refuseButton => 'Refuse';

  @override
  String get acceptRide => 'Accept ride';

  @override
  String get waitingForResponse => 'Waiting for Response';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds seconds remaining';
  }

  @override
  String get cancelOffer => 'Cancel Offer';

  @override
  String get registration => 'Registration';

  @override
  String get type => 'Type';

  @override
  String get year => 'Year';

  @override
  String get unknownAddress => 'Unknown Address';

  @override
  String get walletTitle => 'My Wallet';

  @override
  String get overviewTab => 'Overview';

  @override
  String get codesTab => 'Codes';

  @override
  String get historyTab => 'History';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get rechargeWallet => 'Recharge Wallet';

  @override
  String get monthDetails => 'Month Details';

  @override
  String get grossEarnings => 'Gross earnings';

  @override
  String get commissions => 'Commissions';

  @override
  String get netEarnings => 'Net earnings';

  @override
  String get costPerRide => 'Cost per ride';

  @override
  String get effectiveRate => 'Effective rate';

  @override
  String get thisWeek => 'This Week';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get retry => 'Retry';

  @override
  String get currencySymbol => 'DH';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get transactionTypeCredit => 'Credit';

  @override
  String get transactionTypeDebit => 'Debit';

  @override
  String get transactionTypeCommission => 'Commission';

  @override
  String get transactionTypeSubscription => 'Subscription';

  @override
  String get transactionTypeInit => 'Initialization';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get thisMonth => 'This Month';

  @override
  String get perRide => 'Per Ride';

  @override
  String get totalDebits => 'Total Debits';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get netThisMonth => 'Net this month';

  @override
  String get totalTransactions => 'Total transactions';

  @override
  String get generateNewCode => 'Generate New Code';

  @override
  String get activeCodes => 'Active Codes';

  @override
  String get expiredCodes => 'Expired Codes';

  @override
  String get noRechargeCodes => 'No recharge codes';

  @override
  String get generateCodeDescription =>
      'Generate a code to recharge\nyour wallet';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get deleteCodeTitle => 'Delete Code';

  @override
  String get deleteCodeConfirmation =>
      'Are you sure you want to delete this recharge code?';

  @override
  String get codeDeleted => 'Code deleted';

  @override
  String get active => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get generateCodeOption => 'Generate a Code';

  @override
  String get generateCodeSubtitle => 'Pay at agency with a code';

  @override
  String get creditCardOption => 'Credit Card';

  @override
  String get creditCardSubtitle => 'Secure online payment';

  @override
  String get amount => 'Amount (DH)';

  @override
  String get amountHint => 'Ex: 500';

  @override
  String get generateCodeInfo => 'Present this code at agency to make payment';

  @override
  String get generate => 'Generate';

  @override
  String get codeGenerated => 'Code Generated';

  @override
  String get presentCodeInfo =>
      'Present this code at agency to\nrecharge your wallet';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get cardPaymentTitle => 'Card Payment';

  @override
  String get securePaymentInfo => 'Secure payment • Immediate recharge';

  @override
  String get redirectingPayment => 'Redirecting to secure payment...';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get plansTab => 'Plans';

  @override
  String get noActiveSubscription => 'No active subscription';

  @override
  String get choosePlanPrompt => 'Choose a plan to unlock\nall benefits';

  @override
  String get ridesUsed => 'Rides used';

  @override
  String get coursesThisMonth => 'Courses this month';

  @override
  String get unlimited => 'UNLIMITED';

  @override
  String get subscriptionExpired => 'Subscription expired';

  @override
  String expiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String renewsInDays(int days) {
    return 'Renews in $days days';
  }

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get cancelSubscriptionDialog => 'Cancel subscription?';

  @override
  String cancelSubscriptionWarning(String planName) {
    return 'Your $planName subscription will be cancelled immediately';
  }

  @override
  String get subscriptionCancelled => 'Subscription cancelled';

  @override
  String get choosePlan => 'Choose a plan';

  @override
  String get popular => 'POPULAR';

  @override
  String get current => 'CURRENT';

  @override
  String get amountPerMonth => 'DH/month';

  @override
  String get activeSubscription => 'Active Subscription';

  @override
  String get changeToPlan => 'Change to this plan';

  @override
  String get chooseThisPlan => 'Choose this plan';

  @override
  String get takeAdvantage => '🎉 Take advantage of offer';

  @override
  String get notAvailable => 'Not available';

  @override
  String get confirmSubscription => 'Confirm subscription';

  @override
  String subscribeToPlan(String planName) {
    return 'You will subscribe to the $planName plan';
  }

  @override
  String get newPlan => 'New plan';

  @override
  String get changeSubscription => 'Change subscription';

  @override
  String switchFromTo(String fromPlan, String toPlan) {
    return 'Switch from $fromPlan to $toPlan';
  }

  @override
  String get changeEffectiveImmediately => 'Change effective immediately';

  @override
  String get subscriptionActivated => 'Subscription activated!';

  @override
  String get subscriptionChanged => 'Subscription changed!';

  @override
  String get noHistory => 'No history';

  @override
  String get historyPrompt => 'Your past subscriptions\nwill appear here';

  @override
  String itemsOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get period => 'Period';

  @override
  String get comparison => 'Comparison';

  @override
  String get commission => 'Commission';

  @override
  String get rideLimit => 'Ride limit';

  @override
  String get support => 'Support';

  @override
  String get standard => 'Standard';

  @override
  String get priority => 'Priority';

  @override
  String get vip247 => 'VIP 24/7';

  @override
  String get basic => 'Basic';

  @override
  String get advanced => 'Advanced';

  @override
  String get complete => 'Complete';

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get canChangeSubscription => 'Can I change subscription?';

  @override
  String get changeSubscriptionAnswer =>
      'Yes, you can change at any time. Changes take effect immediately.';

  @override
  String get exceedLimitQuestion => 'What happens if I exceed my limit?';

  @override
  String get exceedLimitAnswer =>
      'For Basic and Premium, you won\'t be able to accept rides until renewal.';

  @override
  String get howRenewalWorks => 'How does renewal work?';

  @override
  String get renewalAnswer =>
      'Subscription renews automatically each month. You can cancel at any time.';

  @override
  String get canGetRefund => 'Can I get a refund?';

  @override
  String get refundAnswer =>
      'Refund possible within 7 days if no rides have been taken.';

  @override
  String get commissionModel => 'Commission Model';

  @override
  String get preferCommission => 'Prefer commission model?';

  @override
  String get commissionExplanation =>
      '8% per ride instead of subscription. Ideal for low ride volume.';

  @override
  String get learnMore => 'Learn more';

  @override
  String get commissionModalTitle => 'Commission Model';

  @override
  String get commissionPerRide => 'Pay 8% commission per ride';

  @override
  String get commissionFeature1 => '8% commission per ride';

  @override
  String get commissionFeature2 => 'No monthly fees';

  @override
  String get commissionFeature3 => 'Unlimited rides';

  @override
  String get commissionExample => 'Ex: 100 DH ride → 8 DH commission';

  @override
  String get activate => 'Activate';

  @override
  String daysForMonth(int days) {
    return '$days days for 1 month';
  }

  @override
  String get specialOffer => 'Special offer for your\nfirst subscription!';

  @override
  String get errorLoadingPlans => 'Error loading plans';

  @override
  String get errorSubscription => 'Error during subscription';

  @override
  String get errorCancellation => 'Error during cancellation';

  @override
  String get errorChanging => 'Error changing subscription';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get rideLimitBasic => '60 rides/month';

  @override
  String get rideLimitPremium => '150 rides/month';

  @override
  String get rideLimitPro => 'Unlimited courses';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get notificationsMarkError => 'Error marking notifications';

  @override
  String get notificationsNoNotifications => 'No notifications';

  @override
  String get notificationsNoNotificationsMessage =>
      'You haven\'t received\nany notifications yet';

  @override
  String get notificationsLoading => 'Loading notifications...';

  @override
  String get notificationsLoadingMore => 'Loading...';

  @override
  String notificationsPaginationInfo(int current, int total) {
    return '$current of $total notifications';
  }

  @override
  String get arrivedAtPickup => 'I have arrived';

  @override
  String get startingRide => 'Start the ride';

  @override
  String get finishRide => 'Finish the ride';

  @override
  String get coming => 'I\'m coming!';

  @override
  String get time => 'Time';

  @override
  String etaMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get rideInitilisation => 'Initializing ride...';

  @override
  String get sendEvaluation => 'Send evaluation';

  @override
  String rateUser(String user) {
    return 'Rate $user';
  }

  @override
  String get thankYouForYourFeedback => 'Thank you for your feedback!';

  @override
  String get navigate => 'Navigate';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';

  @override
  String get cancelRide => 'Cancel ride';

  @override
  String get confirmationSentToPassenger => 'Confirmation sent to passenger';

  @override
  String get rideStarted => 'Ride started - Heading to: Destination';

  @override
  String get phoneNotAvailable => 'Phone number not available';

  @override
  String get cannotOpenPhoneApp => 'Cannot open phone app';

  @override
  String get userInfoNotAvailable => 'User information not available';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get locationNotAvailable => 'Location not available yet';

  @override
  String get cannotOpenNavigation => 'Cannot open navigation app';

  @override
  String get rideInfoNotAvailable => 'Ride information not available';

  @override
  String get rideCancelled => 'Ride cancelled';

  @override
  String get cancellationError => 'Error during cancellation';

  @override
  String get ratingError => 'Error submitting rating';

  @override
  String get pressAgainToExit => 'Press again to exit app';
}
