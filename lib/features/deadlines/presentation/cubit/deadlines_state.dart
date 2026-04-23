// lib/features/deadlines/presentation/cubit/deadlines_state.dart
part of 'deadlines_cubit.dart';

abstract class DeadlinesState extends Equatable {
  const DeadlinesState();
  @override List<Object?> get props => [];
}
class DeadlinesInitial extends DeadlinesState {}
class DeadlinesLoading extends DeadlinesState {}
class DeadlinesLoaded extends DeadlinesState {
  final List<dynamic> deadlines;
  final String filter; // 'all' | 'overdue' | 'upcoming' | 'done'
  const DeadlinesLoaded(this.deadlines, {this.filter = 'all'});
  @override List<Object?> get props => [deadlines, filter];

  List<dynamic> get filtered {
    if (filter == 'all') return deadlines;
    return deadlines.where((d) {
      final status = (d['status'] ?? '').toString().toLowerCase();
      return status == filter;
    }).toList();
  }
}
class DeadlinesError extends DeadlinesState {
  final String message;
  const DeadlinesError(this.message);
  @override List<Object?> get props => [message];
}
