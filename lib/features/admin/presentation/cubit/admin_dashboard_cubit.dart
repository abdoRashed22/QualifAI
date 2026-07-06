import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_dashboard_state.dart';

// ─── CUBIT ─────────────────────────────────────────────────────────
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final Dio _dio;

  AdminDashboardCubit(this._dio) : super(AdminDashboardLoading());

  Future<void> loadData() async {
    emit(AdminDashboardLoading());
    try {
      // Execute all API calls concurrently
      final responses = await Future.wait([
        _dio.get('/Colleges'),
        _dio.get('/Notification/unread-count'),
        _dio.get('/Quality/colleges'),
        _dio.get('/Subscription'),
        _dio.get('/ActivityLog'),
      ]);

      // 1. Colleges Count
      int collegesCount = _parseListLength(responses[0].data);

      // 2. Unread Notifications
      int unreadNotifications = _parseCount(responses[1].data);

      // 3. Pending Reviews
      int pendingReviewsCount = _parseListLength(responses[2].data);

      // 4. Subscriptions
      List<dynamic> subscriptions = _parseList(responses[3].data);

      // 5. Activity Log
      List<dynamic> activityLog = _parseList(responses[4].data);

      emit(AdminDashboardLoaded(
        collegesCount: collegesCount,
        unreadNotifications: unreadNotifications,
        pendingReviewsCount: pendingReviewsCount,
        subscriptions: subscriptions,
        activityLog: activityLog,
      ));
    } catch (e) {
      emit(const AdminDashboardError(
          'تعذر تحميل بيانات لوحة التحكم. تأكد من اتصالك.'));
    }
  }

  // Safe Parsing Helpers
  int _parseListLength(dynamic data) {
    if (data is List) return data.length;
    if (data is Map) {
      if (data['data'] is List) return (data['data'] as List).length;
      if (data['result'] is List) return (data['result'] as List).length;
    }
    return 0;
  }

  List<dynamic> _parseList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['result'] is List) return data['result'] as List;
    }
    return [];
  }

  int _parseCount(dynamic data) {
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    if (data is Map) {
      if (data['count'] != null)
        return int.tryParse(data['count'].toString()) ?? 0;
      if (data['unreadCount'] != null)
        return int.tryParse(data['unreadCount'].toString()) ?? 0;
      if (data['data'] != null)
        return int.tryParse(data['data'].toString()) ?? 0;
    }
    return 0;
  }
}
