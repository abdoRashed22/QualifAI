// lib/features/profile/data/remote/profile_remote_ds.dart
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class ProfileRemoteDs {
  final Dio _dio;
  const ProfileRemoteDs(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.profile);
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> updateProfile(String email, String firstName, String lastName) async {
    try {
      await _dio.put(ApiEndpoints.updateProfile, data: {
        'email': email, 'firstName': firstName, 'lastName': lastName,
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> updatePassword(String oldPass, String newPass) async {
    try {
      await _dio.put(ApiEndpoints.updatePassword, data: {
        'oldPassword': oldPass, 'newPassword': newPass,
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> uploadPhoto(File file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      await _dio.post(ApiEndpoints.uploadPhoto, data: form);
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> deletePhoto() async {
    try {
      await _dio.delete(ApiEndpoints.deletePhoto);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}
