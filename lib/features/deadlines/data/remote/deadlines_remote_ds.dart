// lib/features/deadlines/data/remote/deadlines_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class DeadlinesRemoteDs {
  final Dio _dio;
  const DeadlinesRemoteDs(this._dio);

  Future<List<dynamic>> getDeadlines() async {
    try {
      final res = await _dio.get(ApiEndpoints.deadlines);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> setDeadline(
    int docId,
    String deadline,
    bool remindOneWeek,
    bool remindOneDay,
    bool remindOnDue,
  ) async {
    try {
      await _dio.post(ApiEndpoints.setDeadline(docId), data: {
        'requiredDocumentId': docId,
        'deadline': deadline,
        'reminders': {
          'one_week': remindOneWeek,
          'one_day': remindOneDay,
          'on_due': remindOnDue
        }
      });
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
