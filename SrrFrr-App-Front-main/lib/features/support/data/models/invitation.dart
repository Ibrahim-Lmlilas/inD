import 'invitation_status.dart';

class Invitation {
  final String? id;
  final String phoneNumber;
  final DateTime? sentAt;
  final InvitationStatus? status;

  Invitation({this.id, required this.phoneNumber, this.sentAt, this.status});

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      status: json['status'] != null
          ? InvitationStatus.fromString(json['status'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'phoneNumber': phoneNumber,
      if (sentAt != null) 'sentAt': sentAt!.toIso8601String(),
      if (status != null) 'status': status!.value,
    };
  }
}
