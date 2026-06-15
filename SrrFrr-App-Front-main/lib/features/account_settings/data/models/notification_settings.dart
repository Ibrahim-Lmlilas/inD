class NotificationSettings {
  final bool fullyEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    required this.fullyEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      fullyEnabled: json['fullyEnabled'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullyEnabled': fullyEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? fullyEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      fullyEnabled: fullyEnabled ?? this.fullyEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
