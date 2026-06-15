// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سرفر';

  @override
  String get welcomeToSrrfrr => 'مرحباً بك في سرفر';

  @override
  String get yourRideYourWay => 'رحلتك، بطريقتك';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterYourPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get connecting => 'جاري الاتصال...';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get termsConditionsNotice =>
      'بالمتابعة، توافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get loginFailedMessage =>
      'فشل تسجيل الدخول. تحقق من بيانات اعتمادك وحاول مجدداً.';

  @override
  String get errorOccurred => 'حدث خطأ. يرجى المحاولة مجدداً.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterPhoneToReceiveOtp =>
      'أدخل رقم هاتفك لتلقي رمز التحقق عبر واتساب';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String enterCodeAndNewPassword(String phoneNumber) {
    return 'أدخل الرمز المرسل إلى $phoneNumber وكلمة المرور الجديدة';
  }

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordRequirements => 'متطلبات كلمة المرور';

  @override
  String get atLeast8Characters => '8 أحرف على الأقل';

  @override
  String get oneUppercaseLetter => 'حرف كبير واحد على الأقل';

  @override
  String get oneLowercaseLetter => 'حرف صغير واحد على الأقل';

  @override
  String get oneNumber => 'رقم واحد على الأقل';

  @override
  String get oneSpecialCharacter => 'رمز خاص واحد على الأقل (!@#\$%^&*)';

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة إرسال الرمز خلال $secondsث';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get passwordReset => 'تم إعادة تعيين كلمة المرور!';

  @override
  String get passwordResetSuccess =>
      'تم إعادة تعيين كلمة المرور بنجاح.\nيمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get dontForgetNewPassword => 'لا تنسَ كلمة المرور الجديدة';

  @override
  String get otpSentViaWhatsApp => 'تم إرسال الرمز عبر واتساب';

  @override
  String get incorrectCode => 'رمز غير صحيح';

  @override
  String get createYourAccount => 'إنشاء حسابك';

  @override
  String get fillYourInformation => 'ملء معلوماتك للبدء';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get enterYourFirstName => 'أدخل اسمك الأول';

  @override
  String get lastName => 'الاسم الأخير';

  @override
  String get enterYourLastName => 'أدخل اسمك الأخير';

  @override
  String get gender => 'الجنس';

  @override
  String get selectYourGender => 'اختر جنسك';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get email => 'البريد الإلكتروني (اختياري)';

  @override
  String get emailPlaceholder => 'example@email.com';

  @override
  String get minimumPassword => '8 أحرف على الأقل';

  @override
  String get retypePassword => 'أعد كتابة كلمة المرور';

  @override
  String get iAcceptThe => 'أوافق على ';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get continueButton => 'متابعة';

  @override
  String get touchToAddPhoto => 'اضغط لإضافة صورة';

  @override
  String get touchToChangePhoto => 'اضغط للتغيير';

  @override
  String get chooseYourInterface => 'اختر واجهتك';

  @override
  String get srrfrrRegular => 'سرفر';

  @override
  String get standardInterface => 'واجهة قياسية';

  @override
  String get srrfrrLadies => 'سرفر السيدات';

  @override
  String get femaleDriversOnly => 'سائقات فقط';

  @override
  String stepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get pleaseAcceptTerms => 'يجب أن توافق على شروط الاستخدام';

  @override
  String get pleaseChooseInterface => 'يرجى اختيار واجهتك';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول بشكل صحيح';

  @override
  String get verifyYourNumber => 'تحقق من رقمك';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phoneNumber';
  }

  @override
  String get verifyCode => 'التحقق من الرمز';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get codeSentSuccessfully => 'تم إرسال رمز التحقق بنجاح';

  @override
  String get aNewCodeHasBeenSent => 'تم إرسال رمز جديد';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح!';

  @override
  String welcome(String name) {
    return 'مرحباً $name!';
  }

  @override
  String get yourAccountIsReady => 'حسابك جاهز';

  @override
  String get startTraveling => 'ابدأ رحلتك';

  @override
  String get verifiedDrivers => 'سائقون موثقون';

  @override
  String get secureEnvironment => 'بيئة آمنة';

  @override
  String get prioritySupport => 'دعم أولوي';

  @override
  String get wideChoiceOfRides => 'خيارات رحلات متنوعة';

  @override
  String get securePayments => 'دفع آمن';

  @override
  String get verifiedFemaleDrivers => 'سائقات موثقات';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get secureYourAccount => 'أمّن حسابك بكلمة مرور قوية';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get save => 'حفظ';

  @override
  String get currentPasswordRequired => 'كلمة المرور الحالية مطلوبة';

  @override
  String get newPasswordRequired => 'كلمة المرور الجديدة مطلوبة';

  @override
  String get confirmationRequired => 'التأكيد مطلوب';

  @override
  String get passwordsDontMatch => 'كلمات المرور غير متطابقة';

  @override
  String get newPasswordMustBeDifferent =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get errorChangingPassword => 'خطأ في تغيير كلمة المرور';

  @override
  String get back => 'رجوع';

  @override
  String get close => 'إغلاق';

  @override
  String get clear => 'مسح';

  @override
  String registrationProgress(int current, int total) {
    return 'تقدم التسجيل: الخطوة $current من $total';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearanceAndInterface => 'المظهر والواجهة';

  @override
  String get apply => 'تطبيق';

  @override
  String get languageChangeInfo =>
      'سيتم تحديث التطبيق فوراً لتعكس اللغة الجديدة';

  @override
  String get language => 'اللغة';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get interfaceType => 'نوع الواجهة';

  @override
  String get regularInterface => 'واجهة سرفر العادية';

  @override
  String get ladiesInterface => 'واجهة سرفر السيدات';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get enableNotifications => 'تفعيل التنبيهات';

  @override
  String get receiveAllNotifications => 'استقبال جميع التنبيهات';

  @override
  String get sound => 'الصوت';

  @override
  String get notificationSounds => 'أصوات التنبيهات';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get notificationVibration => 'اهتزاز التنبيهات';

  @override
  String get dataAndPrivacy => 'البيانات والخصوصية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get deleteMyAccount => 'حذف حسابي';

  @override
  String get notificationsSaved => 'تم حفظ إعدادات التنبيهات';

  @override
  String get savingError => 'خطأ في الحفظ';

  @override
  String get notificationsDisabled => 'تم تعطيل التنبيهات';

  @override
  String get notificationsEnabled => 'تم تفعيل التنبيهات';

  @override
  String get permissionRequired => 'إذن مطلوب';

  @override
  String get notificationPermissionExplanation =>
      'يحتاج سرفر إلى إذن التنبيهات لإرسال التحديثات المهمة حول رحلاتك وحالة السائق والرسائل.';

  @override
  String get mustEnableInSettings => 'يجب تفعيل التنبيهات في إعدادات النظام';

  @override
  String get cancel => 'إلغاء';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String featureComingSoon(String feature) {
    return '$feature - قريباً';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get actionIsIrreversible => 'هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get accountDeletionWarning =>
      'سيتم حذف حسابك بشكل دائم بعد 30 يوماً. سيتم إخفاء هويتك عن جميع بياناتك الشخصية.';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get whyDeleteAccount => 'لماذا تحذف حسابك؟';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get iUnderstandIrreversible =>
      'أفهم أن هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get delete => 'حذف';

  @override
  String get deleting => 'جاري الحذف...';

  @override
  String get accountDeletedSuccessfully => 'تم حذف الحساب بنجاح.';

  @override
  String get accountDeletionFailed => 'فشل حذف الحساب';

  @override
  String get errorOccurredPleaseTryAgain => 'حدث خطأ. يرجى المحاولة مجدداً.';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get selectLanguage => 'اختر لغتك المفضلة';

  @override
  String languageChanged(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get systemLanguage => 'لغة النظام';

  @override
  String get account => 'الحساب';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get personalInformation => 'معلومات شخصية';

  @override
  String get activity => 'النشاط';

  @override
  String get yourAlertsAndMessages => 'تنبيهاتك ورسائلك';

  @override
  String get history => 'السجل';

  @override
  String get completedRides => 'الرحلات المكتملة';

  @override
  String get loyaltyProgram => 'برنامج الولاء';

  @override
  String get pointsAndRewards => 'النقاط والمكافآت';

  @override
  String get appPreferences => 'تفضيلات التطبيق';

  @override
  String get help => 'المساعدة';

  @override
  String get supportAndFaq => 'الدعم والأسئلة الشائعة';

  @override
  String get about => 'حول';

  @override
  String get versionAndInformation => 'الإصدار والمعلومات';

  @override
  String get driverMode => 'وضع السائق';

  @override
  String get switching => 'جاري التبديل...';

  @override
  String get departure => 'الانطلاق';

  @override
  String get yourCurrentPosition => 'موقعك الحالي';

  @override
  String get arrival => 'الوصول';

  @override
  String get whereAreYouGoing => 'إلى أين تتجه؟';

  @override
  String get selectDepartureAndDestination =>
      'يرجى اختيار نقطة الانطلاق والوجهة';

  @override
  String get sendingRequest => 'جاري إرسال الطلب...';

  @override
  String get locating => 'جاري تحديد الموقع...';

  @override
  String get locationError => 'خطأ في الموقع';

  @override
  String get pickupLocation => 'موقع الالتقاط';

  @override
  String get destination => 'الوجهة';

  @override
  String get searchPlace => 'ابحث عن مكان';

  @override
  String get selectOnMap => 'اختر من الخريطة';

  @override
  String get searchAddress => 'ابحث عن عنوان';

  @override
  String get orSelectOnMap => 'أو اختر من الخريطة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get selectPickupLocation => 'اختر موقع الالتقاط';

  @override
  String get selectDestinationLocation => 'اختر موقع الوجهة';

  @override
  String get tapMapOrMoveMarker => 'اضغط على الخريطة أو اسحب العلامة';

  @override
  String get zoomForPrecision => 'قرّب للحصول على دقة أكبر';

  @override
  String get retrievingAddress => 'جاري استرجاع العنوان...';

  @override
  String get confirm => 'تأكيد';

  @override
  String get rideDetails => 'تفاصيل الرحلة';

  @override
  String get rideType => 'نوع الرحلة';

  @override
  String get autoDetected => 'تم الكشف تلقائياً';

  @override
  String get cityToCity => 'من مدينة إلى أخرى';

  @override
  String get inCity => 'داخل المدينة';

  @override
  String intercityTripDetected(String pickupCity, String destinationCity) {
    return 'تم الكشف عن رحلة بين المدن: $pickupCity → $destinationCity';
  }

  @override
  String get numberOfSeats => 'عدد المقاعد';

  @override
  String seatsSelected(int count, String plural) {
    return '$count راكب$plural محدد';
  }

  @override
  String get proposePrice => 'اقترح سعراً';

  @override
  String minimumPrice(int price) {
    return 'الحد الأدنى للسعر: $price درهم';
  }

  @override
  String get confirmRide => 'تأكيد الرحلة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cash => 'نقداً';

  @override
  String get cashPayment => 'دفع نقداً للسائق';

  @override
  String get freeRide => 'رحلة مجانية';

  @override
  String get freeRideWithPoints => 'رحلة مجانية باستخدام نقاطك';

  @override
  String insufficientPoints(int required, int available) {
    return 'نقاط غير كافية: $requiredنقطة مطلوبة، لديك $availableنقطة';
  }

  @override
  String youHavePoints(int points) {
    return 'لديك $pointsنقطة (1نقطة = 1درهم)';
  }

  @override
  String get freeRideTitle => 'رحلة مجانية';

  @override
  String get availablePoints => 'النقاط المتاحة';

  @override
  String get afterThisRide => 'بعد هذه الرحلة';

  @override
  String pointsWillBeDeducted(int points) {
    return 'سيتم خصم $pointsنقطة (1نقطة = 1درهم)';
  }

  @override
  String get driverOffers => 'عروض السائقين';

  @override
  String driversAvailable(int count, String plural) {
    return '$count سائق$plural متاح';
  }

  @override
  String get adjustYourOffer => 'عدّل عرضك';

  @override
  String get applyPrice => 'تطبيق السعر';

  @override
  String get waitingForDriverOffers => 'جاري انتظار عروض السائقين...';

  @override
  String canAdjustPriceIn(int seconds) {
    return 'يمكنك تعديل السعر خلال $secondsث إذا لم تتلقَ عروضاً';
  }

  @override
  String get canAdjustPriceNow => 'يمكنك الآن تعديل سعرك';

  @override
  String get searchingDrivers => 'جاري البحث عن سائقين';

  @override
  String get nearbyDriversWillAppear => 'ستظهر السائقون القريبون هنا';

  @override
  String get offersExpireAfter60s => 'تنتهي الصلاحية بعد 60 ثانية';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get rides => 'رحلات';

  @override
  String get counterOffer => 'عرض مقابل';

  @override
  String get initialPrice => 'السعر الأولي';

  @override
  String get driverCounterOffer => 'عرض السائق المقابل';

  @override
  String get decline => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get confirmingRide => 'جاري تأكيد الرحلة...';

  @override
  String get rideConfirmationTimeout =>
      'انتهت صلاحية تأكيد الرحلة. يرجى المحاولة مجدداً.';

  @override
  String get errorAcceptingDriver => 'خطأ في قبول السائق';

  @override
  String get driverDeclined => 'رفض السائق';

  @override
  String get offerExpired => 'انتهت صلاحية العرض';

  @override
  String get requestCancelled => 'تم إلغاء طلب الرحلة.';

  @override
  String get errorCancellingRequest => 'خطأ في إلغاء الطلب';

  @override
  String newOfferSent(int price) {
    return 'تم إرسال عرض جديد: $price درهم';
  }

  @override
  String get errorSendingOffer => 'خطأ في إرسال العرض';

  @override
  String get noOffersAdjustPrice => 'لا توجد عروض حتى الآن. حاول تعديل سعرك!';

  @override
  String get useLastOtpSent => 'يرجى استخدام رمز OTP الذي تم إرساله مسبقاً';

  @override
  String waitBeforeResending(int seconds) {
    return 'يرجى الانتظار $seconds ثانية قبل طلب رمز جديد';
  }

  @override
  String get pleaseWaitBeforeResending => 'يرجى الانتظار قبل طلب رمز جديد';

  @override
  String get tooManyAttempts => 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً';

  @override
  String get invalidPhoneNumber => 'صيغة رقم الهاتف غير صحيحة';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من الاتصال';

  @override
  String get failedToSendOtp => 'فشل إرسال رمز التحقق';

  @override
  String get otpSendIssue =>
      'حدثت مشكلة في إرسال الرمز. يمكنك محاولة إعادة الإرسال';

  @override
  String get editProfile => 'تحرير الملف الشخصي';

  @override
  String get updatePersonalInfo => 'تحديث معلوماتك الشخصية';

  @override
  String get viewPersonalInfo => 'معلوماتك الشخصية';

  @override
  String get firstNameHint => 'مثال: محمد';

  @override
  String get lastNameHint => 'مثال: العلمي';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get lastNameRequired => 'الاسم الأخير مطلوب';

  @override
  String nameTooShort(String field) {
    return '$field قصير جداً (الحد الأدنى حرفان)';
  }

  @override
  String nameTooLong(String field) {
    return '$field طويل جداً (الحد الأقصى 50 حرف)';
  }

  @override
  String get invalidCharacters => 'أحرف غير صحيحة';

  @override
  String get noChangesDetected => 'لم يتم الكشف عن أي تغييرات';

  @override
  String get infoForReservations =>
      'ستُستخدم هذه المعلومات في حجوزاتك والتحقق من هويتك';

  @override
  String get changeProfilePhoto => 'تغيير الصورة الشخصية';

  @override
  String get takePhoto => 'التقط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get cameraAccessNeeded =>
      'يتطلب الوصول إلى الكاميرا لتغيير صورتك الشخصية. يرجى السماح بالوصول في الإعدادات.';

  @override
  String get galleryAccessNeeded =>
      'يتطلب الوصول إلى المعرض لتغيير صورتك الشخصية. يرجى السماح بالوصول في الإعدادات.';

  @override
  String get errorSelectingImage => 'خطأ في اختيار الصورة';

  @override
  String get profilePhotoUpdated => 'تم تحديث الصورة الشخصية بنجاح';

  @override
  String get profilePhotoUpdateFailed => 'فشل تحديث الصورة الشخصية';

  @override
  String get errorUpdatingPhoto => 'خطأ في تحديث الصورة';

  @override
  String get editPassword => 'تغيير كلمة المرور';

  @override
  String get passwordRequirementsMustContain => 'يجب أن تحتوي كلمة المرور على:';

  @override
  String get editPhone => 'تغيير الهاتف';

  @override
  String get editPhoneNumber => 'تغيير رقم الهاتف';

  @override
  String get enterNewPhoneAndPassword =>
      'أدخل رقم هاتفك الجديد وكلمة المرور الحالية';

  @override
  String get newPhoneNumber => 'رقم الهاتف الجديد';

  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get invalidPhoneFormat => 'صيغة غير صحيحة (مثال: 0612345678)';

  @override
  String get verificationCodeWillBeSent =>
      'سيتم إرسال رمز التحقق إلى هذا الرقم';

  @override
  String enterCodeSentToPhone(String phone) {
    return 'أدخل الرمز المرسل إلى $phone';
  }

  @override
  String get otpCode => 'رمز OTP';

  @override
  String codeExpiresIn(String time) {
    return 'ينتهي الرمز في $time';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get phoneNumberChanged => 'تم تغيير رقم الهاتف بنجاح';

  @override
  String get invalidOtpCode => 'رمز OTP غير صحيح';

  @override
  String get otpSent => 'تم إرسال رمز OTP';

  @override
  String get phoneNumberSameAsCurrent => 'الرقم الجديد هو نفس الرقم الحالي';

  @override
  String get standardInterfaceDescription =>
      'واجهة كاملة مع جميع السائقين المتاحين';

  @override
  String get ladiesInterfaceDescription =>
      'واجهة مخصصة مع سائقات فقط لراحة أكثر';

  @override
  String get aboutLadiesInterface => 'حول واجهة السيدات';

  @override
  String get ladiesInterfaceInfo =>
      'يتيح لك هذا الخيار السفر فقط مع سائقات معتمدات. يمكنك تغيير الواجهة في أي وقت.';

  @override
  String get interfaceUpdated => 'تم تحديث الواجهة بنجاح';

  @override
  String get errorUpdatingInterface => 'خطأ في تحديث الواجهة';

  @override
  String get ladiesInterfaceBadge => 'واجهة السيدات';

  @override
  String get driverModeBadge => 'وضع السائق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmLogout => 'تأكيد تسجيل الخروج';

  @override
  String get enterPasswordToConfirm =>
      'يرجى إدخال كلمة المرور لتأكيد تسجيل الخروج:';

  @override
  String get loggingOut => 'جاري تسجيل الخروج...';

  @override
  String get logoutError => 'خطأ في تسجيل الخروج';

  @override
  String get editProfileInfo => 'تحرير الملف الشخصي';

  @override
  String get firstNameLastName => 'الاسم الأول والأخير';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get changePhoneNumber => 'تغيير رقم الهاتف';

  @override
  String get user => 'مستخدم';

  @override
  String get camera => 'كاميرا';

  @override
  String get gallery => 'معرض';

  @override
  String get continue_ => 'متابعة';

  @override
  String get secureAccountWithStrongPassword => 'أمّن حسابك بكلمة مرور قوية';

  @override
  String get passwordMinLength => '8 أحرف على الأقل';

  @override
  String get passwordNeedsUppercase => 'حرف كبير واحد على الأقل';

  @override
  String get passwordNeedsLowercase => 'حرف صغير واحد على الأقل';

  @override
  String get passwordNeedsNumber => 'رقم واحد على الأقل';

  @override
  String get passwordNeedsSpecialChar => 'رمز خاص واحد على الأقل';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get passwordChangeFailed => 'خطأ في تغيير كلمة المرور';

  @override
  String get confirmPasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordReqMinChars => '8 أحرف على الأقل';

  @override
  String get passwordReqUppercase => 'حرف كبير واحد';

  @override
  String get passwordReqLowercase => 'حرف صغير واحد';

  @override
  String get passwordReqNumber => 'رقم واحد';

  @override
  String get passwordReqSpecialChar => 'رمز خاص واحد (!@#\$%^&*)';

  @override
  String get otpCodeRequired => 'رمز OTP مطلوب';

  @override
  String get otpCodeMustBe6Digits => 'يجب أن يكون الرمز 6 أرقام';

  @override
  String get errorRequestingOtp => 'خطأ في طلب OTP';

  @override
  String get profileUpdateFailed => 'خطأ في تحديث الملف الشخصي';

  @override
  String get locatingYourPosition => 'جاري تحديد موقعك...';

  @override
  String get continueToOptions => 'متابعة';

  @override
  String get errorLocationService => 'خطأ في خدمة الموقع';

  @override
  String get pleaseSelectBothLocations => 'يرجى اختيار الانطلاق والوجهة';

  @override
  String get unableToCalculateDistance => 'تعذر حساب مسافة الرحلة';

  @override
  String get chooseRideType => 'اختر نوع الرحلة';

  @override
  String minimumPriceIs(int price) {
    return 'الحد الأدنى للسعر: $price درهم';
  }

  @override
  String insufficientPointsForFreeRide(int requiredPoints, int available) {
    return 'نقاط غير كافية: $requiredPointsنقطة مطلوبة، لديك $availableنقطة';
  }

  @override
  String get connectingToServer => 'جاري الاتصال بالخادم...';

  @override
  String get unableToConnectToServer => 'تعذر الاتصال بالخادم';

  @override
  String selectingLocationFor(String target) {
    return 'اختيار الموقع $target';
  }

  @override
  String get tapOrDragMarker => 'اضغط على الخريطة أو اسحب العلامة';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get selectingPickup => 'الانطلاق';

  @override
  String get selectingDestination => 'الوجهة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get carLabel => 'السيارة';

  @override
  String get carSubtitle => 'مركبة عادية';

  @override
  String get motorcycleLabel => 'دراجة نارية';

  @override
  String get motorcycleSubtitle => 'مركبة ثنائية العجلات';

  @override
  String get truckLabel => 'شاحنة';

  @override
  String get truckSubtitle => 'مركبة تجارية';

  @override
  String get newApplication => 'طلب جديد';

  @override
  String get driverRegistration => 'تسجيل السائق';

  @override
  String get cinInformationTitle => 'معلومات بطاقة التعريف';

  @override
  String get cinInformationSubtitle => 'يرجى تقديم وثائق هويتك';

  @override
  String get cinRectoPhoto => 'صورة وجه البطاقة';

  @override
  String get cinVersoPhoto => 'صورة ظهر البطاقة';

  @override
  String get selfieWithCIN => 'سيلفي مع البطاقة';

  @override
  String get cinCode => 'رقم البطاقة';

  @override
  String get cinCodeHint => 'مثال: AB123456';

  @override
  String get expirationDate => 'تاريخ الانتهاء';

  @override
  String get selectDate => 'اختر تاريخاً';

  @override
  String get vehicleInformationTitle => 'معلومات المركبة';

  @override
  String get vehicleInformationSubtitle => 'تفاصيل مركبتك';

  @override
  String get vehiclePhoto => 'صورة المركبة';

  @override
  String get vehicleRegistrationRecto => 'وجه رخصة المركبة';

  @override
  String get vehicleRegistrationVerso => 'ظهر رخصة المركبة';

  @override
  String get registrationNumber => 'رقم التسجيل';

  @override
  String get registrationNumberHint => 'مثال: 12345-A-67';

  @override
  String get brand => 'الماركة';

  @override
  String get brandHint => 'مثال: تويوتا';

  @override
  String get model => 'الموديل';

  @override
  String get modelHint => 'مثال: كورولا';

  @override
  String get color => 'اللون';

  @override
  String get colorHint => 'مثال: أبيض';

  @override
  String get productionYear => 'سنة الإنتاج';

  @override
  String get productionYearHint => 'مثال: 2020';

  @override
  String get reviewTitle => 'المراجعة';

  @override
  String get reviewSubtitle => 'يرجى التحقق من معلوماتك قبل الإرسال';

  @override
  String get cinInformationSection => 'معلومات البطاقة';

  @override
  String get vehicleInformationSection => 'معلومات المركبة';

  @override
  String get uploaded => '✓ تم الرفع';

  @override
  String get vehicleTypeLabel => 'النوع';

  @override
  String get registrationNumberLabel => 'التسجيل';

  @override
  String get brandLabel => 'الماركة';

  @override
  String get modelLabel => 'الموديل';

  @override
  String get colorLabel => 'اللون';

  @override
  String get yearLabel => 'السنة';

  @override
  String get vehiclePhotoLabel => 'صورة المركبة';

  @override
  String get vehicleRegistrationRectoLabel => 'وجه الرخصة';

  @override
  String get vehicleRegistrationVersoLabel => 'ظهر الرخصة';

  @override
  String get verificationNotice => 'سيتم التحقق من طلبك خلال 24-48 ساعة';

  @override
  String get photoAdded => 'تم إضافة الصورة';

  @override
  String get tapToTakePhoto => 'اضغط لالتقاط صورة';

  @override
  String get cinCodeLabel => 'رقم البطاقة';

  @override
  String get expirationDateLabel => 'تاريخ الانتهاء';

  @override
  String get cinRectoLabel => 'وجه البطاقة';

  @override
  String get cinVersoLabel => 'ظهر البطاقة';

  @override
  String get selfieLabel => 'سيلفي';

  @override
  String get submitApplication => 'إرسال الطلب';

  @override
  String get submittedSuccessfully => 'تم إرسال الطلب بنجاح';

  @override
  String get submissionError => 'خطأ في الإرسال';

  @override
  String get rideHistory => 'سجل الرحلات';

  @override
  String get filters => 'المرشحات';

  @override
  String get totalRides => 'الرحلات';

  @override
  String get totalAmount => 'الإنفاق الكلي';

  @override
  String ridesLoaded(int loaded, int total) {
    return '$loaded من $total رحلات محملة';
  }

  @override
  String get statusAll => 'الكل';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get statusAccepted => 'مقبولة';

  @override
  String get statusStarted => 'جارية';

  @override
  String get paymentAll => 'الكل';

  @override
  String get paymentCash => 'نقداً';

  @override
  String get paymentWallet => 'المحفظة';

  @override
  String get paymentCreditCard => 'بطاقة ائتمان';

  @override
  String get paymentLoyaltyPoints => 'نقاط الولاء';

  @override
  String get paymentFreeRide => 'رحلة مجانية';

  @override
  String get vehicleAll => 'الكل';

  @override
  String get vehicleCar => 'سيارة';

  @override
  String get vehicleMotorcycle => 'دراجة نارية';

  @override
  String get vehicleTruck => 'شاحنة';

  @override
  String get sortPriceHighToLow => 'السعر (الأعلى أولاً)';

  @override
  String get sortPriceLowToHigh => 'السعر (الأقل أولاً)';

  @override
  String get sortDistance => 'المسافة';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get hideDetails => 'إخفاء التفاصيل';

  @override
  String get rateDriver => 'تقييم السائق';

  @override
  String get contactSupport => 'التواصل مع الدعم';

  @override
  String get thankYouForRating => 'شكراً على تقييمك!';

  @override
  String get complaintSent => 'تم إرسال الشكوى بنجاح';

  @override
  String get loadingError => 'خطأ في التحميل';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get tryAgain => 'حاول مجدداً';

  @override
  String get noRidesTitle => 'لا توجد رحلات';

  @override
  String get noRidesDescription => 'عدّل المرشحات أو تفقد لاحقاً';

  @override
  String get clearAllFilters => 'مسح جميع المرشحات';

  @override
  String get applyFilters => 'تطبيق المرشحات';

  @override
  String get searchDriver => 'ابحث عن سائق...';

  @override
  String get selectDateRange => 'حدد نطاق التاريخ';

  @override
  String get priceRange => 'السعر';

  @override
  String get minPrice => 'الحد الأدنى';

  @override
  String get maxPrice => 'الحد الأقصى';

  @override
  String get status => 'الحالة';

  @override
  String get payment => 'الدفع';

  @override
  String get vehicle => 'المركبة';

  @override
  String get driver => 'السائق';

  @override
  String get date => 'التاريخ';

  @override
  String get price => 'السعر';

  @override
  String get distance => 'المسافة';

  @override
  String get duration => 'المدة';

  @override
  String get fare => 'الأجرة';

  @override
  String get passengers => 'الركاب';

  @override
  String get driverRating => 'تقييم السائق';

  @override
  String get yourRating => 'تقييمك';

  @override
  String get notRated => 'لم يتم التقييم';

  @override
  String get rated => 'تم التقييم';

  @override
  String get completed => 'مكتملة';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get accepted => 'مقبولة';

  @override
  String get started => 'جارية';

  @override
  String get wallet => 'المحفظة';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get loyaltyPoints => 'نقاط الولاء';

  @override
  String get car => 'سيارة';

  @override
  String get motorcycle => 'دراجة نارية';

  @override
  String get truck => 'شاحنة';

  @override
  String get totalRidesLabel => 'الرحلات';

  @override
  String get totalEarned => 'الإجمالي المكتسب';

  @override
  String get totalSpent => 'الإجمالي المنفق';

  @override
  String get filtersTitle => 'المرشحات';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get vehicleLabel => 'المركبة';

  @override
  String get sortByLabel => 'الترتيب حسب';

  @override
  String get statusInProgress => 'جاري التنفيذ';

  @override
  String get paymentCard => 'البطاقة';

  @override
  String get vehicleStandard => 'عادية';

  @override
  String get vehiclePremium => 'بريميوم';

  @override
  String get vehicleLadiesOnly => 'للسيدات فقط';

  @override
  String get sortDateNewestFirst => 'التاريخ (الأحدث أولاً)';

  @override
  String get sortDateOldestFirst => 'التاريخ (الأقدم أولاً)';

  @override
  String get viewTripLocation => 'موقع الرحلة';

  @override
  String get passengerLabel => 'الراكب';

  @override
  String get driverLabel => 'السائق';

  @override
  String get ratingLabel => 'التقييم';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get fareDetails => 'تفاصيل الأجرة';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get rateThisTrip => 'قيّم هذه الرحلة';

  @override
  String get rateButton => 'تقييم';

  @override
  String get complaintButton => 'شكوى';

  @override
  String get statusCompletedBadge => 'مكتملة';

  @override
  String get statusCancelledBadge => 'ملغاة';

  @override
  String get statusInProgressBadge => 'جاري التنفيذ';

  @override
  String get noTripsFound => 'لا توجد رحلات';

  @override
  String get tripsWillAppearHere => 'ستظهر رحلاتك هنا';

  @override
  String get passengerDefault => 'راكب';

  @override
  String get driverDefault => 'سائق';

  @override
  String get filtersAndSort => 'المرشحات والترتيب';

  @override
  String activeFilters(int count) {
    return '$count مرشح نشط';
  }

  @override
  String get noActiveFilters => 'لا توجد مرشحات نشطة';

  @override
  String get driverNameHint => 'اسم السائق';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get allPriceRanges => 'جميع نطاقات الأسعار';

  @override
  String get addPriceFilter => 'إضافة مرشح السعر';

  @override
  String get statusFilter => 'الحالة';

  @override
  String get allStatus => 'الكل';

  @override
  String get completedStatus => 'مكتملة';

  @override
  String get cancelledStatus => 'ملغاة';

  @override
  String get paymentFilter => 'الدفع';

  @override
  String get allPayment => 'الكل';

  @override
  String get walletPayment => 'المحفظة';

  @override
  String get creditCardPayment => 'بطاقة ائتمان';

  @override
  String get loyaltyPointsPayment => 'نقاط الولاء';

  @override
  String get freeRidePayment => 'رحلة مجانية';

  @override
  String get vehicleFilter => 'المركبة';

  @override
  String get allVehicles => 'الكل';

  @override
  String get carVehicle => 'سيارة';

  @override
  String get motorcycleVehicle => 'دراجة نارية';

  @override
  String get truckVehicle => 'شاحنة';

  @override
  String get sortBy => 'الترتيب حسب';

  @override
  String get resetAllFilters => 'إعادة تعيين جميع المرشحات';

  @override
  String get selectPeriod => 'حدد الفترة';

  @override
  String get startDate => 'البداية';

  @override
  String get endDate => 'النهاية';

  @override
  String get points => 'نقاط';

  @override
  String progressToNextLevel(String nextLevel) {
    return 'التقدم إلى $nextLevel';
  }

  @override
  String needPointsToUnlock(int pointsNeeded, String nextLevel) {
    return 'احتاج $pointsNeeded نقطة إضافية لفتح فوائد $nextLevel';
  }

  @override
  String get earnPoints => 'اكسب النقاط';

  @override
  String get earnPointsByRide => 'نقاط لكل رحلة';

  @override
  String get earnPointsByReferral => 'نقاط الإحالة';

  @override
  String get earnPointsByRating => 'نقاط التقييم';

  @override
  String get referAFriend => 'أحيل صديقاً';

  @override
  String get shareAndEarnPoints => 'شارك واكسب النقاط';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get allTransactionsLoaded => 'تم تحميل جميع المعاملات';

  @override
  String get rideCompleted => 'تم إكمال الرحلة';

  @override
  String get referralBonus => 'مكافأة الإحالة';

  @override
  String get ratingBonus => 'مكافأة التقييم';

  @override
  String get pointsUsed => 'النقاط المستخدمة';

  @override
  String get levelBronze => 'برونزي';

  @override
  String get levelSilver => 'فضي';

  @override
  String get levelGold => 'ذهبي';

  @override
  String get levelPlatinum => 'بلاتيني';

  @override
  String get levelDiamond => 'ألماسي';

  @override
  String get dataRefreshed => 'تم تحديث البيانات';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get errorRefreshingData => 'خطأ في تحديث البيانات';

  @override
  String get pleaseSelectRating => 'يرجى اختيار تقييم';

  @override
  String get pleaseSelectOption => 'يرجى اختيار خياراً';

  @override
  String get ratePassenger => 'قيّم الراكب';

  @override
  String howWasYourExperience(String name) {
    return 'كيف كانت تجربتك مع $name؟';
  }

  @override
  String get selectCategory => 'اختر فئة:';

  @override
  String get noOptionsAvailable => 'لا توجد خيارات متاحة';

  @override
  String get send => 'إرسال';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم الهاتف';

  @override
  String get invitationRegistered => 'تم تسجيل الدعوة! شارك الرابط مع صديقك.';

  @override
  String get phoneNotEligible => 'هذا الرقم غير مؤهل للإحالة';

  @override
  String get linkCopied => 'تم نسخ الرابط إلى الحافظة!';

  @override
  String get errorCopyingLink => 'خطأ في نسخ الرابط.';

  @override
  String get linkSharedSuccess => 'تم مشاركة الرابط بنجاح!';

  @override
  String get errorSharing => 'خطأ في المشاركة.';

  @override
  String get earnPointsPerFriend => 'اكسب 50 نقطة لكل صديق';

  @override
  String get referralInfoMessage =>
      'أدخل رقم صديقك لتسجيله، ثم شارك الرابط معه.';

  @override
  String get verifying => 'جاري التحقق...';

  @override
  String get savePhoneNumber => 'حفظ رقم الهاتف';

  @override
  String get or => 'أو';

  @override
  String get referralLink => 'رابط الإحالة';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String referralShareMessage(String link) {
    return '🎉 انضم إلي في سرفر!\n\nأستخدم سرفر لرحلاتي وأعتقد أنك قد تكون مهتماً!\n\n🎁 حمّل التطبيق واحصل على 50 نقطة ترحيبية!\n🚗 إنه بسيط وسريع وآمن\n\nحمّل الآن: $link\n\nإلى اللقاء قريباً على سرفر! 🚙';
  }

  @override
  String get referralInvitationSubject => 'دعوة سرفر';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get contact => 'اتصل';

  @override
  String get searchInFaq => 'ابحث في الأسئلة الشائعة...';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get ourTeamIsHereToHelp => 'فريقنا هنا لمساعدتك';

  @override
  String get hours => 'الساعات';

  @override
  String get businessHours => 'الإثنين-الجمعة: 9 صباحاً-6 مساءً';

  @override
  String get sendComplaint => 'إرسال شكوى';

  @override
  String get describeYourProblem => 'صف مشكلتك وسيرد عليك فريقنا بسرعة';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get tryOtherKeywords => 'جرب كلمات مفتاحية أخرى';

  @override
  String get pleaseDescribeProblem => 'يرجى وصف مشكلتك';

  @override
  String get provideMoreDetails =>
      'يرجى تقديم المزيد من التفاصيل (الحد الأدنى 10 أحرف)';

  @override
  String get category => 'الفئة';

  @override
  String get technicalIssue => 'مشكلة فنية';

  @override
  String get accountingIssue => 'مشكلة محاسبية';

  @override
  String get safetyIssue => 'مشكلة أمان';

  @override
  String get drivingIssue => 'مشكلة قيادة';

  @override
  String get other => 'أخرى';

  @override
  String get description => 'الوصف';

  @override
  String get describeYourProblemInDetail =>
      'صف مشكلتك بالتفصيل. سيقوم فريقنا بالرد عليك في أقرب وقت ممكن.';

  @override
  String trajectoryRef(String ref) {
    return 'مرجع الرحلة #$ref';
  }

  @override
  String get sendReclamation => 'إرسال الشكوى';

  @override
  String get describeProblem => 'وصف المشكلة';

  @override
  String get minCharacters => 'الحد الأدنى 10 أحرف';

  @override
  String get exampleReclamation =>
      'مثال: لم يصل السائق في الوقت المحدد، ولم يتم تحديث حالة الرحلة.';

  @override
  String get sendComplaintButton => 'إرسال الشكوى';

  @override
  String get faqAccountTitle => 'الحساب والتسجيل';

  @override
  String get faqAccount1Q => 'كيف أنشئ حساباً؟';

  @override
  String get faqAccount1A =>
      'لإنشاء حساب، حمّل تطبيق سرفر، أدخل رقم هاتفك، تحقق من رمز OTP المرسل عبر SMS، ثم أكمل ملفك الشخصي بمعلوماتك الشخصية.';

  @override
  String get faqAccount2Q => 'هل يمكنني استخدام نفس الحساب كراكب وسائق؟';

  @override
  String get faqAccount2A =>
      'نعم! يمكنك التبديل بين وضع الراكب والسائق في إعدادات التطبيق. لتصبح سائقاً، يجب عليك إرسال طلب مع وثائقك.';

  @override
  String get faqAccount3Q => 'كيف أغيّر رقم هاتفي؟';

  @override
  String get faqAccount3A =>
      'انتقل إلى الإعدادات > الملف الشخصي > تغيير رقم الهاتف. ستحتاج إلى التحقق من الرقم الجديد برمز OTP.';

  @override
  String get faqBookingTitle => 'حجز الرحلات';

  @override
  String get faqBooking1Q => 'كيف أحجز رحلة؟';

  @override
  String get faqBooking1A =>
      'على الشاشة الرئيسية، أدخل وجهتك، اختر نوع المركبة، تحقق من السعر المتوقع، ثم اضغط \'تأكيد الطلب\'. سيقبل سائق طلبك في لحظات.';

  @override
  String get faqBooking2Q => 'هل يمكنني إلغاء رحلة؟';

  @override
  String get faqBooking2A =>
      'نعم، يمكنك إلغاء الرحلة قبل قبول السائق بدون رسوم. بعد القبول، قد تنطبق رسوم الإلغاء.';

  @override
  String get faqBooking3Q => 'كيف يعمل وضع السيدات فقط؟';

  @override
  String get faqBooking3A =>
      'يسمح وضع السيدات فقط للركاب الإناث بالمطابقة فقط مع سائقات. فعّل هذا الخيار في إعدادات ملفك الشخصي.';

  @override
  String get faqPaymentTitle => 'الدفع';

  @override
  String get faqPayment1Q => 'ما طرق الدفع المقبولة؟';

  @override
  String get faqPayment1A =>
      'نقبل دفع نقداً وبطاقة ائتمان. يمكنك اختيار طريقة الدفع المفضلة لديك عند الحجز.';

  @override
  String get faqPayment2Q => 'كيف تعمل نقاط الولاء؟';

  @override
  String get faqPayment2A =>
      'تكتسب نقاطاً مع كل رحلة مكتملة، عند إحالة الأصدقاء، وباستخدام التطبيق بانتظام. يمكن استبدال هذه النقاط بخصومات على رحلاتك.';

  @override
  String get faqPayment3Q => 'هل يمكنني الحصول على إيصال لرحلتي؟';

  @override
  String get faqPayment3A =>
      'نعم، جميع إيصالاتك متاحة في سجل الرحلات. يمكنك تحميلها أو استقبالها عبر البريد الإلكتروني.';

  @override
  String get faqSafetyTitle => 'الأمان';

  @override
  String get faqSafety1Q => 'كيف يضمن سرفر سلامتي؟';

  @override
  String get faqSafety1A =>
      'يتم التحقق من جميع السائقين ببيانات هويتهم الرسمية. يمكنك مشاركة رحلتك في الوقت الفعلي مع أحبائك والإبلاغ عن أي مشاكل عبر التطبيق.';

  @override
  String get faqSafety2Q => 'ماذا أفعل إذا حدثت مشكلة أثناء الرحلة؟';

  @override
  String get faqSafety2A =>
      'استخدم زر \'الطوارئ\' في التطبيق للتواصل الفوري مع فريق الأمان لدينا. يمكنك أيضاً الاتصال بالسلطات مباشرة إذا لزم الأمر.';

  @override
  String get faqSafety3Q => 'هل يتم حماية بياناتي الشخصية؟';

  @override
  String get faqSafety3A =>
      'نعم، نستخدم تشفيراً بمستوى البنوك لحماية جميع بياناتك الشخصية والمالية. لا نشارك معلوماتك مع أطراف ثالثة.';

  @override
  String get faqDriverTitle => 'الانضمام كسائق';

  @override
  String get faqDriver1Q => 'ما متطلبات الانضمام كسائق؟';

  @override
  String get faqDriver1A =>
      'يجب أن تمتلك رخصة قيادة صالحة، بطاقة هوية، مركبة في حالة جيدة برخصة تسجيل صالحة، وأن تكون في الحد الأدنى 21 سنة من العمر.';

  @override
  String get faqDriver2Q => 'كم من الوقت يستغرق التحقق من حساب السائق؟';

  @override
  String get faqDriver2A =>
      'عادة ما يستغرق التحقق من الوثائق من 24 إلى 48 ساعة. ستتلقى إشعاراً عند التحقق من حسابك.';

  @override
  String get faqDriver3Q => 'كيف يتم حساب أرباحي؟';

  @override
  String get faqDriver3A =>
      'يتم حساب أرباحك بناءً على المسافة المقطوعة ووقت الرحلة والطلب الحالي. تأخذ سرفر عمولة 15% على كل رحلة.';

  @override
  String get faqDriver4Q => 'متى يمكنني سحب أرباحي؟';

  @override
  String get faqDriver4A =>
      'يمكنك سحب أرباحك في أي وقت عبر محفظتك كسائق. يتم معالجة السحوبات خلال 1 إلى 3 أيام عمل.';

  @override
  String get faqTechTitle => 'المشاكل الفنية';

  @override
  String get faqTech1Q => 'التطبيق لا يجد موقعي';

  @override
  String get faqTech1A =>
      'تحقق من تفعيل خدمات الموقع للتطبيق في إعدادات هاتفك. تأكد أيضاً من وجود اتصال إنترنت نشط.';

  @override
  String get faqTech2Q => 'لا أتلقى رمز OTP';

  @override
  String get faqTech2A =>
      'تحقق من إدخالك لرقم الهاتف الصحيح وأن لديك تغطية شبكة. إذا استمرت المشكلة، استخدم خيار \'إعادة إرسال الرمز\' بعد 60 ثانية.';

  @override
  String get faqTech3Q => 'التطبيق يغلق بشكل غير متوقع';

  @override
  String get faqTech3A =>
      'حاول تحديث التطبيق إلى أحدث إصدار، أعد تشغيل هاتفك، وتأكد من توفر مساحة تخزين كافية.';

  @override
  String get walletBalanceTransactions => 'الرصيد والمعاملات';

  @override
  String get manageSubscription => 'إدارة اشتراكي';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get passengerMode => 'وضع الراكب';

  @override
  String get ladiesInterfaceDriverBadge => 'سائق سرفر السيدات';

  @override
  String get verificationStatus => 'حالة التحقق';

  @override
  String get notRegisteredTitle => 'أصبح سائقاً';

  @override
  String get notRegisteredDescription =>
      'حوّل رحلاتك إلى دخل وانضم إلى مجتمعنا من السائقين';

  @override
  String get startRegistration => 'ابدأ التسجيل';

  @override
  String get pendingVerificationTitle => 'قيد التحقق';

  @override
  String get pendingVerificationDescription =>
      'فريقنا يراجع طلبك.\nستتلقى إشعاراً عند التحقق';

  @override
  String get verificationTimeframe =>
      'عادة ما يستغرق التحقق 24 إلى 48 ساعة عمل';

  @override
  String get processingTime => 'وقت المعالجة';

  @override
  String get returnHome => 'العودة للصفحة الرئيسية';

  @override
  String get validatedTitle => 'تهانينا! 🎉';

  @override
  String get validatedDescription => 'تم التحقق بنجاح\nمن حسابك كسائق';

  @override
  String get welcomeDrivers => 'مرحباً بك في مجتمع السائقين';

  @override
  String get welcomeDriversDescription =>
      'أنت الآن سائق معتمد بسرفر ويمكنك البدء في قبول الرحلات';

  @override
  String get verifiedStatus => 'حالة معتمد';

  @override
  String get verifiedBadge => 'شارة سائق معتمد';

  @override
  String get flexibleIncome => 'دخل مرن';

  @override
  String get flexibleIncomeDesc => 'اكسب وفقاً لتوفرك';

  @override
  String get insuredProtection => 'حماية مؤمنة';

  @override
  String get insuredProtectionDesc => 'تغطية كاملة أثناء الرحلات';

  @override
  String get startDriving => 'ابدأ القيادة';

  @override
  String get rejectedTitle => 'الطلب لم يتم قبوله';

  @override
  String get rejectedDescription =>
      'طلبك يحتاج إلى تعديلات.\nيمكنك إرسال طلب جديد';

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get defaultRejectionReason =>
      'وثائق غير مكتملة أو غير صحيحة. يرجى التحقق من معلوماتك وإرسال وثائق متوافقة.';

  @override
  String get attractiveIncome => 'دخل جذاب';

  @override
  String get attractiveIncomeDesc => 'حدد أسعارك وزيادة أرباحك';

  @override
  String get totalFreedom => 'حرية كاملة';

  @override
  String get totalFreedomDesc => 'اعمل وفقاً لجدولك';

  @override
  String get guaranteedSafety => 'أمان مضمون';

  @override
  String get guaranteedSafetyDesc => 'حماية كاملة لكل رحلة';

  @override
  String get verifyingStatus => 'جاري التحقق من الحالة...';

  @override
  String get myVehicle => 'مركبتي';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get driverWallet => 'المحفظة';

  @override
  String get totalRidesDriver => 'إجمالي الرحلات';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get earnings => 'الأرباح';

  @override
  String get historyDriver => 'السجل';

  @override
  String get supportDriver => 'الدعم';

  @override
  String get onlineMode => 'متصل';

  @override
  String get offlineMode => 'غير متصل';

  @override
  String get readyToAccept => 'جاهز لقبول الرحلات';

  @override
  String get activateToReceive => 'فعّل لاستقبال الطلبات';

  @override
  String get goOnline => 'اتصل';

  @override
  String get goOffline => 'قطع الاتصال';

  @override
  String get noRequests => 'لا توجد طلبات';

  @override
  String get searchingNearby => 'جاري البحث عن ركاب قريبين...';

  @override
  String get notificationsActive => 'التنبيهات نشطة';

  @override
  String get offlineStatus => 'وضع غير متصل';

  @override
  String get goOnlineToReceive => 'اتصل لاستقبال الطلبات';

  @override
  String get activeRequests => 'الطلبات النشطة';

  @override
  String get counterOfferTitle => 'إرسال عرض مقابل';

  @override
  String get passengerOffer => 'عرض الراكب:';

  @override
  String get yourCounterOffer => 'عرضك المقابل';

  @override
  String get enterYourPrice => 'أدخل سعرك';

  @override
  String get fairPriceTip =>
      'نصيحة: اقترح سعراً عادلاً بناءً على المسافة والوقت';

  @override
  String get sendOffer => 'إرسال العرض';

  @override
  String get negotiateButton => 'المفاوضة';

  @override
  String get refuseButton => 'رفض';

  @override
  String get acceptRide => 'قبول الرحلة';

  @override
  String get waitingForResponse => 'في انتظار الرد';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds ثانية متبقية';
  }

  @override
  String get cancelOffer => 'إلغاء العرض';

  @override
  String get registration => 'التسجيل';

  @override
  String get type => 'النوع';

  @override
  String get year => 'السنة';

  @override
  String get unknownAddress => 'عنوان غير معروف';

  @override
  String get walletTitle => 'محفظتي';

  @override
  String get overviewTab => 'نظرة عامة';

  @override
  String get codesTab => 'الرموز';

  @override
  String get historyTab => 'السجل';

  @override
  String get availableBalance => 'الرصيد المتاح';

  @override
  String get rechargeWallet => 'إعادة شحن المحفظة';

  @override
  String get monthDetails => 'تفاصيل الشهر';

  @override
  String get grossEarnings => 'الأرباح الإجمالية';

  @override
  String get commissions => 'العمولات';

  @override
  String get netEarnings => 'الأرباح الصافية';

  @override
  String get costPerRide => 'التكلفة لكل رحلة';

  @override
  String get effectiveRate => 'المعدل الفعلي';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get retry => 'إعادة محاولة';

  @override
  String get currencySymbol => 'د.م.';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get transactionTypeCredit => 'إيداع';

  @override
  String get transactionTypeDebit => 'سحب';

  @override
  String get transactionTypeCommission => 'عمولة';

  @override
  String get transactionTypeSubscription => 'اشتراك';

  @override
  String get transactionTypeInit => 'تهيئة';

  @override
  String get justNow => 'للتو';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hoursس';
  }

  @override
  String daysAgo(int days) {
    return 'منذ $days أيام';
  }

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get perRide => 'لكل رحلة';

  @override
  String get totalDebits => 'إجمالي السحوبات';

  @override
  String get totalCredits => 'إجمالي الإيدوعات';

  @override
  String get netThisMonth => 'الصافي هذا الشهر';

  @override
  String get totalTransactions => 'إجمالي المعاملات';

  @override
  String get generateNewCode => 'إنشاء رمز جديد';

  @override
  String get activeCodes => 'الرموز النشطة';

  @override
  String get expiredCodes => 'الرموز منتهية الصلاحية';

  @override
  String get noRechargeCodes => 'لا توجد رموز إعادة شحن';

  @override
  String get generateCodeDescription => 'أنشئ رمزاً لإعادة شحن\nمحفظتك';

  @override
  String get codeCopied => 'تم نسخ الرمز إلى الحافظة';

  @override
  String get deleteCodeTitle => 'حذف الرمز';

  @override
  String get deleteCodeConfirmation =>
      'هل أنت متأكد من رغبتك في حذف رمز إعادة الشحن هذا؟';

  @override
  String get codeDeleted => 'تم حذف الرمز';

  @override
  String get active => 'نشط';

  @override
  String get expired => 'منتهي الصلاحية';

  @override
  String get generateCodeOption => 'إنشاء رمز';

  @override
  String get generateCodeSubtitle => 'الدفع في الوكالة برمز';

  @override
  String get creditCardOption => 'بطاقة ائتمان';

  @override
  String get creditCardSubtitle => 'دفع آمن عبر الإنترنت';

  @override
  String get amount => 'المبلغ (درهم)';

  @override
  String get amountHint => 'مثال: 500';

  @override
  String get generateCodeInfo => 'قدّم هذا الرمز في الوكالة لإتمام الدفع';

  @override
  String get generate => 'إنشاء';

  @override
  String get codeGenerated => 'تم إنشاء الرمز';

  @override
  String get presentCodeInfo => 'قدّم هذا الرمز في الوكالة\nلإعادة شحن محفظتك';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get cardPaymentTitle => 'دفع بالبطاقة';

  @override
  String get securePaymentInfo => 'دفع آمن • إعادة شحن فورية';

  @override
  String get redirectingPayment => 'جاري إعادة التوجيه للدفع الآمن...';

  @override
  String get subscriptionsTitle => 'الاشتراكات';

  @override
  String get plansTab => 'الخطط';

  @override
  String get noActiveSubscription => 'لا توجد اشتراكات نشطة';

  @override
  String get choosePlanPrompt => 'اختر خطة لفتح\nجميع الفوائد';

  @override
  String get ridesUsed => 'الرحلات المستخدمة';

  @override
  String get coursesThisMonth => 'الرحلات هذا الشهر';

  @override
  String get unlimited => 'غير محدود';

  @override
  String get subscriptionExpired => 'انتهت صلاحية الاشتراك';

  @override
  String expiresInDays(int days) {
    return 'ينتهي خلال $days أيام';
  }

  @override
  String renewsInDays(int days) {
    return 'يتجدد خلال $days أيام';
  }

  @override
  String get cancelSubscription => 'إلغاء الاشتراك';

  @override
  String get cancelSubscriptionDialog => 'إلغاء الاشتراك؟';

  @override
  String cancelSubscriptionWarning(String planName) {
    return 'سيتم إلغاء اشتراك $planName الخاص بك فوراً';
  }

  @override
  String get subscriptionCancelled => 'تم إلغاء الاشتراك';

  @override
  String get choosePlan => 'اختر خطة';

  @override
  String get popular => 'الأكثر رواجاً';

  @override
  String get current => 'حالي';

  @override
  String get amountPerMonth => 'درهم/شهر';

  @override
  String get activeSubscription => 'اشتراك نشط';

  @override
  String get changeToPlan => 'التبديل إلى هذه الخطة';

  @override
  String get chooseThisPlan => 'اختر هذه الخطة';

  @override
  String get takeAdvantage => '🎉 استفد من العرض';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get confirmSubscription => 'تأكيد الاشتراك';

  @override
  String subscribeToPlan(String planName) {
    return 'ستشترك في خطة $planName';
  }

  @override
  String get newPlan => 'خطة جديدة';

  @override
  String get changeSubscription => 'تغيير الاشتراك';

  @override
  String switchFromTo(String fromPlan, String toPlan) {
    return 'التبديل من $fromPlan إلى $toPlan';
  }

  @override
  String get changeEffectiveImmediately => 'يصبح التغيير نافذاً فوراً';

  @override
  String get subscriptionActivated => 'تم تفعيل الاشتراك!';

  @override
  String get subscriptionChanged => 'تم تغيير الاشتراك!';

  @override
  String get noHistory => 'لا يوجد سجل';

  @override
  String get historyPrompt => 'ستظهر اشتراكاتك السابقة\nهنا';

  @override
  String itemsOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get period => 'الفترة';

  @override
  String get comparison => 'المقارنة';

  @override
  String get commission => 'العمولة';

  @override
  String get rideLimit => 'حد الرحلات';

  @override
  String get support => 'الدعم';

  @override
  String get standard => 'عادي';

  @override
  String get priority => 'أولوي';

  @override
  String get vip247 => 'VIP 24/7';

  @override
  String get basic => 'أساسي';

  @override
  String get advanced => 'متقدم';

  @override
  String get complete => 'كامل';

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get canChangeSubscription => 'هل يمكنني تغيير الاشتراك؟';

  @override
  String get changeSubscriptionAnswer =>
      'نعم، يمكنك التغيير في أي وقت. يصبح التغيير نافذاً فوراً.';

  @override
  String get exceedLimitQuestion => 'ماذا يحدث إذا تجاوزت الحد؟';

  @override
  String get exceedLimitAnswer =>
      'بالنسبة للخطط الأساسية والمتقدمة، لن تتمكن من قبول الرحلات حتى التجديد.';

  @override
  String get howRenewalWorks => 'كيف يعمل التجديد؟';

  @override
  String get renewalAnswer =>
      'يتجدد الاشتراك تلقائياً كل شهر. يمكنك الإلغاء في أي وقت.';

  @override
  String get canGetRefund => 'هل يمكنني الحصول على استرجاع؟';

  @override
  String get refundAnswer =>
      'الاسترجاع ممكن خلال 7 أيام إذا لم تكن قد أنجزت أي رحلات.';

  @override
  String get commissionModel => 'نموذج العمولة';

  @override
  String get preferCommission => 'تفضل نموذج العمولة؟';

  @override
  String get commissionExplanation =>
      'عمولة 8% لكل رحلة بدلاً من الاشتراك. مثالي لحجم رحلات منخفض.';

  @override
  String get learnMore => 'معرفة المزيد';

  @override
  String get commissionModalTitle => 'نموذج العمولة';

  @override
  String get commissionPerRide => 'ادفع عمولة 8% لكل رحلة';

  @override
  String get commissionFeature1 => 'عمولة 8% لكل رحلة';

  @override
  String get commissionFeature2 => 'بدون رسوم شهرية';

  @override
  String get commissionFeature3 => 'رحلات غير محدودة';

  @override
  String get commissionExample => 'مثال: رحلة 100 درهم → عمولة 8 درهم';

  @override
  String get activate => 'تفعيل';

  @override
  String daysForMonth(int days) {
    return '$days يوم بـ شهر واحد';
  }

  @override
  String get specialOffer => 'عرض خاص لاشتراكك\nالأول!';

  @override
  String get errorLoadingPlans => 'خطأ في تحميل الخطط';

  @override
  String get errorSubscription => 'خطأ أثناء الاشتراك';

  @override
  String get errorCancellation => 'خطأ أثناء الإلغاء';

  @override
  String get errorChanging => 'خطأ في تغيير الاشتراك';

  @override
  String get errorLoadingHistory => 'خطأ في تحميل السجل';

  @override
  String get rideLimitBasic => '60 رحلة/شهر';

  @override
  String get rideLimitPremium => '150 رحلة/شهر';

  @override
  String get rideLimitPro => 'رحلات غير محدودة';

  @override
  String get notificationsTitle => 'التنبيهات';

  @override
  String get notificationsMarkAllRead => 'وضع علامة الكل كمقروء';

  @override
  String get notificationsMarkedAsRead =>
      'تم وضع علامة على جميع التنبيهات كمقروء';

  @override
  String get notificationsMarkError => 'خطأ في وضع العلامات';

  @override
  String get notificationsNoNotifications => 'لا توجد تنبيهات';

  @override
  String get notificationsNoNotificationsMessage =>
      'لم تتلقَ أي\nتنبيهات حتى الآن';

  @override
  String get notificationsLoading => 'جاري تحميل التنبيهات...';

  @override
  String get notificationsLoadingMore => 'جاري التحميل...';

  @override
  String notificationsPaginationInfo(int current, int total) {
    return '$current من $total تنبيهات';
  }

  @override
  String get arrivedAtPickup => 'لقد وصلت';

  @override
  String get startingRide => 'بدء الرحلة';

  @override
  String get finishRide => 'إنهاء الرحلة';

  @override
  String get coming => 'قادم';

  @override
  String get time => 'الوقت';

  @override
  String etaMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get rideInitilisation => 'تهيئة الرحلة...';

  @override
  String get sendEvaluation => 'إرسال التقييم';

  @override
  String rateUser(String user) {
    return 'تقييم $user';
  }

  @override
  String get thankYouForYourFeedback => 'شكراً لتقديم تقييمك!';

  @override
  String get navigate => 'توجيه';

  @override
  String get call => 'اتصال';

  @override
  String get message => 'مراسلة';

  @override
  String get cancelRide => 'إلغاء الرحلة';

  @override
  String get confirmationSentToPassenger => 'تم إرسال التأكيد إلى الراكب';

  @override
  String get rideStarted => 'بدأت الرحلة - الاتجاه: الوجهة';

  @override
  String get phoneNotAvailable => 'رقم الهاتف غير متاح';

  @override
  String get cannotOpenPhoneApp => 'لا يمكن فتح تطبيق الهاتف';

  @override
  String get userInfoNotAvailable => 'معلومات المستخدم غير متاحة';

  @override
  String get userNotAuthenticated => 'المستخدم غير موثق';

  @override
  String get locationNotAvailable => 'الموقع غير متاح بعد';

  @override
  String get cannotOpenNavigation => 'لا يمكن فتح تطبيق الملاحة';

  @override
  String get rideInfoNotAvailable => 'معلومات الرحلة غير متاحة';

  @override
  String get rideCancelled => 'تم إلغاء الرحلة';

  @override
  String get cancellationError => 'خطأ أثناء الإلغاء';

  @override
  String get ratingError => 'خطأ في التقديم';

  @override
  String get pressAgainToExit => 'اضغط مرة أخرى للخروج من التطبيق';
}
