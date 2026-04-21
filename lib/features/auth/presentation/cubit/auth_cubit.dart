// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/auth_model.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _repo.login(
      LoginRequestModel(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    final result = await _repo.forgotPassword(email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
