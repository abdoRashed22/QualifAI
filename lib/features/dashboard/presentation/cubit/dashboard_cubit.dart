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

  if (isClosed) return;                    // ← guard 2 (most important — after await)

  result.fold(
    (f) {
      if (!isClosed) emit(DashboardError(f.message));   // ← guard 3
    },
    (data) {
      if (isClosed) return;                             // ← guard 4

      // ... mapping logic ...

  

        final sections = data['sections'];
        List<SectionSummary> summaries = [];

        if (sections is List) {
          summaries = sections.map<SectionSummary>((s) {
            final id = s['sectionId'] ?? s['id'] ?? 0;
            final name = s['sectionName'] ?? s['name'] ?? '';
            final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
            final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
            final type = s['accreditationType'] ?? 0;

            double pct;
            if (s['completionPercentage'] != null) {
              pct = (s['completionPercentage'] as num).toDouble() / 100.0;
            } else {
              pct = total > 0 ? (uploaded / total).toDouble() : 0.0;
            }

            return SectionSummary(
              id: id is int ? id : int.tryParse(id.toString()) ?? 0,
              name: name.toString(),
              uploadedDocs: uploaded is int
                  ? uploaded
                  : int.tryParse(uploaded.toString()) ?? 0,
              requiredDocs:
                  total is int ? total : int.tryParse(total.toString()) ?? 1,
              completionPercent: pct.clamp(0.0, 1.0),
              accreditationType: type is int
                  ? type
                  : int.tryParse(type.toString()) ?? 0,
            );
          }).where((section) => section.accreditationType == accreditationType).toList();
        }

        if (!isClosed) emit(DashboardLoaded(accreditationType, summaries));
      },
    );
  }

  Future<void> reloadCurrent() => load(_currentType);
}