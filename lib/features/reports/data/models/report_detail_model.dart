class ReportDetailModel {
  final String name;
  final double completionRatio;
  final String aiAnalysis;
  final String reviewerFeedback;
  final String requiredRevisions;

  const ReportDetailModel({
    required this.name,
    required this.completionRatio,
    required this.aiAnalysis,
    required this.reviewerFeedback,
    required this.requiredRevisions,
  });
}
