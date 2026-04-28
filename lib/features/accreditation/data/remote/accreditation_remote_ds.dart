import 'dart:io';

import 'package:dio/dio.dart';

import 'package:http_parser/http_parser.dart';

import '../../../../core/api/api_endpoints.dart';

import '../../../../core/data/accreditation_data.dart';

import '../../../../core/errors/failures.dart';

class AccreditationRemoteDs {
  final Dio _dio;

  const AccreditationRemoteDs(this._dio);

  Future<List<dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      final list = res.data is List ? res.data as List : <dynamic>[];
      // Use local data as fallback if API returns empty
      if (list.isEmpty) {
        return _getLocalSections();
      }
      return list;
    } on DioException {
      // Fallback to local data on network error
      return _getLocalSections();
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل البيانات');
    }
  }

  List<dynamic> _getLocalSections() {
    final List<dynamic> sections = [];
    for (final entry in accreditationData.entries) {
      final data = entry.value;
      final standards = data['standards'] as List? ?? [];
      for (final standard in standards) {
        sections.add({
          'id': standard['id'],
          'sectionId': standard['sectionId'],
          'name': standard['name'],
          'completedDocs': standard['completedDocs'] ?? 0,
          'totalDocs': standard['totalDocs'] ?? 0,
          'accreditationType': entry.key,
        });
      }
    }
    return sections;
  }

  Future<Map<String, dynamic>> getSectionById(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.sectionById(id));
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
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
      final res = await _dio.get(ApiEndpoints.sectionById(sectionId));
      if (res.data is! Map) {
        // Try local data as fallback
        return _getLocalSectionByTypeAndId(accreditationType, sectionId);
      }
      final section = Map<String, dynamic>.from(res.data);
      final sectionType =
          int.tryParse('${section['accreditationType'] ?? ''}') ?? 0;
      if (sectionType != 0 && sectionType != accreditationType) {
        throw const ServerFailure('هذا المعيار لا ينتمي لنوع الاعتماد الحالي');
      }
      return section;
    } on DioException {
      // Fallback to local data on network error
      return _getLocalSectionByTypeAndId(accreditationType, sectionId);
    } catch (e) {
      // Try local data as fallback
      return _getLocalSectionByTypeAndId(accreditationType, sectionId);
    }
  }

  Map<String, dynamic> _getLocalSectionByTypeAndId(
    int accreditationType,
    int sectionId,
  ) {
    final data = accreditationData[accreditationType];
    if (data == null) return {};

    final standards = data['standards'] as List? ?? [];
    try {
      final standard = standards.firstWhere(
        (s) => s['id'] == sectionId || s['sectionId'] == sectionId,
      );
      return {
        'id': standard['id'],
        'sectionId': standard['sectionId'],
        'name': standard['name'],
        'completedDocs': standard['completedDocs'] ?? 0,
        'totalDocs': standard['totalDocs'] ?? 0,
        'accreditationType': accreditationType,
        'requiredDocuments': standard['documents'] ?? [],
      };
    } catch (_) {
      return {};
    }
  }

  /// Get all standards for a specific accreditation type
  Future<List<dynamic>> getStandardsByType(int accreditationType) async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      final list = res.data is List ? res.data as List : <dynamic>[];
      final filtered = list.where((item) {
        if (item is! Map) return false;
        final type = item['accreditationType'];
        if (type == null) return false;
        return int.tryParse(type.toString()) == accreditationType;
      }).toList();
      // Use local data as fallback if API returns empty
      if (filtered.isEmpty) {
        return _getLocalStandardsByType(accreditationType);
      }
      return filtered;
    } on DioException {
      // Fallback to local data on network error
      return _getLocalStandardsByType(accreditationType);
    } catch (e) {
      throw const ServerFailure('خطأ في تحميل المعايير');
    }
  }

  List<dynamic> _getLocalStandardsByType(int accreditationType) {
    final data = accreditationData[accreditationType];
    if (data == null) return [];

    final standards = data['standards'] as List? ?? [];
    return standards
        .map((s) => {
              'id': s['id'],
              'sectionId': s['sectionId'],
              'name': s['name'],
              'completedDocs': s['completedDocs'] ?? 0,
              'totalDocs': s['totalDocs'] ?? 0,
              'accreditationType': accreditationType,
            })
        .toList();
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
        'File': await MultipartFile.fromFile(
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
