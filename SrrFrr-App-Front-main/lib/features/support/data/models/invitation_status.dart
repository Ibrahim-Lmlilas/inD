enum InvitationStatus {
  sent,
  accepted,
  expired;

  String get value => name.toUpperCase();

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => InvitationStatus.sent,
    );
  }
}
