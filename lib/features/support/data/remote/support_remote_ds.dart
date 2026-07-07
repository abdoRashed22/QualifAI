import 'package:dio/dio.dart';
import 'package:qualif_ai/core/api/api_endpoints.dart';
import 'package:qualif_ai/core/errors/failures.dart';

class SupportRemoteDs {
  final Dio dio;

  SupportRemoteDs(this.dio);

  Future<void> submitSupport(String name, String email, String message) async {
    try {
      await dio.post(
        ApiEndpoints.supportSubmit,
        data: {'name': name, 'email': email, 'message': message},
      );
    } on DioException catch (e) {
      throw dioToFailure(e);
    } catch (e) {
      throw const UnknownFailure();
    }
  }
}
