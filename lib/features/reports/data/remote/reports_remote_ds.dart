// lib/features/reports/data/remote/reports_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

/// Reports Remote Data Source
/// Fetches reports from the backend API.
/// Primary endpoint: GET /api/Reports/ui (for UI display)
/// Fallback: GET /api/Accreditation/sections (if UI endpoint not available)
class ReportsRemoteDs {
  final Dio _dio;
  const ReportsRemoteDs(this._dio);

  Future<List<dynamic>> getReports() async {
    try {
      // Try the UI endpoint first (designed for UI display with proper calculations)
      try {
        print('📤 [REPORTS] Fetching reports from /Reports/ui');
        final res = await _dio.get(ApiEndpoints.reportsUi);
        if (res.data is List) {
          final list = res.data as List;
          if (list.isNotEmpty) {
            print(
                '📥 [REPORTS] Received ${list.length} reports from /Reports/ui');
            return list;
          }
        }
      } catch (e) {
        print(
            '⚠️  [REPORTS] /Reports/ui endpoint not available, falling back to sections: $e');
      }

      // Fallback to sections endpoint
      print(
          '📤 [REPORTS] Fetching reports from /Accreditation/sections (fallback)');
      final res = await _dio.get(ApiEndpoints.sections);
      if (res.data is List) {
        final list = res.data as List;
        print('📥 [REPORTS] Received ${list.length} sections as reports');
        return list;
      }
      return [];
    } on DioException catch (e) {
      print('❌ [REPORTS] Error fetching reports: ${e.message}');
      print('❌ [REPORTS] Status: ${e.response?.statusCode}');
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> getReportDetail(int sectionId) async {
    try {
      print('📤 [REPORTS] Fetching report detail for section $sectionId');
      final res = await _dio.get(ApiEndpoints.sectionById(sectionId));
    final result = res.data is Map ? Map<String, dynamic>.from(res.data) : <String, dynamic>{};

      print(
          '📥 [REPORTS] Successfully fetched report detail for section $sectionId');
      return result;
    } on DioException catch (e) {
      print('❌ [REPORTS] Error fetching report detail: ${e.message}');
      print('❌ [REPORTS] Status: ${e.response?.statusCode}');
      throw dioToFailure(e);
    }
  }

  /// Get reports for a specific college
  Future<List<dynamic>> getReportsByCollege(int collegeId) async {
    try {
      final res = await _dio.get(ApiEndpoints.reportsByCollege(collegeId));
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  /// Download report for a college
  Future<dynamic> downloadReport(int collegeId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.reportDownload(collegeId),
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data;
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
