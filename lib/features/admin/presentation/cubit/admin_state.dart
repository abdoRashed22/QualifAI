// lib/features/admin/presentation/cubit/admin_state.dart
part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override List<Object?> get props => [];
}
class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminActionLoading extends AdminState {}
class EmployeesLoaded extends AdminState {
  final List<dynamic> employees;
  const EmployeesLoaded(this.employees);
  @override List<Object?> get props => [employees];
}
class RolesLoaded extends AdminState {
  final List<dynamic> roles;
  final List<dynamic> permissions;
  const RolesLoaded(this.roles, this.permissions);
  @override List<Object?> get props => [roles, permissions];
}
class CollegesLoaded extends AdminState {
  final List<dynamic> colleges;
  const CollegesLoaded(this.colleges);
  @override List<Object?> get props => [colleges];
}
class PlansLoaded extends AdminState {
  final List<dynamic> plans;
  const PlansLoaded(this.plans);
  @override List<Object?> get props => [plans];
}
class ActivityLoaded extends AdminState {
  final List<dynamic> logs;
  const ActivityLoaded(this.logs);
  @override List<Object?> get props => [logs];
}
class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override List<Object?> get props => [message];
}
