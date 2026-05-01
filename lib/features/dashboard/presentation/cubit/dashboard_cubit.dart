import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;
  int _currentType = 1;

  DashboardCubit(this._repo) : super(DashboardInitial());

  Future<void> load([int accreditationType = 1]) async {
    _currentType = accreditationType;
    if (isClosed) return;
    emit(DashboardLoading());

    final result = await _repo.getSections();

    if (isClosed) return;

    result.fold(
      (f) {
        if (!isClosed) emit(DashboardError(f.message));
      },
      (data) {
        if (isClosed) return;

        final sections = data['sections'];
        List<SectionSummary> summaries = [];

        if (sections is List) {
          summaries = sections.map<SectionSummary>((s) {
            final id = s['sectionId'] ?? s['id'] ?? 0;
            final name = s['sectionName'] ?? s['name'] ?? '';

            double pct = 0.0;
            if (s['completionPercentage'] != null) {
              final rawPct = (s['completionPercentage'] as num).toDouble();
              pct = (rawPct > 1 ? rawPct / 100.0 : rawPct).clamp(0.0, 1.0);
            } else {
              final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
              final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
              final totalInt = total is int ? total : int.tryParse(total.toString()) ?? 1;
              final uploadedInt = uploaded is int ? uploaded : int.tryParse(uploaded.toString()) ?? 0;
              pct = totalInt > 0 ? (uploadedInt / totalInt).clamp(0.0, 1.0) : 0.0;
            }

            final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
            final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;

            return SectionSummary(
              id: id is int ? id : int.tryParse(id.toString()) ?? 0,
              name: name.toString(),
              uploadedDocs: uploaded is int ? uploaded : int.tryParse(uploaded.toString()) ?? 0,
              requiredDocs: total is int ? total : int.tryParse(total.toString()) ?? 1,
              completionPercent: pct,
              accreditationType: accreditationType, // ✅ استخدم الـ type الجاي من الـ UI مباشرة
            );
          }).toList(); // ✅ حذف الـ filter لأن الـ API مش بيبعت accreditationType
        }

        if (!isClosed) emit(DashboardLoaded(accreditationType, summaries));
      },
    );
  }

  Future<void> reloadCurrent() => load(_currentType);
}