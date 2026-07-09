class ReportListItemModel {
  final int id;
  final String name;
  final int uploadedDocuments;
  final int requiredDocumentsCount;
  final String collegeName;
  final int collegeId;
  final String status;

  const ReportListItemModel({
    required this.id,
    required this.name,
    required this.uploadedDocuments,
    required this.requiredDocumentsCount,
    required this.collegeName,
    required this.collegeId,
    required this.status,
  });

  double get completionRatio {
    if (requiredDocumentsCount <= 0) return 0.0;
    final ratio = uploadedDocuments / requiredDocumentsCount;
    if (ratio.isNaN) return 0.0;
    return ratio.clamp(0.0, 1.0);
  }
}
