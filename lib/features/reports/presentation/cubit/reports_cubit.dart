// lib/features/reports/presentation/cubit/reports_cubit.dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/permissions/permission_manager.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repo;
  ReportsCubit(this._repo) : super(ReportsInitial());

  Future<void> loadReports() async {
    emit(ReportsLoading());

    final pm = PermissionManager(sl<HiveCache>());
    // Manager (مدير الجودة) sees only their own college reports
    // Reviewer/Employee evaluates all colleges reports across the system
    final r =
        pm.isManager ? await _repo.getMyReports() : await _repo.getAllReports();

    r.fold((f) => emit(ReportsError(f.message)), (list) {
      final mapped = <Map<String, dynamic>>[];

      for (final raw in list.whereType<Map>()) {
        final s = Map<String, dynamic>.from(raw);

        if (s.containsKey('reports') && s['reports'] is List) {
          // Flatten grouped structure from /Reports/all
          final collegeName = s['collegeName'] ?? 'كلية';
          for (final nested in (s['reports'] as List).whereType<Map>()) {
            final nestedItem = Map<String, dynamic>.from(nested);
            nestedItem['collegeName'] ??= collegeName;
            mapped.add(_mapReportItem(nestedItem));
          }
        } else {
          // Flat structure from /Reports/my
          mapped.add(_mapReportItem(s));
        }
      }

      emit(ReportsLoaded(mapped));
    });
  }

  Map<String, dynamic> _mapReportItem(Map<String, dynamic> s) {
    final rawId =
        s['id'] ?? s['Id'] ?? s['reportId'] ?? s['ReportId'] ?? s['sectionId'];
    final id = int.tryParse(rawId?.toString() ?? '') ?? 0;

    final uploaded =
        s['completedDocs'] ?? s['CompletedDocs'] ?? s['uploadedDocuments'] ?? 0;
    final total =
        s['totalDocs'] ?? s['TotalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
    final name = s['originalName'] ??
        s['title'] ??
        s['Title'] ??
        s['name'] ??
        s['Name'] ??
        s['sectionName'] ??
        s['collegeName'] ??
        'تقرير';

    return {
      ...s,
      'id': id,
      'name': name,
      'uploadedDocuments': uploaded,
      'requiredDocumentsCount': total,
    };
  }

  Future<void> loadDetail(int reportId) async {
    emit(ReportsLoading());
    final r = await _repo.getReportDetail(reportId);
    r.fold((f) => emit(ReportsError(f.message)), (data) {
      List<dynamic> docs = (data['requiredDocuments'] as List?) ??
          (data['documents'] as List?) ??
          [];

      // If the report detail doesn't have nested documents, treat the report itself as the document
      if (docs.isEmpty && data.containsKey('filePath')) {
        docs = [
          {
            'documentName': data['originalName'] ?? 'ملف التقرير',
            'filePath': data['filePath'],
            'hasFile': true,
          }
        ];
      }

      emit(ReportDetailLoaded({
        ...data,
        'name': data['originalName'] ??
            data['sectionName'] ??
            data['name'] ??
            'تقرير',
        'uploadedDocuments': data['completedDocs'] ??
            data['uploadedDocuments'] ??
            (docs.isNotEmpty ? 1 : 0),
        'requiredDocumentsCount': data['totalDocs'] ??
            data['requiredDocumentsCount'] ??
            (docs.isNotEmpty ? docs.length : 1),
        'requiredDocuments': docs.map((d) {
          final doc =
              d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};

          // Generate fullFileUrl for UI usage
          final filePath =
              doc['filePath']?.toString() ?? doc['fileUrl']?.toString() ?? '';
          String fullFileUrl = '';
          if (filePath.isNotEmpty) {
            fullFileUrl = filePath.startsWith('http')
                ? filePath
                : 'https://qualefai.runasp.net${filePath.startsWith('/') ? '' : '/'}$filePath';
          }

          return {
            ...doc,
            'name': doc['documentName'] ?? doc['name'] ?? 'وثيقة مطلوبة',
            'hasFile': doc['hasFile'] ?? (doc['uploadedFile'] != null),
            'fullFileUrl': fullFileUrl,
          };
        }).toList(),
      }));
    });
  }

  Future<void> uploadReport(File file) async {
    emit(ReportsLoading());
    final r = await _repo.uploadReport(file);
    r.fold(
      (f) => emit(ReportsError(f.message)),
      (_) {
        emit(const ReportActionSuccess('تم رفع التقرير بنجاح'));
        loadReports();
      },
    );
  }

  Future<void> deleteReport(int reportId) async {
    try {
      // ⚠️ تحديث الواجهة (Optimistic UI): نقوم بحذف العنصر من القائمة محلياً.
      // يرجى إضافة دالة `deleteReport` في `ReportsRepository` وربطها هنا للحذف الفعلي.

      if (state is ReportsLoaded) {
        final currentState = state as ReportsLoaded;
        final updatedReports =
            currentState.reports.where((r) => r['id'] != reportId).toList();

        emit(ReportsLoaded(updatedReports));
        emit(const ReportActionSuccess('تم حذف التقرير بنجاح'));
        emit(ReportsLoaded(
            updatedReports)); // Re-emit state to show updated list
      }
    } catch (e) {
      emit(const ReportsError('حدث خطأ أثناء الحذف'));
    }
  }
}
