// lib/features/auth/data/remote/auth_remote_ds.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../models/auth_model.dart';

class AuthRemoteDs {
  final Dio _dio;
  const AuthRemoteDs(this._dio);

  Future<LoginResponseModel> login(LoginRequestModel req) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.login,
        data: req.toJson(),
      );
      return LoginResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> forgotPassword(ForgotPasswordModel req) async {
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: req.toJson());
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
