// lib/features/accreditation/presentation/cubit/accreditation_state.dart

part of 'accreditation_cubit.dart';

abstract class AccreditationState extends Equatable {
  const AccreditationState();

  @override
  List<Object?> get props => [];
}

class AccreditationInitial extends AccreditationState {}

class AccreditationLoading extends AccreditationState {}

class UploadingDocument extends AccreditationState {}

class SectionsLoaded extends AccreditationState {
  final List<dynamic> sections;

  const SectionsLoaded(this.sections);

  @override
  List<Object?> get props => [sections];
}

class SectionDetailLoaded extends AccreditationState {
  final Map<String, dynamic> section;

  const SectionDetailLoaded(this.section);

  @override
  List<Object?> get props => [section];
}

class DocumentUploaded extends AccreditationState {
  final Map<String, dynamic> result;

  const DocumentUploaded(this.result);

  @override
  List<Object?> get props => [result];
}

class DeadlineSet extends AccreditationState {
  const DeadlineSet();
}

class AnalysisLoaded extends AccreditationState {
  final Map<String, dynamic> analysis;

  const AnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AccreditationError extends AccreditationState {
  final String message;

  const AccreditationError(this.message);

  @override
  List<Object?> get props => [message];
}
