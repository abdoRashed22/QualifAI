// lib/features/dashboard/data/remote/dashboard_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class DashboardRemoteDs {
  final Dio _dio;
  const DashboardRemoteDs(this._dio);

  Future<Map<String, dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      return {'sections': res.data};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadCount);
      return res.data is int ? res.data : (res.data['count'] ?? 0);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}
