// lib/features/dashboard/presentation/cubit/dashboard_state.dart
part of 'dashboard_cubit.dart';

class SectionSummary extends Equatable {
  final int id;
  final String name;
  final int uploadedDocs;
  final int requiredDocs;
  final double completionPercent;
  final int accreditationType;

  const SectionSummary({
    required this.id,
    required this.name,
    required this.uploadedDocs,
    required this.requiredDocs,
    required this.completionPercent,
    required this.accreditationType,
  });

  @override
  List<Object?> get props => [id, name, completionPercent, accreditationType];
}

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override List<Object?> get props => [];
}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final int accreditationType;
  final List<SectionSummary> sections;
  const DashboardLoaded(this.accreditationType, this.sections);
  @override List<Object?> get props => [accreditationType, sections];

  double get overallCompletion {
    if (sections.isEmpty) return 0;
    return sections.map((s) => s.completionPercent).reduce((a, b) => a + b) / sections.length;
  }
  int get totalUploaded => sections.fold(0, (s, e) => s + e.uploadedDocs);
}
class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override List<Object?> get props => [message];
}
