// lib/features/reports/presentation/cubit/reports_state.dart
part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override List<Object?> get props => [];
}
class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}
class ReportsLoaded extends ReportsState {
  final List<dynamic> reports;
  const ReportsLoaded(this.reports);
  @override List<Object?> get props => [reports];
}
class ReportDetailLoaded extends ReportsState {
  final Map<String, dynamic> report;
  const ReportDetailLoaded(this.report);
  @override List<Object?> get props => [report];
}
class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override List<Object?> get props => [message];
}
