// Notification Model
// Maps to: com.srrfrr.api.dto.NotificationResponse

library;

import 'notification_type.dart';

class AppNotification {
  final String id;
  
  // Multilingual fields
  final String titleAR;
  final String titleFR;
  final String titleEN;
  final String contentAR;
  final String contentFR;
  final String contentEN;
  
  final NotificationType type;
  final String category; // DRIVER, PASSENGER, or ACCOUNT
  final String status; // UNREAD or READ
  final DateTime createdAt;
  final String? receiverId;

  AppNotification({
    required this.id,
    required this.titleAR,
    required this.titleFR,
    required this.titleEN,
    required this.contentAR,
    required this.contentFR,
    required this.contentEN,
    required this.type,
    required this.category,
    required this.status,
    required this.createdAt,
    this.receiverId,
  });

  // Create from backend JSON response
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      titleAR: json['titleAR'] ?? json['title_ar'] ?? '',
      titleFR: json['titleFR'] ?? json['title_fr'] ?? '',
      titleEN: json['titleEN'] ?? json['title_en'] ?? '',
      contentAR: json['contentAR'] ?? json['content_ar'] ?? '',
      contentFR: json['contentFR'] ?? json['content_fr'] ?? '',
      contentEN: json['contentEN'] ?? json['content_en'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'UNKNOWN'),
      category: json['category'] ?? 'UNKNOWN',
      status: json['status'] ?? 'UNREAD',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      receiverId: json['receiverId'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleAR': titleAR,
      'titleFR': titleFR,
      'titleEN': titleEN,
      'contentAR': contentAR,
      'contentFR': contentFR,
      'contentEN': contentEN,
      'type': type.value,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'receiverId': receiverId,
    };
  }

  // Get localized title based on language code
  String getTitle(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return titleAR;
      case 'en':
        return titleEN;
      case 'fr':
      default:
        return titleFR;
    }
  }

  // Get localized content based on language code
  String getContent(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return contentAR;
      case 'en':
        return contentEN;
      case 'fr':
      default:
        return contentFR;
    }
  }

  // Check if notification is unread
  bool get isUnread => status.toUpperCase() == 'UNREAD';

  // Check if notification is read
  bool get isRead => status.toUpperCase() == 'READ';

  // Check if notification belongs to passenger
  bool get isPassengerNotification => category == 'PASSENGER';

  // Check if notification belongs to driver
  bool get isDriverNotification => category == 'DRIVER';

  // Check if notification is account-related
  bool get isAccountNotification => category == 'ACCOUNT';

  // Create a copy with updated fields
  AppNotification copyWith({
    String? id,
    String? titleAR,
    String? titleFR,
    String? titleEN,
    String? contentAR,
    String? contentFR,
    String? contentEN,
    NotificationType? type,
    String? category,
    String? status,
    DateTime? createdAt,
    String? receiverId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titleAR: titleAR ?? this.titleAR,
      titleFR: titleFR ?? this.titleFR,
      titleEN: titleEN ?? this.titleEN,
      contentAR: contentAR ?? this.contentAR,
      contentFR: contentFR ?? this.contentFR,
      contentEN: contentEN ?? this.contentEN,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      receiverId: receiverId ?? this.receiverId,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, type: ${type.value}, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}