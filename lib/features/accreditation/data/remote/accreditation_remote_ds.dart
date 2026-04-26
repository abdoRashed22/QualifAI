import 'dart:io';

import 'package:dio/dio.dart';

import 'package:http_parser/http_parser.dart';

import '../../../../core/api/api_endpoints.dart';

import '../../../../core/errors/failures.dart';

import '../../../../core/data/accreditation_data.dart' as accred_data;

class AccreditationRemoteDs {
  final Dio _dio;

  const AccreditationRemoteDs(this._dio);

  Future<List<dynamic>> getSections() async {
    try {
      // TODO: Replace with actual API call when backend is ready

      // For now, using mock data

      final accreditationTypes = accred_data.getAllAccreditationTypes();

      return accreditationTypes;
    } on DioException catch (e) {
      throw dioToFailure(e);
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل البيانات');
    }
  }

  Future<Map<String, dynamic>> getSectionById(int id) async {
    try {
      // TODO: Replace with actual API call when backend is ready

      // For now, using mock data - default to type 1 (Academic)

      return getSectionByTypeAndId(1, id);

      // Commented out API call - uncomment when backend is ready

      // final res = await _dio.get(ApiEndpoints.sectionById(id));

      // return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      throw dioToFailure(e);
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل البيانات');
    }
  }

  /// Get section by accreditation type and section ID

  Future<Map<String, dynamic>> getSectionByTypeAndId(
    int accreditationType,
    int sectionId,
  ) async {
    try {
      final section = accred_data.getSectionById(accreditationType, sectionId);

      if (section == null) {
        throw const ServerFailure('لم يتم العثور على المعيار المطلوب');
      }

      return section;
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل بيانات المعيار');
    }
  }

  /// Get all standards for a specific accreditation type
  Future<List<dynamic>> getStandardsByType(int accreditationType) async {
    try {
      final standards = accred_data.getStandardsByType(accreditationType);
      return standards;
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل المعايير');
    }
  }

  Future<Map<String, dynamic>> uploadDocument(
    int reqDocId,
    File file,
  ) async {
    try {
      if (!await file.exists()) {
        throw const ServerFailure('الملف غير موجود، يرجى اختياره مجدداً');
      }

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

      print('📤 Uploading file: $fileName (${file.lengthSync()} bytes)');

      print('📤 Endpoint: ${ApiEndpoints.uploadDocument(reqDocId)}');

      final res = await _dio.post(
        ApiEndpoints.uploadDocument(reqDocId),
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw ServerFailure('فشل رفع الملف: ${res.statusCode}');
      }

      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      print('❌ UPLOAD ERROR: ${e.response?.statusCode}');

      print('❌ Response: ${e.response?.data}');

      print('❌ Headers: ${e.requestOptions.headers}');

      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>> getDocumentAnalysis(int reqDocId) async {
    try {
      final res = await _dio.get(ApiEndpoints.getDocumentAnalysis(reqDocId));

      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) {
      throw dioToFailure(e);
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل التحليل');
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
