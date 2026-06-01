// lib/features/reports/data/remote/reports_remote_ds.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

/// Reports Remote Data Source
/// Fetches reports from the backend API.
/// Primary endpoint: GET /api/Reports/ui (for UI display)
/// Fallback: GET /api/Accreditation/sections (if UI endpoint not available)
class ReportsRemoteDs {
  final Dio _dio;
  const ReportsRemoteDs(this._dio);

  /// Fetch all reports across the system (For Quality Manager)
  Future<List<dynamic>> getAllReports() async {
    try {
      print('📤 [REPORTS] Fetching all reports (Manager) from /Reports/all');
      final res = await _dio.get(ApiEndpoints.reportsAll);
      if (res.data is List) {
        final list = res.data as List;
        print('📥 [REPORTS] Received ${list.length} reports');
        return list;
      }
      return [];
    } on DioException catch (e) {
      print('❌ [REPORTS] Error fetching reports: ${e.message}');
      throw dioToFailure(e);
    }
  }

  /// Fetch own reports (For Quality Employee)
  Future<List<dynamic>> getMyReports() async {
    try {
      print('📤 [REPORTS] Fetching my reports (Employee) from /Reports/my');
      final res = await _dio.get(ApiEndpoints.reportsMy);
      if (res.data is List) {
        final list = res.data as List;
        print('📥 [REPORTS] Received ${list.length} reports');
        return list;
      }
      return [];
    } on DioException catch (e) {
      print('❌ [REPORTS] Error fetching reports: ${e.message}');
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> getReportDetail(int reportId) async {
    try {
      print('📤 [REPORTS] Fetching report detail for report $reportId');
      final res = await _dio.get(ApiEndpoints.reportDetail(reportId));
      final result = res.data is Map
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};

      print(
          '📥 [REPORTS] Successfully fetched report detail for report $reportId');
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

  Future<Map<String, dynamic>> uploadReport(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();

      final contentType = switch (ext) {
        'pdf' => MediaType('application', 'pdf'),
        'doc' => MediaType('application', 'msword'),
        'docx' => MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document'),
        _ => MediaType('application', 'octet-stream'),
      };

      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: contentType,
        ),
      });

      final res = await _dio.post('/Reports/upload', data: form);
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> deleteReport(int reportId) async {
    try {
      print('📤 [REPORTS] Deleting report $reportId');
      await _dio.delete('/api/Reports/$reportId');
      print('📥 [REPORTS] Successfully deleted report $reportId');
    } on DioException catch (e) {
      print('❌ [REPORTS] Error deleting report: ${e.message}');
      throw dioToFailure(e);
    }
  }
}
