enum AppTheme {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppTheme.light:
        return 'Clair';
      case AppTheme.dark:
        return 'Sombre';
      case AppTheme.system:
        return 'Système';
    }
  }

  static AppTheme fromString(String value) {
    return AppTheme.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AppTheme.light,
    );
  }

  static List<AppTheme> get all => AppTheme.values;
}
