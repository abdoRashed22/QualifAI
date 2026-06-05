// lib/features/reports/presentation/cubit/reports_cubit.dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qualif_ai/core/api/api_endpoints.dart';
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

    // Employee reviews ALL reports. Manager views ONLY MY reports.
    final r = pm.isEmployee
        ? await _repo.getAllReports()
        : await _repo.getMyReports();

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

    final pm = PermissionManager(sl<HiveCache>());
    // Manager fetches UI formatted endpoint. Employee fetches detail by ID.
    final r = pm.isManager
        ? await _repo.getReportUiDetails()
        : await _repo.getReportDetail(reportId);

    r.fold((f) => emit(ReportsError(f.message)), (data) {
      emit(ReportDetailLoaded(data));
    });
  }

  Future<void> downloadCollegeReport(int collegeId) async {
    emit(const ReportDownloadSuccess('جاري تجهيز التحميل...'));
    // This triggers the UI to launch the URL via url_launcher or similar behavior
    final url = '${ApiEndpoints.baseUrl}/Reports/college/$collegeId/download';
    emit(ReportDownloadSuccess(url));
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
}
