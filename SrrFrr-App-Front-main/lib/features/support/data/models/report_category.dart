enum ReportCategory {
  technique,
  administrative,
  facturation,
  generale,
  autre;

  String get value => name.toUpperCase();

  String get displayName {
    switch (this) {
      case ReportCategory.technique:
        return 'Technique';
      case ReportCategory.administrative:
        return 'Administrative';
      case ReportCategory.facturation:
        return 'Facturation';
      case ReportCategory.generale:
        return 'Générale';
      case ReportCategory.autre:
        return 'Autre';
    }
  }

  static ReportCategory fromString(String value) {
    return ReportCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ReportCategory.generale,
    );
  }

  static List<ReportCategory> get all => ReportCategory.values;
}
