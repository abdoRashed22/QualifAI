import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class SupportRemoteDs {
  final Dio _dio;

  const SupportRemoteDs(this._dio);

  Future<void> submitSupport(String name, String email, String message) async {
    try {
      await _dio.post(ApiEndpoints.supportSubmit, data: {
        'name': name,
        'email': email,
        'message': message,
      });
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
