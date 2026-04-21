// lib/features/profile/presentation/cubit/profile_state.dart
part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override List<Object?> get props => [];
}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileUpdating extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> data;
  const ProfileLoaded(this.data);
  @override List<Object?> get props => [data];
}
class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override List<Object?> get props => [message];
}
