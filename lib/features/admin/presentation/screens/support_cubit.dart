import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualif_ai/features/admin/presentation/screens/support_repository.dart';

import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository _repo;

  SupportCubit(this._repo) : super(SupportInitial());

  Future<void> submit(String name, String email, String message) async {
    emit(SupportLoading());
    final result = await _repo.submitSupport(name, email, message);
    result.fold(
      (failure) => emit(SupportError(failure.message)),
      (_) => emit(const SupportSuccess(
          'تم إرسال رسالتك بنجاح! فريق الدعم سيتواصل معك قريباً.')),
    );
  }
}
