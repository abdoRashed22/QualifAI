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
            final uploaded = (s['uploadedDocuments'] ?? 0) as int;
            final required = (s['requiredDocumentsCount'] ?? 1) as int;
            final pct = required > 0 ? (uploaded / required) : 0.0;
            return SectionSummary(
              id: s['id'] ?? 0,
              name: s['name'] ?? '',
              uploadedDocs: uploaded,
              requiredDocs: required,
              completionPercent: pct.toDouble().clamp(0.0, 1.0),
            );
          }).toList();
        }
        emit(DashboardLoaded(summaries));
      },
    );
  }
}
