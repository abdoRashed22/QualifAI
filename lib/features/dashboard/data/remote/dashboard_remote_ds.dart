// lib/features/dashboard/data/remote/dashboard_remote_ds.dart

import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';

import '../../../../core/data/accreditation_data.dart';

import '../../../../core/errors/failures.dart';

class DashboardRemoteDs {
  final Dio _dio;

  const DashboardRemoteDs(this._dio);

  Future<Map<String, dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      final sections = res.data;

      if (sections is List) {
        return {'sections': sections};
      }

      return {'sections': []};
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  List<dynamic> _getLocalSections() {
    final List<dynamic> sections = [];
    for (final entry in accreditationData.entries) {
      final data = entry.value;
      final standards = data['standards'] as List? ?? [];
      for (final standard in standards) {
        sections.add({
          'id': standard['id'],
          'sectionId': standard['sectionId'],
          'name': standard['name'],
          'completedDocs': standard['completedDocs'] ?? 0,
          'totalDocs': standard['totalDocs'] ?? 0,
          'accreditationType': entry.key,
        });
      }
    }
    return sections;
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadCount);
      return res.data is int ? res.data : (res.data['count'] ?? 0);
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

}
