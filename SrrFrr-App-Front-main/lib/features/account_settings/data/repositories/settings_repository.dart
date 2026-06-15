// Settings Repository
// Handles persistent storage and retrieval of app settings

import 'package:shared_preferences/shared_preferences.dart';
import 'package:srrfrr_app_front/features/account_settings/data/models/account_models.dart';
import 'package:srrfrr_app_front/shared/models/user.dart';

class SettingsRepository {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyLanguage = 'app_language';
  static const String _keyTheme = 'app_theme';

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return NotificationSettings(
      fullyEnabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
      soundEnabled: prefs.getBool(_keySoundEnabled) ?? true,
      vibrationEnabled: prefs.getBool(_keyVibrationEnabled) ?? true,
    );
  }

  // Save notification settings
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool(_keyNotificationsEnabled, settings.fullyEnabled),
      prefs.setBool(_keySoundEnabled, settings.soundEnabled),
      prefs.setBool(_keyVibrationEnabled, settings.vibrationEnabled),
    ]);
  }

  // Update individual notification setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrationEnabled, enabled);
  }

  // Language settings
  Future<Language> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLanguage);
    return code != null ? LanguageExtension.fromBackend(code) : Language.french;
  }

  Future<void> setLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language.toBackend());
  }

  // Theme settings
  Future<AppTheme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_keyTheme);
    return theme != null ? AppTheme.fromString(theme) : AppTheme.light;
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme.name);
  }

  // Get all settings
  Future<AppSettings> getAllSettings() async {
    final notifications = await getNotificationSettings();
    final language = await getLanguage();
    final theme = await getTheme();

    return AppSettings(
      language: language,
      theme: theme,
      interfaceType: InterfaceType.regular, // From user profile
      notifications: notifications,
    );
  }

  // Save all settings
  Future<void> saveAllSettings(AppSettings settings) async {
    await Future.wait([
      saveNotificationSettings(settings.notifications),
      setLanguage(settings.language),
      setTheme(settings.theme),
    ]);
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyNotificationsEnabled),
      prefs.remove(_keySoundEnabled),
      prefs.remove(_keyVibrationEnabled),
      prefs.remove(_keyLanguage),
      prefs.remove(_keyTheme),
    ]);
  }
}
