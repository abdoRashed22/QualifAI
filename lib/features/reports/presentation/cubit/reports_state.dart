// lib/features/reports/presentation/cubit/reports_state.dart

import 'package:equatable/equatable.dart';

import '../../data/models/report_detail_model.dart';
import '../../data/models/report_list_item_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ReportListItemModel> reports;

  const ReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportDetailLoaded extends ReportsState {
  final ReportDetailModel report;

  const ReportDetailLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportDownloadSuccess extends ReportsState {
  final String url;
  const ReportDownloadSuccess(this.url);

  @override
  List<Object?> get props => [url];
}

class ReportActionSuccess extends ReportsState {
  final String message;
  const ReportActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
