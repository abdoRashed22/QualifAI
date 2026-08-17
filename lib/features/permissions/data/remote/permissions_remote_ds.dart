import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class PermissionsRemoteDs {
  final Dio _dio;

  const PermissionsRemoteDs(this._dio);

  Future<List<dynamic>> getPermissions() async {
    try {
      final r = await _dio.get(ApiEndpoints.permissions);
      return r.data is List ? r.data : [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
