// lib/features/notifications/data/remote/notification_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class NotificationRemoteDs {
  final Dio _dio;
  const NotificationRemoteDs(this._dio);

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await _dio.get(ApiEndpoints.notifications);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadCount);
      if (res.data is int) return res.data;
      return res.data?['count'] ?? 0;
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiEndpoints.markAllRead);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}
