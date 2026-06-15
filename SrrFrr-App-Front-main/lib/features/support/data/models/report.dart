import 'report_status.dart';
import 'report_category.dart';

class Report {
  final String? id;
  final String content;
  final String category;
  final String? rideId;
  final DateTime? createdAt;
  final ReportStatus? status;

  Report({
    this.id,
    required this.content,
    required this.category,
    this.rideId,
    this.createdAt,
    this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String?,
      content: json['content'] as String,
      category: json['category'] as String,
      rideId: json['rideId'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      status: json['status'] != null 
          ? ReportStatus.fromString(json['status'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'category': category,
      if (rideId != null && rideId!.isNotEmpty) 'rideId': rideId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (status != null) 'status': status!.value,
    };
  }

  Report copyWith({
    String? id,
    String? content,
    String? category,
    String? rideId,
    DateTime? createdAt,
    ReportStatus? status,
  }) {
    return Report(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      rideId: rideId ?? this.rideId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}