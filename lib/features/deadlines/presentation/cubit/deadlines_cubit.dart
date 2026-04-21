// lib/features/deadlines/presentation/cubit/deadlines_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/deadlines_repository.dart';

part 'deadlines_state.dart';

class DeadlinesCubit extends Cubit<DeadlinesState> {
  final DeadlinesRepository _repo;
  DeadlinesCubit(this._repo) : super(DeadlinesInitial());

  Future<void> load() async {
    emit(DeadlinesLoading());
    final r = await _repo.getDeadlines();
    r.fold((f) => emit(DeadlinesError(f.message)), (list) => emit(DeadlinesLoaded(list)));
  }

  void filterBy(String filter) {
    if (state is DeadlinesLoaded) {
      emit(DeadlinesLoaded((state as DeadlinesLoaded).deadlines, filter: filter));
    }
  }
}
