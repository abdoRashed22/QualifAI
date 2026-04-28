// lib/features/reports/presentation/cubit/reports_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/reports_repository.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repo;
  ReportsCubit(this._repo) : super(ReportsInitial());

  Future<void> loadReports() async {
    emit(ReportsLoading());
    final r = await _repo.getReports();
    r.fold((f) => emit(ReportsError(f.message)), (list) {
      final mapped = list.whereType<Map>().map((raw) {
        final s = Map<String, dynamic>.from(raw);
        final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
        final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
        return {
          ...s,
          'id': s['sectionId'] ?? s['id'] ?? 0,
          'name': s['sectionName'] ?? s['name'] ?? 'تقرير',
          'uploadedDocuments': uploaded,
          'requiredDocumentsCount': total,
        };
      }).toList();
      emit(ReportsLoaded(mapped));
    });
  }

  Future<void> loadDetail(int sectionId) async {
    emit(ReportsLoading());
    final r = await _repo.getReportDetail(sectionId);
    r.fold((f) => emit(ReportsError(f.message)), (data) {
      final docs = (data['requiredDocuments'] as List?) ??
          (data['documents'] as List?) ??
          const [];
      emit(ReportDetailLoaded({
        ...data,
        'name': data['sectionName'] ?? data['name'] ?? 'تقرير',
        'uploadedDocuments': data['completedDocs'] ?? data['uploadedDocuments'] ?? 0,
        'requiredDocumentsCount': data['totalDocs'] ?? data['requiredDocumentsCount'] ?? docs.length,
        'requiredDocuments': docs.map((d) {
          final doc = d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
          return {
            ...doc,
            'name': doc['documentName'] ?? doc['name'] ?? 'وثيقة مطلوبة',
            'hasFile': doc['hasFile'] ?? (doc['uploadedFile'] != null),
          };
        }).toList(),
      }));
    });
  }
}
