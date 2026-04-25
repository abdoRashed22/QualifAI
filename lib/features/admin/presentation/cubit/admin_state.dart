part of 'admin_cubit.dart';

// ============================================================================
// ADMIN STATES (MERGED + CLEANED)
// ============================================================================

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminActionLoading extends AdminState {
  const AdminActionLoading();
}

// ✅ FIXED TYPE SAFETY (dynamic → Map<String, dynamic>)
class EmployeesLoaded extends AdminState {
  final List<Map<String, dynamic>> employees;

  const EmployeesLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

// ⚠️ REMOVED duplication (Roles/Colleges/Plans/Activity not in NEW but kept OLD support)

class RolesLoaded extends AdminState {
  final List<dynamic> roles;
  final List<dynamic> permissions;

  const RolesLoaded(this.roles, this.permissions);

  @override
  List<Object?> get props => [roles, permissions];
}

class CollegesLoaded extends AdminState {
  final List<dynamic> colleges;

  const CollegesLoaded(this.colleges);

  @override
  List<Object?> get props => [colleges];
}

class PlansLoaded extends AdminState {
  final List<dynamic> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class ActivityLoaded extends AdminState {
  final List<dynamic> logs;

  const ActivityLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}