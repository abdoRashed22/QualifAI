// lib/features/dashboard/presentation/cubit/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;
  DashboardCubit(this._repo) : super(DashboardInitial());

  Future<void> load() async {
    emit(DashboardLoading());
    final result = await _repo.getSections();
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (data) {
        final sections = data['sections'];
        List<SectionSummary> summaries = [];
        if (sections is List) {
          summaries = sections.map<SectionSummary>((s) {
            // Handle BOTH possible field names from API
            final id = s['sectionId'] ?? s['id'] ?? 0;
            final name = s['sectionName'] ?? s['name'] ?? '';
            final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
            final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
            // Use completionPercentage if available, otherwise calculate
            double pct;
            if (s['completionPercentage'] != null) {
              pct = (s['completionPercentage'] as num).toDouble() / 100.0;
            } else {
              pct = total > 0 ? (uploaded / total).toDouble() : 0.0;
            }
            return SectionSummary(
              id: id is int ? id : int.tryParse(id.toString()) ?? 0,
              name: name.toString(),
              uploadedDocs: uploaded is int ? uploaded : int.tryParse(uploaded.toString()) ?? 0,
              requiredDocs: total is int ? total : int.tryParse(total.toString()) ?? 1,
              completionPercent: pct.clamp(0.0, 1.0),
            );
          }).toList();
        }
        emit(DashboardLoaded(summaries));
      },
    );
  }
}
