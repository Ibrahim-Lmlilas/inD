// Input Validators
//
// Centralized validation logic for all user inputs across the application.
// Eliminates scattered validation code and provides consistent error messages.

class InputValidators {
  InputValidators._();

  // Constants
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int maxEmailLength = 100;
  static const int minPhoneLength = 8;

  // MARK: - Name Validation

  // Validate name (first name or last name)
  static bool validateName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 2 &&
        trimmed.length <= maxNameLength &&
        !trimmed.contains(RegExp(r'[0-9]')); // No numbers
  }

  static String? getNameError(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Ce champ est requis';
    if (trimmed.length < 2) return 'Minimum 2 caractères';
    if (trimmed.length > maxNameLength)
      return 'Maximum $maxNameLength caractères';
    if (trimmed.contains(RegExp(r'[0-9]'))) return 'Aucun chiffre autorisé';
    return null;
  }

  // MARK: - Password Validation

  // Validate password with all security requirements
  static bool validatePassword(String password) {
    return password.length >= minPasswordLength &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  // Get specific password error message
  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < minPasswordLength) {
      return 'Minimum $minPasswordLength caractères';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule requise';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Au moins une minuscule requise';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Au moins un chiffre requis';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Au moins un caractère spécial requis';
    }
    return null;
  }

  // Check password strength (0-5)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= minPasswordLength) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 5 ? 5 : strength;
  }

  // Validate password confirmation
  static bool validatePasswordConfirmation(
    String password,
    String confirmation,
  ) {
    return password.isNotEmpty && password == confirmation;
  }

  static String? getPasswordConfirmationError(
    String password,
    String confirmation,
  ) {
    if (confirmation.isEmpty) return 'Confirmation requise';
    if (password != confirmation)
      return 'Les mots de passe ne correspondent pas';
    return null;
  }

  // MARK: - Phone Number Validation

  // Validate phone number (Moroccan format)
  static bool validatePhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= minPhoneLength &&
        cleanPhone.length <= maxPhoneLength;
  }

  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Numéro de téléphone requis';
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < minPhoneLength) {
      return 'Numéro trop court (min $minPhoneLength chiffres)';
    }
    if (cleanPhone.length > maxPhoneLength) {
      return 'Numéro trop long (max $maxPhoneLength chiffres)';
    }
    return null;
  }

  // Clean phone number (remove non-digits)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Format phone number for display (+212 XXX XXX XXX)
  static String formatPhoneNumber(String phone) {
    final clean = cleanPhoneNumber(phone);
    if (clean.length >= 9) {
      return '+212 ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return '+212 $clean';
  }

  // MARK: - Email Validation

  // Validate email format (optional field)
  static bool validateEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    if (email.length > maxEmailLength) return false;

    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? getEmailError(String email) {
    if (email.isEmpty) return null; // Email is optional
    if (email.length > maxEmailLength) {
      return 'Email trop long (max $maxEmailLength caractères)';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  // MARK: - Input Sanitization

  // Sanitize user input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  // Sanitize and limit length
  static String sanitizeAndLimit(String input, int maxLength) {
    final sanitized = sanitizeInput(input);
    return sanitized.length > maxLength
        ? sanitized.substring(0, maxLength)
        : sanitized;
  }

  // MARK: - Comprehensive Validation

  // Validate all registration fields at once
  static ValidationResult validateRegistration({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
    String? email,
    bool? termsAccepted,
  }) {
    final errors = <String, String>{};

    // First name
    final firstNameError = getNameError(firstName);
    if (firstNameError != null) errors['firstName'] = firstNameError;

    // Last name
    final lastNameError = getNameError(lastName);
    if (lastNameError != null) errors['lastName'] = lastNameError;

    // Phone
    final phoneError = getPhoneError(phone);
    if (phoneError != null) errors['phone'] = phoneError;

    // Password
    final passwordError = getPasswordError(password);
    if (passwordError != null) errors['password'] = passwordError;

    // Confirm password
    final confirmError = getPasswordConfirmationError(
      password,
      confirmPassword,
    );
    if (confirmError != null) errors['confirmPassword'] = confirmError;

    // Email (optional)
    if (email != null && email.isNotEmpty) {
      final emailError = getEmailError(email);
      if (emailError != null) errors['email'] = emailError;
    }

    // Terms
    if (termsAccepted != null && !termsAccepted) {
      errors['terms'] = 'Vous devez accepter les conditions';
    }

    return ValidationResult(errors);
  }

  // Validate login fields
  static ValidationResult validateLogin({
    required String phone,
    required String password,
  }) {
    final errors = <String, String>{};

    final phoneError = getPhoneError(phone);
    if (phoneError != null) errors['phone'] = phoneError;

    if (password.isEmpty) {
      errors['password'] = 'Mot de passe requis';
    }

    return ValidationResult(errors);
  }
}

// Validation result container
class ValidationResult {
  final Map<String, String> errors;

  ValidationResult(this.errors);

  // Check if validation passed
  bool get isValid => errors.isEmpty;

  // Check if validation failed
  bool get hasErrors => errors.isNotEmpty;

  // Get error for specific field
  String? getError(String field) => errors[field];

  // Check if specific field has error
  bool hasError(String field) => errors.containsKey(field);

  // Get all error messages as list
  List<String> get errorMessages => errors.values.toList();

  // Get first error message
  String? get firstError => errors.isEmpty ? null : errors.values.first;

  @override
  String toString() => errors.isEmpty
      ? 'Validation passed'
      : 'Validation failed: ${errors.length} error(s)';
}
