import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class ReviewerRemoteDs {
  final Dio _dio;

  const ReviewerRemoteDs(this._dio);

  Future<List<dynamic>> getAssignedColleges() async {
    try {
      final res = await _dio.get(ApiEndpoints.qualityColleges);
      if (res.data is List) {
        return res.data as List<dynamic>;
      }
      return <dynamic>[];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> getCollegeDetails(int collegeId) async {
    try {
      final res = await _dio.get(ApiEndpoints.qualityCollegeById(collegeId));
      if (res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<List<dynamic>> getSectionFiles(
    int collegeId,
    int sectionId,
  ) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.qualityFiles(collegeId, sectionId));
      if (res.data is List) {
        return res.data as List<dynamic>;
      }
      return <dynamic>[];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> submitDecision(
    int collegeId,
    String status,
    String notes,
  ) async {
    try {
      await _dio.post(ApiEndpoints.qualityDecision(collegeId), data: {
        'status': status,
        'notes': notes,
      });
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
