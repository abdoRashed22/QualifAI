// lib/features/reports/presentation/cubit/reports_cubit.dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualif_ai/core/api/api_endpoints.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/permissions/permission_manager.dart';
import '../../data/models/report_mapper.dart';

import 'reports_state.dart';

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
      final mapped = ReportMapper.mapListResponse(list);
      emit(ReportsLoaded(mapped));
    });
  }

  Future<void> loadDetail(int reportId) async {
    emit(ReportsLoading());

    final pm = PermissionManager(sl<HiveCache>());
    // Manager fetches UI formatted endpoint. Employee fetches detail by ID.
    final r = pm.isManager
        ? await _repo.getReportUiDetails()
        : await _repo.getReportDetail(reportId);

    r.fold((f) => emit(ReportsError(f.message)), (data) {
      final mapped = ReportMapper.mapDetail(data);
      emit(ReportDetailLoaded(mapped));
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
