// lib/features/reports/data/remote/reports_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';

/// NOTE: The Swagger does not have a dedicated /Reports endpoint.
/// Reports are derived from Accreditation sections + AI analysis results.
/// This DS aggregates section data to build report-like views.
/// When backend adds a reports endpoint, update the paths here.
class ReportsRemoteDs {
  final Dio _dio;
  const ReportsRemoteDs(this._dio);

  Future<List<dynamic>> getReports() async {
    try {
      // Using sections as report source â€” each section IS a report unit
      final res = await _dio.get('/Accreditation/sections');
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<Map<String, dynamic>> getReportDetail(int sectionId) async {
    try {
      final res = await _dio.get('/Accreditation/sections/$sectionId');
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}
