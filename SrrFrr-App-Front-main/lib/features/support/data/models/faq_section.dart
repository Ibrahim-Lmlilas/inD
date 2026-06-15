import 'faq_item.dart';

class FaqSection {
  final String title;
  final String icon;
  final List<FaqItem> items;

  FaqSection({required this.title, required this.icon, required this.items});

  factory FaqSection.fromJson(Map<String, dynamic> json) {
    return FaqSection(
      title: json['title'] as String,
      icon: json['icon'] as String,
      items:
          (json['items'] as List?)
              ?.map((item) => FaqItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
