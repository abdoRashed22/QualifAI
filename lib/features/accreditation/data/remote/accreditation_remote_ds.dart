// lib/features/accreditation/data/remote/accreditation_remote_ds.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class AccreditationRemoteDs {
  final Dio _dio;

  const AccreditationRemoteDs(this._dio);

  Future<List<dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> getSectionById(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.sectionById(id));
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> uploadDocument(
    int reqDocId,
    File file,
  ) async {
    // ✅ مهم جدًا (ماينفعش يتشال)
    if (!await file.exists()) {
      throw const ServerFailure('الملف غير موجود، يرجى اختياره مجدداً');
    }

    try {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();

      final contentType = switch (ext) {
        'pdf' => MediaType('application', 'pdf'),
        'doc' => MediaType('application', 'msword'),
        'docx' => MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document'),
        _ => MediaType('application', 'octet-stream'),
      };

      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: contentType,
        ),
      });

      // ✅ Debug logs من Claude (مفيدة)
      print('📤 Uploading file: $fileName (${file.lengthSync()} bytes)');
      print('📤 Endpoint: ${ApiEndpoints.uploadDocument(reqDocId)}');

      final res = await _dio.post(
        ApiEndpoints.uploadDocument(reqDocId),
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      // ✅ validation من كودك (مهم)
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw ServerFailure('فشل رفع الملف: ${res.statusCode}');
      }

      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      // ✅ Debug أقوى
      print('❌ UPLOAD ERROR: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Headers: ${e.requestOptions.headers}');

      throw dioToFailure(e);
    }
  }

  Future<void> setDeadline(
    int reqDocId,
    String deadline,
    bool oneWeek,
    bool oneDay,
    bool onDue,
  ) async {
    try {
      await _dio.post(ApiEndpoints.setDeadline(reqDocId), data: {
        'deadline': deadline,
        'reminders': {
          'oneWeekBefore': oneWeek,
          'oneDayBefore': oneDay,
          'onDueDate': onDue,
        },
      });
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
