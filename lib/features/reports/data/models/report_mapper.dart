import 'report_detail_model.dart';
import 'report_list_item_model.dart';

class ReportMapper {
  static ReportListItemModel mapListItem(Map<String, dynamic> s) {
    final rawId =
        s['id'] ?? s['Id'] ?? s['reportId'] ?? s['ReportId'] ?? s['sectionId'];
    final id = int.tryParse(rawId?.toString() ?? '') ?? 0;

    final uploaded =
        s['completedDocs'] ?? s['CompletedDocs'] ?? s['uploadedDocuments'] ?? 0;
    final total =
        s['totalDocs'] ?? s['TotalDocs'] ?? s['requiredDocumentsCount'] ?? 1;

    final name = s['originalName'] ??
        s['title'] ??
        s['Title'] ??
        s['name'] ??
        s['Name'] ??
        s['sectionName'] ??
        s['collegeName'] ??
        'تقرير';

    final collegeName = (s['collegeName'] ?? '').toString();
    final collegeId = int.tryParse(s['collegeId']?.toString() ?? '0') ?? 0;

    final status = (s['status'] ?? 'قيد المراجعة').toString();

    return ReportListItemModel(
      id: id,
      name: name.toString(),
      uploadedDocuments: uploaded as int,
      requiredDocumentsCount: total as int,
      collegeName: collegeName,
      collegeId: collegeId,
      status: status,
    );
  }

  static List<ReportListItemModel> mapListResponse(List<dynamic> list) {
    final mapped = <ReportListItemModel>[];

    for (final raw in list.whereType<Map>()) {
      final s = Map<String, dynamic>.from(raw);

      if (s.containsKey('reports') && s['reports'] is List) {
        final collegeName = s['collegeName'] ?? 'كلية';
        for (final nested in (s['reports'] as List).whereType<Map>()) {
          final nestedItem = Map<String, dynamic>.from(nested);
          nestedItem['collegeName'] ??= collegeName;
          mapped.add(mapListItem(nestedItem));
        }
      } else {
        mapped.add(mapListItem(s));
      }
    }

    return mapped;
  }

  static ReportDetailModel mapDetail(Map<String, dynamic> r) {
    final rawCompletion = r['completionDegree'];
    final rawPct = r['completionPercentage'];

    final completionRatio = (rawCompletion is num
            ? rawCompletion.toDouble()
            : (rawPct is num ? rawPct.toDouble() / 100 : 0.0))
        .clamp(0.0, 1.0);

    final aiAnalysis =
        (r['aiAnalysis'] ?? 'لم يتم إتمام التحليل بعد').toString();

    final reviewerFeedback = (r['reviewerFeedback'] ??
            r['reviewerAssessment'] ??
            'لا توجد ملاحظات من المراجع حتى الآن')
        .toString();

    final requiredRevisions =
        (r['requiredRevisions'] ?? 'لا توجد تعديلات مطلوبة').toString();

    final name = (r['name'] ?? 'تقرير').toString();

    return ReportDetailModel(
      name: name,
      completionRatio: completionRatio,
      aiAnalysis: aiAnalysis,
      reviewerFeedback: reviewerFeedback,
      requiredRevisions: requiredRevisions,
    );
  }
}
