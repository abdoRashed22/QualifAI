// lib/features/auth/presentation/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponseModel user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
