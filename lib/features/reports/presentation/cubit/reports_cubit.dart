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
    r.fold((f) => emit(ReportsError(f.message)), (list) => emit(ReportsLoaded(list)));
  }

  Future<void> loadDetail(int sectionId) async {
    emit(ReportsLoading());
    final r = await _repo.getReportDetail(sectionId);
    r.fold((f) => emit(ReportsError(f.message)), (data) => emit(ReportDetailLoaded(data)));
  }
}
