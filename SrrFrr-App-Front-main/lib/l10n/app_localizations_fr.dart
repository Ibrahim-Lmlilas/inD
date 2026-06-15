// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'SRR FRR';

  @override
  String get welcomeToSrrfrr => 'Bienvenue sur SRR FRR';

  @override
  String get yourRideYourWay => 'Votre trajet, à votre façon';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get enterYourPhoneNumber => 'Entrez votre numéro de téléphone';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get login => 'Se connecter';

  @override
  String get connecting => 'Connexion...';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get termsConditionsNotice =>
      'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité';

  @override
  String get loginFailedMessage =>
      'Échec de la connexion. Veuillez vérifier vos informations et réessayer.';

  @override
  String get errorOccurred => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get enterPhoneToReceiveOtp =>
      'Entrez votre numéro de téléphone pour recevoir un code de vérification par WhatsApp';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String enterCodeAndNewPassword(String phoneNumber) {
    return 'Entrez le code envoyé au $phoneNumber et votre nouveau mot de passe';
  }

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordRequirements => 'Exigences du mot de passe';

  @override
  String get atLeast8Characters => 'Au moins 8 caractères';

  @override
  String get oneUppercaseLetter => 'Une lettre majuscule';

  @override
  String get oneLowercaseLetter => 'Une lettre minuscule';

  @override
  String get oneNumber => 'Un chiffre';

  @override
  String get oneSpecialCharacter => 'Un caractère spécial (!@#\$%^&*)';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer le code dans ${seconds}s';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get passwordReset => 'Mot de passe réinitialisé !';

  @override
  String get passwordResetSuccess =>
      'Votre mot de passe a été réinitialisé avec succès.\nVous pouvez maintenant vous connecter avec votre nouveau mot de passe.';

  @override
  String get dontForgetNewPassword =>
      'N\'oubliez pas votre nouveau mot de passe';

  @override
  String get otpSentViaWhatsApp => 'Code envoyé via WhatsApp';

  @override
  String get incorrectCode => 'Code incorrect';

  @override
  String get createYourAccount => 'Créez votre compte';

  @override
  String get fillYourInformation =>
      'Remplissez vos informations pour commencer';

  @override
  String get firstName => 'Prénom';

  @override
  String get enterYourFirstName => 'Entrez votre prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get enterYourLastName => 'Entrez votre nom';

  @override
  String get gender => 'Genre';

  @override
  String get selectYourGender => 'Sélectionnez votre genre';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get email => 'Email (optionnel)';

  @override
  String get emailPlaceholder => 'exemple@email.com';

  @override
  String get minimumPassword => 'Minimum 8 caractères';

  @override
  String get retypePassword => 'Retapez votre mot de passe';

  @override
  String get iAcceptThe => 'J\'accepte les ';

  @override
  String get termsOfUse => 'conditions d\'utilisation';

  @override
  String get continueButton => 'Continuer';

  @override
  String get touchToAddPhoto => 'Toucher pour ajouter une photo';

  @override
  String get touchToChangePhoto => 'Toucher pour changer';

  @override
  String get chooseYourInterface => 'Choisissez votre interface';

  @override
  String get srrfrrRegular => 'SRR FRR';

  @override
  String get standardInterface => 'Interface standard';

  @override
  String get srrfrrLadies => 'SRR FRR Ladies';

  @override
  String get femaleDriversOnly => 'Conductrices femmes uniquement';

  @override
  String stepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get pleaseAcceptTerms =>
      'Vous devez accepter les conditions d\'utilisation';

  @override
  String get pleaseChooseInterface => 'Veuillez choisir votre interface';

  @override
  String get pleaseFillAllFields =>
      'Veuillez remplir tous les champs correctement';

  @override
  String get verifyYourNumber => 'Vérifiez votre numéro';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Saisissez le code à 6 chiffres envoyé au $phoneNumber';
  }

  @override
  String get verifyCode => 'Vérifier le code';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get codeSentSuccessfully => 'Code de vérification envoyé avec succès';

  @override
  String get aNewCodeHasBeenSent => 'Un nouveau code a été envoyé';

  @override
  String get registrationSuccess => 'Inscription réussie !';

  @override
  String welcome(String name) {
    return 'Bienvenue $name !';
  }

  @override
  String get yourAccountIsReady => 'Votre compte est prêt';

  @override
  String get startTraveling => 'Commencer à voyager';

  @override
  String get verifiedDrivers => 'Conducteurs vérifiés';

  @override
  String get secureEnvironment => 'Environnement sécurisé';

  @override
  String get prioritySupport => 'Support prioritaire';

  @override
  String get wideChoiceOfRides => 'Large choix de trajets';

  @override
  String get securePayments => 'Paiements sécurisés';

  @override
  String get verifiedFemaleDrivers => 'Conductrices vérifiées';

  @override
  String get changePassword => 'Modifier le mot de passe';

  @override
  String get secureYourAccount =>
      'Sécurisez votre compte avec un mot de passe fort';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get save => 'Enregistrer';

  @override
  String get currentPasswordRequired => 'Mot de passe actuel requis';

  @override
  String get newPasswordRequired => 'Nouveau mot de passe requis';

  @override
  String get confirmationRequired => 'Confirmation requise';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get newPasswordMustBeDifferent =>
      'Le nouveau mot de passe doit être différent';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe modifié avec succès';

  @override
  String get errorChangingPassword => 'Erreur lors de la modification';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get clear => 'Effacer';

  @override
  String registrationProgress(int current, int total) {
    return 'Progression de l\'inscription: étape $current sur $total';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get appearanceAndInterface => 'Apparence et Interface';

  @override
  String get apply => 'Appliquer';

  @override
  String get languageChangeInfo =>
      'L\'application se mettra à jour immédiatement pour refléter la nouvelle langue';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get interfaceType => 'Type d\'interface';

  @override
  String get regularInterface => 'Interface SrrFrr Régulière';

  @override
  String get ladiesInterface => 'Interface SrrFrr Ladies';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get receiveAllNotifications => 'Recevoir toutes les notifications';

  @override
  String get sound => 'Son';

  @override
  String get notificationSounds => 'Sons des notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get notificationVibration => 'Vibration des notifications';

  @override
  String get dataAndPrivacy => 'Données et confidentialité';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsAndConditions => 'Conditions d\'utilisation';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get notificationsSaved => 'Paramètres de notifications enregistrés';

  @override
  String get savingError => 'Erreur lors de l\'enregistrement';

  @override
  String get notificationsDisabled => 'Notifications désactivées';

  @override
  String get notificationsEnabled => 'Notifications activées';

  @override
  String get permissionRequired => 'Permission requise';

  @override
  String get notificationPermissionExplanation =>
      'SrrFrr a besoin de la permission de notification pour vous envoyer des mises à jour importantes sur vos trajets, le statut du conducteur et les messages.';

  @override
  String get mustEnableInSettings =>
      'Vous devez autoriser les notifications dans les paramètres système';

  @override
  String get cancel => 'Annuler';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String featureComingSoon(String feature) {
    return '$feature - Bientôt disponible';
  }

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get actionIsIrreversible => 'Cette action est irréversible';

  @override
  String get accountDeletionWarning =>
      'Votre compte sera définitivement supprimé après une période de grâce de 30 jours. Toutes vos données personnelles seront anonymisées.';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get reasonOptional => 'Raison (optionnel)';

  @override
  String get whyDeleteAccount => 'Pourquoi supprimez-vous votre compte ?';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get iUnderstandIrreversible =>
      'Je comprends que cette action est irréversible';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleting => 'Suppression en cours...';

  @override
  String get accountDeletedSuccessfully => 'Compte supprimé avec succès.';

  @override
  String get accountDeletionFailed => 'Échec de la suppression du compte';

  @override
  String get errorOccurredPleaseTryAgain =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get changeLanguage => 'Changer la langue';

  @override
  String get selectLanguage => 'Sélectionnez votre langue préférée';

  @override
  String languageChanged(String language) {
    return 'Langue changée en $language';
  }

  @override
  String get systemLanguage => 'Langue système';

  @override
  String get account => 'Compte';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get activity => 'Activité';

  @override
  String get yourAlertsAndMessages => 'Vos alertes et messages';

  @override
  String get history => 'Historique';

  @override
  String get completedRides => 'Courses effectuées';

  @override
  String get loyaltyProgram => 'Programme de fidélité';

  @override
  String get pointsAndRewards => 'Points et récompenses';

  @override
  String get appPreferences => 'Préférences de l\'app';

  @override
  String get help => 'Aide';

  @override
  String get supportAndFaq => 'Support et FAQ';

  @override
  String get about => 'À propos';

  @override
  String get versionAndInformation => 'Version et informations';

  @override
  String get driverMode => 'Mode Conducteur';

  @override
  String get switching => 'Changement...';

  @override
  String get departure => 'Départ';

  @override
  String get yourCurrentPosition => 'Votre position actuelle';

  @override
  String get arrival => 'Arrivée';

  @override
  String get whereAreYouGoing => 'Où allez-vous?';

  @override
  String get selectDepartureAndDestination =>
      'Veuillez sélectionner le départ et la destination';

  @override
  String get sendingRequest => 'Envoi de la demande...';

  @override
  String get locating => 'Localisation en cours...';

  @override
  String get locationError => 'Erreur de localisation';

  @override
  String get pickupLocation => 'Lieu de départ';

  @override
  String get destination => 'Destination';

  @override
  String get searchPlace => 'Rechercher un lieu';

  @override
  String get selectOnMap => 'Sélectionner sur la carte';

  @override
  String get searchAddress => 'Recherchez une adresse';

  @override
  String get orSelectOnMap => 'ou sélectionnez sur la carte';

  @override
  String get loading => 'Chargement...';

  @override
  String get selectPickupLocation => 'Sélectionner le lieu de départ';

  @override
  String get selectDestinationLocation => 'Sélectionner le lieu de destination';

  @override
  String get tapMapOrMoveMarker => 'Touchez la carte ou déplacez le marqueur';

  @override
  String get zoomForPrecision => 'Zoomez pour plus de précision';

  @override
  String get retrievingAddress => 'Récupération de l\'adresse...';

  @override
  String get confirm => 'Confirmer';

  @override
  String get rideDetails => 'Détails du trajet';

  @override
  String get rideType => 'Type de trajet';

  @override
  String get autoDetected => 'Auto-détecté';

  @override
  String get cityToCity => 'Ville à ville';

  @override
  String get inCity => 'En ville';

  @override
  String intercityTripDetected(String pickupCity, String destinationCity) {
    return 'Trajet inter-villes détecté: $pickupCity → $destinationCity';
  }

  @override
  String get numberOfSeats => 'Nombre de places';

  @override
  String seatsSelected(int count, String plural) {
    return '$count passager$plural sélectionné$plural';
  }

  @override
  String get proposePrice => 'Proposer un prix';

  @override
  String minimumPrice(int price) {
    return 'Prix minimum: $price DH';
  }

  @override
  String get confirmRide => 'Confirmer le trajet';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get cash => 'Espèces';

  @override
  String get cashPayment => 'Paiement en liquide au chauffeur';

  @override
  String get freeRide => 'Course Offerte';

  @override
  String get freeRideWithPoints => 'Course gratuite avec vos points';

  @override
  String insufficientPoints(int required, int available) {
    return 'Insuffisant: ${required}pts requis, vous avez ${available}pts';
  }

  @override
  String youHavePoints(int points) {
    return 'Vous avez ${points}pts (1pt = 1DH)';
  }

  @override
  String get freeRideTitle => 'Course gratuite';

  @override
  String get availablePoints => 'Points disponibles';

  @override
  String get afterThisRide => 'Après cette course';

  @override
  String pointsWillBeDeducted(int points) {
    return '$points points seront déduits (1pt = 1DH)';
  }

  @override
  String get driverOffers => 'Offres des conducteurs';

  @override
  String driversAvailable(int count, String plural) {
    return '$count conducteur$plural disponible$plural';
  }

  @override
  String get adjustYourOffer => 'Ajustez votre offre';

  @override
  String get applyPrice => 'Appliquer le prix';

  @override
  String get waitingForDriverOffers =>
      'En attente des offres des conducteurs...';

  @override
  String canAdjustPriceIn(int seconds) {
    return 'Vous pouvez ajuster le prix dans ${seconds}s si aucune offre';
  }

  @override
  String get canAdjustPriceNow => 'Vous pouvez maintenant ajuster votre prix';

  @override
  String get searchingDrivers => 'Recherche de conducteurs';

  @override
  String get nearbyDriversWillAppear =>
      'Les conducteurs à proximité apparaîtront ici';

  @override
  String get offersExpireAfter60s => 'Les offres expirent après 60 secondes';

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String get rides => 'rides';

  @override
  String get counterOffer => 'Contre-offre';

  @override
  String get initialPrice => 'Prix initial';

  @override
  String get driverCounterOffer => 'Contre-offre du conducteur';

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get confirmingRide => 'Confirmation de la course...';

  @override
  String get rideConfirmationTimeout =>
      'Le délai de confirmation de la course est expiré. Veuillez réessayer.';

  @override
  String get errorAcceptingDriver =>
      'Erreur lors de l\'acceptation du conducteur';

  @override
  String get driverDeclined => 'Conducteur refusé';

  @override
  String get offerExpired => 'Offer expired';

  @override
  String get requestCancelled => 'La demande de course a été annulée.';

  @override
  String get errorCancellingRequest =>
      'Erreur lors de l\'annulation de la demande';

  @override
  String newOfferSent(int price) {
    return 'Nouvelle offre envoyée : $price DH';
  }

  @override
  String get errorSendingOffer => 'Erreur lors de l\'envoi de l\'offre';

  @override
  String get noOffersAdjustPrice => 'No offers yet. Try adjusting your price!';

  @override
  String get useLastOtpSent =>
      'Veuillez utiliser le code OTP envoyé précédemment';

  @override
  String waitBeforeResending(int seconds) {
    return 'Veuillez attendre $seconds secondes avant de demander un nouveau code';
  }

  @override
  String get pleaseWaitBeforeResending =>
      'Veuillez attendre avant de demander un nouveau code';

  @override
  String get tooManyAttempts =>
      'Trop de tentatives. Veuillez réessayer plus tard';

  @override
  String get invalidPhoneNumber => 'Format de numéro de téléphone invalide';

  @override
  String get networkError => 'Erreur réseau. Veuillez vérifier votre connexion';

  @override
  String get failedToSendOtp => 'Échec de l\'envoi du code de vérification';

  @override
  String get otpSendIssue =>
      'Un problème est survenu lors de l\'envoi du code. Vous pouvez réessayer de l\'envoyer';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get updatePersonalInfo =>
      'Mettez à jour vos informations personnelles';

  @override
  String get viewPersonalInfo => 'Vos informations personnelles';

  @override
  String get firstNameHint => 'Ex: Mohamed';

  @override
  String get lastNameHint => 'Ex: Alami';

  @override
  String get firstNameRequired => 'Prénom requis';

  @override
  String get lastNameRequired => 'Nom requis';

  @override
  String nameTooShort(String field) {
    return '$field trop court (minimum 2 caractères)';
  }

  @override
  String nameTooLong(String field) {
    return '$field trop long (maximum 50 caractères)';
  }

  @override
  String get invalidCharacters => 'Caractères invalides';

  @override
  String get noChangesDetected => 'Aucune modification détectée';

  @override
  String get infoForReservations =>
      'Ces informations seront utilisées pour vos réservations et vérifications';

  @override
  String get changeProfilePhoto => 'Changer la photo de profil';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get cameraAccessNeeded =>
      'L\'accès à la caméra est nécessaire pour changer votre photo de profil. Veuillez autoriser l\'accès dans les paramètres.';

  @override
  String get galleryAccessNeeded =>
      'L\'accès à la galerie est nécessaire pour changer votre photo de profil. Veuillez autoriser l\'accès dans les paramètres.';

  @override
  String get errorSelectingImage => 'Erreur lors de la sélection de l\'image';

  @override
  String get profilePhotoUpdated => 'Photo de profil mise à jour avec succès';

  @override
  String get profilePhotoUpdateFailed => 'Échec de la mise à jour de la photo';

  @override
  String get errorUpdatingPhoto => 'Erreur lors de la mise à jour de la photo';

  @override
  String get editPassword => 'Modifier le mot de passe';

  @override
  String get passwordRequirementsMustContain =>
      'Le mot de passe doit contenir:';

  @override
  String get editPhone => 'Modifier le numéro';

  @override
  String get editPhoneNumber => 'Modifier le numéro de téléphone';

  @override
  String get enterNewPhoneAndPassword =>
      'Entrez votre nouveau numéro et votre mot de passe actuel';

  @override
  String get newPhoneNumber => 'Nouveau numéro';

  @override
  String get phoneNumberRequired => 'Numéro de téléphone requis';

  @override
  String get invalidPhoneFormat => 'Format invalide (ex: 0612345678)';

  @override
  String get verificationCodeWillBeSent =>
      'Un code de vérification sera envoyé à ce numéro';

  @override
  String enterCodeSentToPhone(String phone) {
    return 'Entrez le code envoyé au $phone';
  }

  @override
  String get otpCode => 'Code OTP';

  @override
  String codeExpiresIn(String time) {
    return 'Code expire dans $time';
  }

  @override
  String get verify => 'Vérifier';

  @override
  String get phoneNumberChanged => 'Numéro modifié avec succès';

  @override
  String get invalidOtpCode => 'Code OTP invalide';

  @override
  String get otpSent => 'Code OTP envoyé';

  @override
  String get phoneNumberSameAsCurrent =>
      'Le nouveau numéro est identique au numéro actuel';

  @override
  String get standardInterfaceDescription =>
      'Interface complète avec tous les conducteurs disponibles';

  @override
  String get ladiesInterfaceDescription =>
      'Interface dédiée avec conductrices uniquement pour plus de confort';

  @override
  String get aboutLadiesInterface => 'À propos de l\'interface Femmes';

  @override
  String get ladiesInterfaceInfo =>
      'Cette option vous permet de voyager uniquement avec des conductrices certifiées. Vous pouvez changer d\'interface à tout moment.';

  @override
  String get interfaceUpdated => 'Interface mise à jour avec succès';

  @override
  String get errorUpdatingInterface => 'Erreur lors de la mise à jour';

  @override
  String get ladiesInterfaceBadge => 'Interface Femmes';

  @override
  String get driverModeBadge => 'Mode Conducteur';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get confirmLogout => 'Confirmer la déconnexion';

  @override
  String get enterPasswordToConfirm =>
      'Veuillez entrer votre mot de passe pour confirmer la déconnexion:';

  @override
  String get loggingOut => 'Déconnexion...';

  @override
  String get logoutError => 'Erreur de déconnexion';

  @override
  String get editProfileInfo => 'Modifier le profil';

  @override
  String get firstNameLastName => 'Prénom, nom';

  @override
  String get accountSecurity => 'Sécurité du compte';

  @override
  String get changePhoneNumber => 'Modifier le numéro';

  @override
  String get user => 'Utilisateur';

  @override
  String get camera => 'appareil photo';

  @override
  String get gallery => 'galerie';

  @override
  String get continue_ => 'Continuer';

  @override
  String get secureAccountWithStrongPassword =>
      'Sécurisez votre compte avec un mot de passe fort';

  @override
  String get passwordMinLength => 'Au moins 8 caractères';

  @override
  String get passwordNeedsUppercase => 'Au moins une lettre majuscule';

  @override
  String get passwordNeedsLowercase => 'Au moins une lettre minuscule';

  @override
  String get passwordNeedsNumber => 'Au moins un chiffre';

  @override
  String get passwordNeedsSpecialChar => 'Au moins un caractère spécial';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès';

  @override
  String get passwordChangeFailed =>
      'Erreur lors du changement de mot de passe';

  @override
  String get confirmPasswordRequired => 'Confirmation du mot de passe requise';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordReqMinChars => 'Au moins 8 caractères';

  @override
  String get passwordReqUppercase => 'Une lettre majuscule';

  @override
  String get passwordReqLowercase => 'Une lettre minuscule';

  @override
  String get passwordReqNumber => 'Un chiffre';

  @override
  String get passwordReqSpecialChar => 'Un caractère spécial (!@#\$%^&*)';

  @override
  String get otpCodeRequired => 'Code OTP requis';

  @override
  String get otpCodeMustBe6Digits => 'Le code doit contenir 6 chiffres';

  @override
  String get errorRequestingOtp => 'Erreur lors de la demande d\'OTP';

  @override
  String get profileUpdateFailed => 'Erreur lors de la mise à jour du profil';

  @override
  String get locatingYourPosition => 'Localisation en cours...';

  @override
  String get continueToOptions => 'Continuer';

  @override
  String get errorLocationService => 'Erreur de service de localisation';

  @override
  String get pleaseSelectBothLocations =>
      'Veuillez sélectionner le départ et la destination';

  @override
  String get unableToCalculateDistance =>
      'Impossible de calculer la distance du trajet';

  @override
  String get chooseRideType => 'Choisissez un type de trajet';

  @override
  String minimumPriceIs(int price) {
    return 'Prix minimum: $price DH';
  }

  @override
  String insufficientPointsForFreeRide(int requiredPoints, int available) {
    return 'Points insuffisants: ${requiredPoints}pts requis, vous avez ${available}pts';
  }

  @override
  String get connectingToServer => 'Connexion au serveur...';

  @override
  String get unableToConnectToServer => 'Impossible de se connecter au serveur';

  @override
  String selectingLocationFor(String target) {
    return 'Sélection de la localisation pour le $target';
  }

  @override
  String get tapOrDragMarker => 'Touchez la carte ou déplacez le marqueur';

  @override
  String get confirmLocation => 'Confirmer la localisation';

  @override
  String get selectingPickup => 'départ';

  @override
  String get selectingDestination => 'destination';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get carLabel => 'Voiture';

  @override
  String get carSubtitle => 'Véhicule standard';

  @override
  String get motorcycleLabel => 'Moto';

  @override
  String get motorcycleSubtitle => 'Deux roues motorisé';

  @override
  String get truckLabel => 'Camion';

  @override
  String get truckSubtitle => 'Véhicule utilitaire';

  @override
  String get newApplication => 'Nouvelle demande';

  @override
  String get driverRegistration => 'Inscription Conducteur';

  @override
  String get cinInformationTitle => 'Informations CIN';

  @override
  String get cinInformationSubtitle =>
      'Veuillez fournir vos documents d\'identité';

  @override
  String get cinRectoPhoto => 'Photo CIN Recto';

  @override
  String get cinVersoPhoto => 'Photo CIN Verso';

  @override
  String get selfieWithCIN => 'Selfie avec CIN';

  @override
  String get cinCode => 'Code CIN';

  @override
  String get cinCodeHint => 'Ex: AB123456';

  @override
  String get expirationDate => 'Date d\'expiration';

  @override
  String get selectDate => 'Sélectionnez une date';

  @override
  String get vehicleInformationTitle => 'Informations Véhicule';

  @override
  String get vehicleInformationSubtitle => 'Détails de votre véhicule';

  @override
  String get vehiclePhoto => 'Photo du véhicule';

  @override
  String get vehicleRegistrationRecto => 'Carte grise Recto';

  @override
  String get vehicleRegistrationVerso => 'Carte grise Verso';

  @override
  String get registrationNumber => 'Numéro d\'immatriculation';

  @override
  String get registrationNumberHint => 'Ex: 12345-A-67';

  @override
  String get brand => 'Marque';

  @override
  String get brandHint => 'Ex: Toyota';

  @override
  String get model => 'Modèle';

  @override
  String get modelHint => 'Ex: Corolla';

  @override
  String get color => 'Couleur';

  @override
  String get colorHint => 'Ex: Blanc';

  @override
  String get productionYear => 'Année de production';

  @override
  String get productionYearHint => 'Ex: 2020';

  @override
  String get reviewTitle => 'Vérification';

  @override
  String get reviewSubtitle =>
      'Veuillez vérifier vos informations avant de soumettre';

  @override
  String get cinInformationSection => 'Informations CIN';

  @override
  String get vehicleInformationSection => 'Informations Véhicule';

  @override
  String get uploaded => '✓ Uploadé';

  @override
  String get vehicleTypeLabel => 'Type';

  @override
  String get registrationNumberLabel => 'Immatriculation';

  @override
  String get brandLabel => 'Marque';

  @override
  String get modelLabel => 'Modèle';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get yearLabel => 'Année';

  @override
  String get vehiclePhotoLabel => 'Photo véhicule';

  @override
  String get vehicleRegistrationRectoLabel => 'Carte grise Recto';

  @override
  String get vehicleRegistrationVersoLabel => 'Carte grise Verso';

  @override
  String get verificationNotice =>
      'Votre demande sera vérifiée dans les 24-48 heures';

  @override
  String get photoAdded => 'Photo ajoutée';

  @override
  String get tapToTakePhoto => 'Appuyez pour prendre une photo';

  @override
  String get cinCodeLabel => 'Code CIN';

  @override
  String get expirationDateLabel => 'Date d\'expiration';

  @override
  String get cinRectoLabel => 'CIN Recto';

  @override
  String get cinVersoLabel => 'CIN Verso';

  @override
  String get selfieLabel => 'Selfie';

  @override
  String get submitApplication => 'Soumettre la demande';

  @override
  String get submittedSuccessfully => 'Demande soumise avec succès';

  @override
  String get submissionError => 'Erreur lors de la soumission';

  @override
  String get rideHistory => 'Historique des Trajets';

  @override
  String get filters => 'Filtres';

  @override
  String get totalRides => 'Trajets';

  @override
  String get totalAmount => 'Total dépensé';

  @override
  String ridesLoaded(int loaded, int total) {
    return '$loaded sur $total trajets chargés';
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
  String get paymentCreditCard => 'CreditCard';

  @override
  String get paymentLoyaltyPoints => 'LoyaltyPoints';

  @override
  String get paymentFreeRide => 'FreeRide';

  @override
  String get vehicleAll => 'All';

  @override
  String get vehicleCar => 'Voiture';

  @override
  String get vehicleMotorcycle => 'Moto';

  @override
  String get vehicleTruck => 'Camion';

  @override
  String get sortPriceHighToLow => 'Price (high to low)';

  @override
  String get sortPriceLowToHigh => 'Price (low to high)';

  @override
  String get sortDistance => 'Distance';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get hideDetails => 'Masquer les détails';

  @override
  String get rateDriver => 'Évaluer le chauffeur';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get thankYouForRating => 'Merci pour votre évaluation!';

  @override
  String get complaintSent => 'Réclamation envoyée avec succès';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get noRidesTitle => 'Aucun trajet trouvé';

  @override
  String get noRidesDescription => 'Ajustez vos filtres ou revenez plus tard';

  @override
  String get clearAllFilters => 'Effacer tous les filtres';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get searchDriver => 'Rechercher un chauffeur...';

  @override
  String get selectDateRange => 'Sélectionner une période';

  @override
  String get priceRange => 'Prix';

  @override
  String get minPrice => 'Min';

  @override
  String get maxPrice => 'Max';

  @override
  String get status => 'Statut';

  @override
  String get payment => 'Paiement';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get driver => 'Chauffeur';

  @override
  String get date => 'Date';

  @override
  String get price => 'Prix';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Durée';

  @override
  String get fare => 'Tarif';

  @override
  String get passengers => 'Passagers';

  @override
  String get driverRating => 'Note du chauffeur';

  @override
  String get yourRating => 'Votre note';

  @override
  String get notRated => 'Non évalué';

  @override
  String get rated => 'Évalué';

  @override
  String get completed => 'Terminé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get accepted => 'Accepté';

  @override
  String get started => 'En cours';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get creditCard => 'Carte bancaire';

  @override
  String get loyaltyPoints => 'Points fidélité';

  @override
  String get car => 'Voiture';

  @override
  String get motorcycle => 'Moto';

  @override
  String get truck => 'Camion';

  @override
  String get totalRidesLabel => 'Trajets';

  @override
  String get totalEarned => 'Total Gagné';

  @override
  String get totalSpent => 'Total Dépensé';

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get statusLabel => 'Statut';

  @override
  String get paymentLabel => 'Paiement';

  @override
  String get vehicleLabel => 'Véhicule';

  @override
  String get sortByLabel => 'Trier par';

  @override
  String get statusInProgress => 'InProgress';

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
  String get viewTripLocation => 'Localisation du trajet';

  @override
  String get passengerLabel => 'Passager';

  @override
  String get driverLabel => 'Chauffeur';

  @override
  String get ratingLabel => 'Note';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get fareDetails => 'Détail du tarif';

  @override
  String get totalLabel => 'Total';

  @override
  String get rateThisTrip => 'Noter ce trajet';

  @override
  String get rateButton => 'Noter';

  @override
  String get complaintButton => 'Réclamation';

  @override
  String get statusCompletedBadge => 'Terminé';

  @override
  String get statusCancelledBadge => 'Annulé';

  @override
  String get statusInProgressBadge => 'En cours';

  @override
  String get noTripsFound => 'Aucun trajet trouvé';

  @override
  String get tripsWillAppearHere => 'Vos trajets apparaîtront ici';

  @override
  String get passengerDefault => 'Passager';

  @override
  String get driverDefault => 'Chauffeur';

  @override
  String get filtersAndSort => 'Filtres et tri';

  @override
  String activeFilters(int count) {
    return '$count filtre(s) actif(s)';
  }

  @override
  String get noActiveFilters => 'Aucun filtre actif';

  @override
  String get driverNameHint => 'Nom du chauffeur';

  @override
  String get dateRange => 'Période';

  @override
  String get allPriceRanges => 'Toutes les gammes';

  @override
  String get addPriceFilter => 'Ajouter filtre prix';

  @override
  String get statusFilter => 'Statut';

  @override
  String get allStatus => 'Tous';

  @override
  String get completedStatus => 'Terminé';

  @override
  String get cancelledStatus => 'Annulé';

  @override
  String get paymentFilter => 'Paiement';

  @override
  String get allPayment => 'Tous';

  @override
  String get walletPayment => 'Portefeuille';

  @override
  String get creditCardPayment => 'Carte bancaire';

  @override
  String get loyaltyPointsPayment => 'Points fidélité';

  @override
  String get freeRidePayment => 'Trajet gratuit';

  @override
  String get vehicleFilter => 'Véhicule';

  @override
  String get allVehicles => 'Tous';

  @override
  String get carVehicle => 'Voiture';

  @override
  String get motorcycleVehicle => 'Moto';

  @override
  String get truckVehicle => 'Camion';

  @override
  String get sortBy => 'Trier par';

  @override
  String get resetAllFilters => 'Réinitialiser tous les filtres';

  @override
  String get selectPeriod => 'Sélectionner la période';

  @override
  String get startDate => 'Début';

  @override
  String get endDate => 'Fin';

  @override
  String get points => 'points';

  @override
  String progressToNextLevel(String nextLevel) {
    return 'Progression vers $nextLevel';
  }

  @override
  String needPointsToUnlock(int pointsNeeded, String nextLevel) {
    return 'Encore $pointsNeeded points pour débloquer les avantages $nextLevel';
  }

  @override
  String get earnPoints => 'Gagner des points';

  @override
  String get earnPointsByRide => 'Points pour chaque trajet';

  @override
  String get earnPointsByReferral => 'Points de parrainage';

  @override
  String get earnPointsByRating => 'Points pour avis';

  @override
  String get referAFriend => 'Parrainer un ami';

  @override
  String get shareAndEarnPoints => 'Partagez et gagnez des points';

  @override
  String get noTransactions => 'Aucune transaction';

  @override
  String get allTransactionsLoaded => 'Toutes les transactions chargées';

  @override
  String get rideCompleted => 'Trajet terminé';

  @override
  String get referralBonus => 'Bonus parrainage';

  @override
  String get ratingBonus => 'Bonus évaluation';

  @override
  String get pointsUsed => 'Points utilisés';

  @override
  String get levelBronze => 'Bronze';

  @override
  String get levelSilver => 'Argent';

  @override
  String get levelGold => 'Or';

  @override
  String get levelPlatinum => 'Platine';

  @override
  String get levelDiamond => 'Diamant';

  @override
  String get dataRefreshed => 'Données actualisées';

  @override
  String get errorLoadingData => 'Erreur lors du chargement';

  @override
  String get errorRefreshingData => 'Erreur lors de l\'actualisation';

  @override
  String get pleaseSelectRating => 'Veuillez sélectionner une note';

  @override
  String get pleaseSelectOption => 'Veuillez sélectionner une option';

  @override
  String get ratePassenger => 'Noter le passager';

  @override
  String howWasYourExperience(String name) {
    return 'Comment était votre expérience avec $name?';
  }

  @override
  String get selectCategory => 'Sélectionnez une catégorie :';

  @override
  String get noOptionsAvailable => 'Aucune option disponible';

  @override
  String get send => 'Envoyer';

  @override
  String get pleaseEnterPhoneNumber => 'Veuillez entrer un numéro de téléphone';

  @override
  String get invitationRegistered =>
      'Invitation enregistrée! Partagez le lien avec votre ami.';

  @override
  String get phoneNotEligible => 'Ce numéro n\'est pas éligible au parrainage';

  @override
  String get linkCopied => 'Lien copié dans le presse-papiers!';

  @override
  String get errorCopyingLink => 'Erreur lors de la copie du lien.';

  @override
  String get linkSharedSuccess => 'Lien partagé avec succès!';

  @override
  String get errorSharing => 'Erreur lors du partage.';

  @override
  String get earnPointsPerFriend => 'Gagnez 50 points par ami';

  @override
  String get referralInfoMessage =>
      'Entrez le numéro de votre ami pour l\'enregistrer, puis partagez le lien avec lui.';

  @override
  String get verifying => 'Vérification...';

  @override
  String get savePhoneNumber => 'Enregistrer le numéro';

  @override
  String get or => 'OU';

  @override
  String get referralLink => 'Lien de parrainage';

  @override
  String get share => 'Partager';

  @override
  String get copy => 'Copier';

  @override
  String referralShareMessage(String link) {
    return '🎉 Rejoins-moi sur SRRFRR!\n\nJ\'utilise SRRFRR pour mes déplacements et je pense que ça pourrait t\'intéresser aussi!\n\n🎁 Télécharge l\'app et reçois 50 points de bienvenue!\n🚗 C\'est simple, rapide et sécurisé\n\nTélécharge maintenant: $link\n\nÀ bientôt sur SRRFRR! 🚙';
  }

  @override
  String get referralInvitationSubject => 'Invitation SRRFRR';

  @override
  String get faq => 'FAQ';

  @override
  String get contact => 'Contact';

  @override
  String get searchInFaq => 'Rechercher dans les FAQ...';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get ourTeamIsHereToHelp => 'Notre équipe est là pour vous aider';

  @override
  String get hours => 'Horaires';

  @override
  String get businessHours => 'Lun-Ven: 9h-18h';

  @override
  String get sendComplaint => 'Envoyer une réclamation';

  @override
  String get describeYourProblem =>
      'Décrivez votre problème et notre équipe vous répondra rapidement';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryOtherKeywords => 'Essayez avec d\'autres mots-clés';

  @override
  String get pleaseDescribeProblem => 'Veuillez décrire votre problème';

  @override
  String get provideMoreDetails =>
      'Veuillez fournir plus de détails (minimum 10 caractères)';

  @override
  String get category => 'Catégorie';

  @override
  String get technicalIssue => 'Problème technique';

  @override
  String get accountingIssue => 'Problème comptable';

  @override
  String get safetyIssue => 'Problème de sécurité';

  @override
  String get drivingIssue => 'Problème de conduite';

  @override
  String get other => 'Autre';

  @override
  String get description => 'Description';

  @override
  String get describeYourProblemInDetail =>
      'Décrivez votre problème en détail. Notre équipe vous répondra dans les plus brefs délais.';

  @override
  String trajectoryRef(String ref) {
    return 'Trajet ref #$ref';
  }

  @override
  String get sendReclamation => 'Envoyer la réclamation';

  @override
  String get describeProblem => 'Décrivez votre problème';

  @override
  String get minCharacters => 'Minimum 10 caractères requis';

  @override
  String get exampleReclamation =>
      'Exemple: J\'ai eu un problème avec mon dernier trajet où le conducteur a pris un chemin plus long que nécessaire, ce qui a augmenté le coût de la course. Je souhaite que cela soit examiné et que des mesures soient prises pour éviter que cela ne se reproduise.';

  @override
  String get sendComplaintButton => 'Envoyer la réclamation';

  @override
  String get faqAccountTitle => 'Compte et Inscription';

  @override
  String get faqAccount1Q => 'Comment créer un compte?';

  @override
  String get faqAccount1A =>
      'Pour créer un compte, téléchargez l\'application SRRFRR, entrez votre numéro de téléphone, vérifiez le code OTP envoyé par SMS, puis complétez votre profil avec vos informations personnelles.';

  @override
  String get faqAccount2Q =>
      'Puis-je utiliser le même compte comme passager et conducteur?';

  @override
  String get faqAccount2A =>
      'Oui! Vous pouvez basculer entre les modes passager et conducteur dans les paramètres de l\'application. Pour devenir conducteur, vous devez soumettre une demande avec vos documents.';

  @override
  String get faqAccount3Q => 'Comment modifier mon numéro de téléphone?';

  @override
  String get faqAccount3A =>
      'Allez dans Paramètres > Profil > Modifier le numéro de téléphone. Vous devrez vérifier le nouveau numéro avec un code OTP.';

  @override
  String get faqBookingTitle => 'Réservation de trajets';

  @override
  String get faqBooking1Q => 'Comment réserver un trajet?';

  @override
  String get faqBooking1A =>
      'Sur l\'écran d\'accueil, entrez votre destination, choisissez le type de véhicule, vérifiez le prix estimé, puis appuyez sur \'Confirmer la demande\'. Un conducteur acceptera votre demande dans quelques instants.';

  @override
  String get faqBooking2Q => 'Puis-je annuler un trajet?';

  @override
  String get faqBooking2A =>
      'Oui, vous pouvez annuler un trajet avant qu\'un conducteur n\'accepte sans frais. Après acceptation, des frais d\'annulation peuvent s\'appliquer.';

  @override
  String get faqBooking3Q => 'Comment fonctionne le mode \'Ladies-only\'?';

  @override
  String get faqBooking3A =>
      'Le mode Ladies-only permet aux passagères d\'être mises en relation uniquement avec des conductrices. Activez cette option dans vos paramètres de profil.';

  @override
  String get faqPaymentTitle => 'Paiement';

  @override
  String get faqPayment1Q => 'Quels modes de paiement sont acceptés?';

  @override
  String get faqPayment1A =>
      'Nous acceptons les paiements en espèces et par carte bancaire. Vous pouvez choisir votre mode de paiement préféré lors de la réservation.';

  @override
  String get faqPayment2Q => 'Comment fonctionnent les points de fidélité?';

  @override
  String get faqPayment2A =>
      'Vous gagnez des points à chaque trajet complété, lors du parrainage d\'amis, et en utilisant régulièrement l\'application. Ces points peuvent être échangés contre des réductions sur vos trajets.';

  @override
  String get faqPayment3Q => 'Puis-je obtenir un reçu pour mon trajet?';

  @override
  String get faqPayment3A =>
      'Oui, tous vos reçus sont disponibles dans l\'historique des trajets. Vous pouvez les télécharger ou les recevoir par email.';

  @override
  String get faqSafetyTitle => 'Sécurité';

  @override
  String get faqSafety1Q => 'Comment SRRFRR assure-t-il ma sécurité?';

  @override
  String get faqSafety1A =>
      'Tous les conducteurs sont vérifiés avec leurs documents officiels. Vous pouvez partager votre trajet en temps réel avec vos proches et signaler tout problème via l\'application.';

  @override
  String get faqSafety2Q => 'Que faire en cas de problème pendant un trajet?';

  @override
  String get faqSafety2A =>
      'Utilisez le bouton \'Urgence\' dans l\'application pour contacter immédiatement notre équipe de sécurité. Vous pouvez également appeler directement les autorités si nécessaire.';

  @override
  String get faqSafety3Q => 'Mes données personnelles sont-elles protégées?';

  @override
  String get faqSafety3A =>
      'Oui, nous utilisons un cryptage de niveau bancaire pour protéger toutes vos données personnelles et financières. Nous ne partageons jamais vos informations avec des tiers.';

  @override
  String get faqDriverTitle => 'Devenir conducteur';

  @override
  String get faqDriver1Q =>
      'Quelles sont les conditions pour devenir conducteur?';

  @override
  String get faqDriver1A =>
      'Vous devez avoir un permis de conduire valide, une carte d\'identité, un véhicule en bon état avec une carte grise valide, et être âgé d\'au moins 21 ans.';

  @override
  String get faqDriver2Q =>
      'Combien de temps prend la validation de mon compte conducteur?';

  @override
  String get faqDriver2A =>
      'La vérification de vos documents prend généralement 24 à 48 heures. Vous recevrez une notification une fois votre compte validé.';

  @override
  String get faqDriver3Q => 'Comment sont calculés mes gains?';

  @override
  String get faqDriver3A =>
      'Vos gains sont calculés en fonction de la distance parcourue, du temps de trajet, et de la demande actuelle. SRRFRR prend une commission de 15% sur chaque course.';

  @override
  String get faqDriver4Q => 'Quand puis-je retirer mes gains?';

  @override
  String get faqDriver4A =>
      'Vous pouvez retirer vos gains à tout moment via votre portefeuille conducteur. Les retraits sont traités sous 1 à 3 jours ouvrables.';

  @override
  String get faqTechTitle => 'Problèmes techniques';

  @override
  String get faqTech1Q => 'L\'application ne trouve pas ma position';

  @override
  String get faqTech1A =>
      'Vérifiez que vous avez activé la géolocalisation pour l\'application dans les paramètres de votre téléphone. Assurez-vous également d\'avoir une connexion internet active.';

  @override
  String get faqTech2Q => 'Je n\'arrive pas à recevoir le code OTP';

  @override
  String get faqTech2A =>
      'Vérifiez que vous avez entré le bon numéro de téléphone et que vous avez du réseau. Si le problème persiste, utilisez l\'option \'Renvoyer le code\' après 60 secondes.';

  @override
  String get faqTech3Q => 'L\'application se ferme de manière inattendue';

  @override
  String get faqTech3A =>
      'Essayez de mettre à jour l\'application vers la dernière version, redémarrez votre téléphone, et assurez-vous d\'avoir suffisamment d\'espace de stockage disponible.';

  @override
  String get walletBalanceTransactions => 'Solde et transactions';

  @override
  String get manageSubscription => 'Gérer mon abonnement';

  @override
  String get subscription => 'Abonnement';

  @override
  String get passengerMode => 'Mode Passager';

  @override
  String get ladiesInterfaceDriverBadge => 'SRR FRR Ladies Conductrice';

  @override
  String get verificationStatus => 'Statut de vérification';

  @override
  String get notRegisteredTitle => 'Devenez Conducteur';

  @override
  String get notRegisteredDescription =>
      'Transformez vos trajets en revenus et rejoignez notre communauté de conducteurs';

  @override
  String get startRegistration => 'Commencer l\'inscription';

  @override
  String get pendingVerificationTitle => 'En cours de vérification';

  @override
  String get pendingVerificationDescription =>
      'Notre équipe examine votre demande.\nVous recevrez une notification dès validation';

  @override
  String get verificationTimeframe =>
      'La vérification prend généralement entre 24 et 48 heures ouvrables';

  @override
  String get processingTime => 'Délai de traitement';

  @override
  String get returnHome => 'Retour à l\'accueil';

  @override
  String get validatedTitle => 'Félicitations ! 🎉';

  @override
  String get validatedDescription =>
      'Votre compte conducteur\na été validé avec succès';

  @override
  String get welcomeDrivers => 'Bienvenue parmi les conducteurs';

  @override
  String get welcomeDriversDescription =>
      'Vous êtes maintenant un conducteur SRR FRR vérifié et pouvez commencer à accepter des courses';

  @override
  String get verifiedStatus => 'Statut vérifié';

  @override
  String get verifiedBadge => 'Badge de conducteur certifié';

  @override
  String get flexibleIncome => 'Revenus flexibles';

  @override
  String get flexibleIncomeDesc => 'Gagnez selon votre disponibilité';

  @override
  String get insuredProtection => 'Protection assurée';

  @override
  String get insuredProtectionDesc => 'Couverture complète pendant les courses';

  @override
  String get startDriving => 'Commencer à conduire';

  @override
  String get rejectedTitle => 'Demande non approuvée';

  @override
  String get rejectedDescription =>
      'Votre demande nécessite des ajustements.\nVous pouvez soumettre une nouvelle demande';

  @override
  String get rejectionReason => 'Raison du refus';

  @override
  String get defaultRejectionReason =>
      'Documents incomplets ou invalides. Veuillez vérifier vos informations et soumettre des documents conformes.';

  @override
  String get attractiveIncome => 'Revenus attractifs';

  @override
  String get attractiveIncomeDesc => 'Fixez vos tarifs et maximisez vos gains';

  @override
  String get totalFreedom => 'Liberté totale';

  @override
  String get totalFreedomDesc => 'Travaillez selon votre emploi du temps';

  @override
  String get guaranteedSafety => 'Sécurité garantie';

  @override
  String get guaranteedSafetyDesc => 'Protection complète pour chaque course';

  @override
  String get verifyingStatus => 'Vérification du statut...';

  @override
  String get myVehicle => 'Mon Véhicule';

  @override
  String get statistics => 'Statistiques';

  @override
  String get driverWallet => 'Portefeuille';

  @override
  String get totalRidesDriver => 'Total Courses';

  @override
  String get averageRating => 'Note Moyenne';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get earnings => 'Revenus';

  @override
  String get historyDriver => 'Historique';

  @override
  String get supportDriver => 'Support';

  @override
  String get onlineMode => 'En Ligne';

  @override
  String get offlineMode => 'Hors Ligne';

  @override
  String get readyToAccept => 'Prêt à accepter des courses';

  @override
  String get activateToReceive => 'Activez pour recevoir des demandes';

  @override
  String get goOnline => 'Passer En Ligne';

  @override
  String get goOffline => 'Passer Hors Ligne';

  @override
  String get noRequests => 'Aucune Demande';

  @override
  String get searchingNearby => 'Recherche de passagers à proximité...';

  @override
  String get notificationsActive => 'Notifications actives';

  @override
  String get offlineStatus => 'Mode Hors Ligne';

  @override
  String get goOnlineToReceive => 'Passez en ligne pour recevoir des demandes';

  @override
  String get activeRequests => 'Demandes Actives';

  @override
  String get counterOfferTitle => 'Envoyer une contre-offre';

  @override
  String get passengerOffer => 'Offre du passager :';

  @override
  String get yourCounterOffer => 'Votre contre-offre';

  @override
  String get enterYourPrice => 'Entrez votre prix';

  @override
  String get fairPriceTip =>
      'Conseil : Proposez un prix juste basé sur la distance et le temps';

  @override
  String get sendOffer => 'Envoyer l\'offre';

  @override
  String get negotiateButton => 'Négocier';

  @override
  String get refuseButton => 'Refuser';

  @override
  String get acceptRide => 'Accepter la course';

  @override
  String get waitingForResponse => 'En Attente de Réponse';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds secondes restantes';
  }

  @override
  String get cancelOffer => 'Annuler l\'Offre';

  @override
  String get registration => 'Immatriculation';

  @override
  String get type => 'Type';

  @override
  String get year => 'Année';

  @override
  String get unknownAddress => 'Adresse inconnue';

  @override
  String get walletTitle => 'Mon Portefeuille';

  @override
  String get overviewTab => 'Vue d\'ensemble';

  @override
  String get codesTab => 'Codes';

  @override
  String get historyTab => 'Historique';

  @override
  String get availableBalance => 'Solde Disponible';

  @override
  String get rechargeWallet => 'Recharger le Portefeuille';

  @override
  String get monthDetails => 'Détails du Mois';

  @override
  String get grossEarnings => 'Gains bruts';

  @override
  String get commissions => 'Commissions';

  @override
  String get netEarnings => 'Revenus nets';

  @override
  String get costPerRide => 'Coût par course';

  @override
  String get effectiveRate => 'Taux effectif';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get recentTransactions => 'Transactions Récentes';

  @override
  String get retry => 'Réessayer';

  @override
  String get currencySymbol => 'DH';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mer';

  @override
  String get thursday => 'Jeu';

  @override
  String get friday => 'Ven';

  @override
  String get saturday => 'Sam';

  @override
  String get sunday => 'Dim';

  @override
  String get transactionTypeCredit => 'Crédit';

  @override
  String get transactionTypeDebit => 'Débit';

  @override
  String get transactionTypeCommission => 'Commission';

  @override
  String get transactionTypeSubscription => 'Abonnement';

  @override
  String get transactionTypeInit => 'Initialisation';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String daysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get perRide => 'Par course';

  @override
  String get totalDebits => 'Total ébits';

  @override
  String get totalCredits => 'Total Crédits';

  @override
  String get netThisMonth => 'Net ce mois-ci';

  @override
  String get totalTransactions => 'Total des transactions';

  @override
  String get generateNewCode => 'Générer un Nouveau Code';

  @override
  String get activeCodes => 'Codes Actifs';

  @override
  String get expiredCodes => 'Codes Expirés';

  @override
  String get noRechargeCodes => 'Aucun code de recharge';

  @override
  String get generateCodeDescription =>
      'Générez un code pour recharger\nvotre portefeuille';

  @override
  String get codeCopied => 'Code copié dans le presse-papiers';

  @override
  String get deleteCodeTitle => 'Supprimer le Code';

  @override
  String get deleteCodeConfirmation =>
      'Êtes-vous sûr de vouloir supprimer ce code de recharge ?';

  @override
  String get codeDeleted => 'Code supprimé';

  @override
  String get active => 'Actif';

  @override
  String get expired => 'Expiré';

  @override
  String get generateCodeOption => 'Générer un Code';

  @override
  String get generateCodeSubtitle => 'Payez en agence avec un code';

  @override
  String get creditCardOption => 'Carte Bancaire';

  @override
  String get creditCardSubtitle => 'Paiement en ligne sécurisé';

  @override
  String get amount => 'Montant (DH)';

  @override
  String get amountHint => 'Ex: 500';

  @override
  String get generateCodeInfo =>
      'Présentez ce code en agence pour effectuer le paiement';

  @override
  String get generate => 'Générer';

  @override
  String get codeGenerated => 'Code Généré';

  @override
  String get presentCodeInfo =>
      'Présentez ce code en agence pour\nrecharger votre portefeuille';

  @override
  String get copyCode => 'Copier le Code';

  @override
  String get cardPaymentTitle => 'Paiement par Carte';

  @override
  String get securePaymentInfo => 'Paiement sécurisé • Rechargement immédiat';

  @override
  String get redirectingPayment => 'Redirection vers le paiement sécurisé...';

  @override
  String get subscriptionsTitle => 'Abonnements';

  @override
  String get plansTab => 'Plans';

  @override
  String get noActiveSubscription => 'Aucun abonnement actif';

  @override
  String get choosePlanPrompt =>
      'Choisissez un plan pour débloquer\ntous les avantages';

  @override
  String get ridesUsed => 'Courses utilisées';

  @override
  String get coursesThisMonth => 'Courses ce mois';

  @override
  String get unlimited => 'ILLIMITÉ';

  @override
  String get subscriptionExpired => 'Abonnement expiré';

  @override
  String expiresInDays(int days) {
    return 'Expire dans $days jours';
  }

  @override
  String renewsInDays(int days) {
    return 'Renouvellement dans $days jours';
  }

  @override
  String get cancelSubscription => 'Annuler l\'abonnement';

  @override
  String get cancelSubscriptionDialog => 'Annuler l\'abonnement?';

  @override
  String cancelSubscriptionWarning(String planName) {
    return 'Votre abonnement $planName sera annulé immédiatement';
  }

  @override
  String get subscriptionCancelled => 'Abonnement annulé';

  @override
  String get choosePlan => 'Choisir un plan';

  @override
  String get popular => 'POPULAIRE';

  @override
  String get current => 'ACTUEL';

  @override
  String get amountPerMonth => 'DH/mois';

  @override
  String get activeSubscription => 'Abonnement Actif';

  @override
  String get changeToPlan => 'Changer vers ce plan';

  @override
  String get chooseThisPlan => 'Choisir ce plan';

  @override
  String get takeAdvantage => '🎉 Profiter de l\'offre';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get confirmSubscription => 'Confirmer l\'abonnement';

  @override
  String subscribeToPlan(String planName) {
    return 'Vous allez souscrire à l\'abonnement $planName';
  }

  @override
  String get newPlan => 'Nouveau plan';

  @override
  String get changeSubscription => 'Changer d\'abonnement';

  @override
  String switchFromTo(String fromPlan, String toPlan) {
    return 'Passer de $fromPlan à $toPlan';
  }

  @override
  String get changeEffectiveImmediately => 'Changement effectif immédiatement';

  @override
  String get subscriptionActivated => 'Abonnement activé!';

  @override
  String get subscriptionChanged => 'Abonnement changé!';

  @override
  String get noHistory => 'Aucun historique';

  @override
  String get historyPrompt => 'Vos abonnements passés\napparaîtront ici';

  @override
  String itemsOfTotal(int count, int total) {
    return '$count / $total';
  }

  @override
  String get period => 'Période';

  @override
  String get comparison => 'Comparaison';

  @override
  String get commission => 'Commission';

  @override
  String get rideLimit => 'Limite courses';

  @override
  String get support => 'Support';

  @override
  String get standard => 'Standard';

  @override
  String get priority => 'Prioritaire';

  @override
  String get vip247 => 'VIP 24/7';

  @override
  String get basic => 'Base';

  @override
  String get advanced => 'Avancées';

  @override
  String get complete => 'Complètes';

  @override
  String get faqTitle => 'Questions fréquentes';

  @override
  String get canChangeSubscription => 'Puis-je changer d\'abonnement?';

  @override
  String get changeSubscriptionAnswer =>
      'Oui, vous pouvez changer à tout moment. Les changements prennent effet immédiatement.';

  @override
  String get exceedLimitQuestion =>
      'Que se passe-t-il si je dépasse ma limite?';

  @override
  String get exceedLimitAnswer =>
      'Pour Basic et Premium, vous ne pourrez plus accepter de courses jusqu\'au renouvellement.';

  @override
  String get howRenewalWorks => 'Comment fonctionne le renouvellement?';

  @override
  String get renewalAnswer =>
      'L\'abonnement se renouvelle automatiquement chaque mois. Vous pouvez annuler à tout moment.';

  @override
  String get canGetRefund => 'Puis-je obtenir un remboursement?';

  @override
  String get refundAnswer =>
      'Remboursement possible dans les 7 jours si aucune course n\'a été effectuée.';

  @override
  String get commissionModel => 'Modèle Commission';

  @override
  String get preferCommission => 'Préférez payer à la commission?';

  @override
  String get commissionExplanation =>
      '8% par course au lieu d\'un abonnement. Idéal pour peu de courses.';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get commissionModalTitle => 'Modèle Commission';

  @override
  String get commissionPerRide => 'Payez 8% de commission par course';

  @override
  String get commissionFeature1 => '8% de commission par course';

  @override
  String get commissionFeature2 => 'Aucun frais mensuel';

  @override
  String get commissionFeature3 => 'Courses illimitées';

  @override
  String get commissionExample => 'Ex: Course 100 DH → 8 DH commission';

  @override
  String get activate => 'Activer';

  @override
  String daysForMonth(int days) {
    return '$days jours pour 1 mois';
  }

  @override
  String get specialOffer =>
      'Offre exceptionnelle pour votre\npremier abonnement!';

  @override
  String get errorLoadingPlans => 'Erreur lors du chargement des plans';

  @override
  String get errorSubscription => 'Erreur lors de l\'activation';

  @override
  String get errorCancellation => 'Erreur lors de l\'annulation';

  @override
  String get errorChanging => 'Erreur lors du changement d\'abonnement';

  @override
  String get errorLoadingHistory =>
      'Erreur lors du chargement de l\'historique';

  @override
  String get rideLimitBasic => '60 courses/mois';

  @override
  String get rideLimitPremium => '150 courses/mois';

  @override
  String get rideLimitPro => 'Courses illimitées';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsMarkedAsRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get notificationsMarkError =>
      'Erreur lors du marquage des notifications';

  @override
  String get notificationsNoNotifications => 'Aucune notification';

  @override
  String get notificationsNoNotificationsMessage =>
      'Vous n\'avez pas encore reçu\nde notifications';

  @override
  String get notificationsLoading => 'Chargement des notifications...';

  @override
  String get notificationsLoadingMore => 'Chargement...';

  @override
  String notificationsPaginationInfo(int current, int total) {
    return '$current sur $total notifications';
  }

  @override
  String get arrivedAtPickup => 'Je suis arrivé';

  @override
  String get startingRide => 'Démarrer la course';

  @override
  String get finishRide => 'Terminer la course';

  @override
  String get coming => 'J\'arrive!';

  @override
  String get time => 'Temps';

  @override
  String etaMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get rideInitilisation => 'Initialisation de la course...';

  @override
  String get sendEvaluation => 'Envoyer l\'évaluation';

  @override
  String rateUser(String user) {
    return 'Noter $user';
  }

  @override
  String get thankYouForYourFeedback => 'Merci pour votre évaluation!';

  @override
  String get navigate => 'Naviguer';

  @override
  String get call => 'Appeler';

  @override
  String get message => 'Message';

  @override
  String get cancelRide => 'Annuler la course';

  @override
  String get confirmationSentToPassenger => 'Confirmation envoyée au passager';

  @override
  String get rideStarted => 'Course démarrée - Direction: Destination';

  @override
  String get phoneNotAvailable => 'Numéro de téléphone non disponible';

  @override
  String get cannotOpenPhoneApp =>
      'Impossible d\'ouvrir l\'application téléphone';

  @override
  String get userInfoNotAvailable => 'Informations utilisateur non disponibles';

  @override
  String get userNotAuthenticated => 'Utilisateur non authentifié';

  @override
  String get locationNotAvailable => 'Localisation pas encore disponible';

  @override
  String get cannotOpenNavigation =>
      'Impossible d\'ouvrir l\'application de navigation';

  @override
  String get rideInfoNotAvailable => 'Informations de course non disponibles';

  @override
  String get rideCancelled => 'Course annulée';

  @override
  String get cancellationError => 'Erreur lors de l\'annulation';

  @override
  String get ratingError => 'Erreur lors de la soumission';

  @override
  String get pressAgainToExit =>
      'Appuyez à nouveau pour quitter l\'application';
}
