import 'package:srrfrr_app_front/shared/models/user.dart';
import 'app_theme.dart';
import 'notification_settings.dart';

class AppSettings {
  final Language language;
  final AppTheme theme;
  final InterfaceType interfaceType;
  final NotificationSettings notifications;

  AppSettings({
    required this.language,
    required this.theme,
    required this.interfaceType,
    required this.notifications,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      language: Language.french,
      theme: AppTheme.light,
      interfaceType: InterfaceType.regular,
      notifications: NotificationSettings(
        fullyEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
      ),
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] != null
          ? LanguageExtension.fromBackend(json['language'] as String)
          : Language.french,
      theme: json['theme'] != null
          ? AppTheme.fromString(json['theme'] as String)
          : AppTheme.light,
      interfaceType: json['interfaceType'] != null
          ? InterfaceType.fromString(json['interfaceType'] as String)
          : InterfaceType.regular,
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(
              json['notifications'] as Map<String, dynamic>,
            )
          : NotificationSettings(
              fullyEnabled: true,
              soundEnabled: true,
              vibrationEnabled: true,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language.code,
      'theme': theme.name,
      'interfaceType': interfaceType.name,
      'notifications': notifications.toJson(),
    };
  }

  AppSettings copyWith({
    Language? language,
    AppTheme? theme,
    InterfaceType? interfaceType,
    NotificationSettings? notifications,
  }) {
    return AppSettings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      interfaceType: interfaceType ?? this.interfaceType,
      notifications: notifications ?? this.notifications,
    );
  }
}
