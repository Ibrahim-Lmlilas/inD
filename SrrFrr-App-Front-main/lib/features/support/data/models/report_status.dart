enum ReportStatus {
  pending,
  inProgress,
  resolved,
  closed;

  String get value => name.toUpperCase();

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ReportStatus.pending,
    );
  }
}
