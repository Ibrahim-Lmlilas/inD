import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';
import 'package:srrfrr_app_front/features/account_settings/data/repositories/settings_repository.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class LanguageProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  Language? _currentLanguage;
  bool _isLoading = true;

  LanguageProvider({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository() {
    _loadLanguage();
  }

  Language? get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;

  Locale? get locale {
    if (_currentLanguage == null) return null;
    return Locale(_currentLanguage!.code);
  }

  Future<void> _loadLanguage() async {
    try {
      _currentLanguage = await _repository.getLanguage();
      _isLoading = false;
      notifyListeners();
      logSuccess(
        '[LanguageProvider]',
        'Language loaded: ${_currentLanguage?.code}',
      );
    } catch (e) {
      logError('[LanguageProvider]', 'Error loading language: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Language language) async {
    try {
      await _repository.setLanguage(language);
      _currentLanguage = language;
      notifyListeners();
      logSuccess('[LanguageProvider]', 'Language changed to: ${language.code}');
    } catch (e) {
      logError('[LanguageProvider]', 'Error changing language: $e');
      rethrow;
    }
  }

  Future<void> clearLanguage() async {
    try {
      _currentLanguage = null;
      await _repository.setLanguage(Language.french);
      notifyListeners();
      logSuccess('[LanguageProvider]', 'Language reset to system default');
    } catch (e) {
      logError('[LanguageProvider]', 'Error clearing language: $e');
    }
  }
}