// lib/features/deadlines/presentation/cubit/deadlines_state.dart

part of 'deadlines_cubit.dart';

abstract class DeadlinesState extends Equatable {
  const DeadlinesState();

  @override
  List<Object?> get props => [];
}

class DeadlinesInitial extends DeadlinesState {}

class DeadlinesLoading extends DeadlinesState {}

class DeadlinesLoaded extends DeadlinesState {
  final List<dynamic> deadlines;

  final String filter; // 'all' | 'overdue' | 'upcoming' | 'done'

  const DeadlinesLoaded(this.deadlines, {this.filter = 'all'});

  @override
  List<Object?> get props => [deadlines, filter];

  List<dynamic> get filtered {
    if (filter == 'all') return deadlines;

    return deadlines.where((d) {
      final status = _normalizeStatus(d);

      return status == filter;
    }).toList();
  }

  String _normalizeStatus(dynamic data) {
    if (data is! Map) return 'upcoming';

    final statusValue =
        (data['status'] ?? data['state'] ?? '').toString().toLowerCase();
    final completed = data['completed'] ?? data['isDone'] ?? data['done'];
    final isCompleted =
        completed == true || completed?.toString().toLowerCase() == 'true';

    if (statusValue.contains('done') ||
        statusValue.contains('completed') ||
        statusValue.contains('finished') ||
        statusValue.contains('complete') ||
        statusValue.contains('منتهي') ||
        statusValue.contains('مكتمل')) {
      return 'done';
    }
    if (statusValue.contains('overdue') ||
        statusValue.contains('late') ||
        statusValue.contains('متأخر') ||
        statusValue.contains('تأخر')) {
      return 'overdue';
    }
    if (statusValue.contains('upcoming') ||
        statusValue.contains('pending') ||
        statusValue.contains('قادم') ||
        statusValue.contains('قيد')) {
      return 'upcoming';
    }
    if (isCompleted) return 'done';

    final deadlineStr = data['deadline']?.toString() ?? '';
    final deadlineDate = DateTime.tryParse(deadlineStr);
    if (deadlineDate != null) {
      final now = DateTime.now();
      if (deadlineDate.isBefore(now)) return 'overdue';
      return 'upcoming';
    }

    return 'upcoming';
  }
}

class DeadlinesError extends DeadlinesState {
  final String message;

  const DeadlinesError(this.message);

  @override
  List<Object?> get props => [message];
}
