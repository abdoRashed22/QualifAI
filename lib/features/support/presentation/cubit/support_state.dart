import 'package:equatable/equatable.dart';

abstract class SupportState extends Equatable {
  const SupportState();
  @override
  List<Object?> get props => [];
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportSuccess extends SupportState {
  final String message;
  const SupportSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SupportError extends SupportState {
  final String message;
  const SupportError(this.message);
  @override
  List<Object?> get props => [message];
}
