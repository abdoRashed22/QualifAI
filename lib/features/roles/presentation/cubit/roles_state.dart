import 'package:equatable/equatable.dart';

import '../../data/models/role_model.dart';

abstract class RolesState extends Equatable {
  const RolesState();

  @override
  List<Object?> get props => [];
}

class RolesInitial extends RolesState {}

class RolesLoading extends RolesState {}

class RolesActionLoading extends RolesState {}

class RolesLoaded extends RolesState {
  final List<RoleModel> roles;
  final List<dynamic> permissions;

  const RolesLoaded(this.roles, this.permissions);

  @override
  List<Object?> get props => [roles, permissions];
}

class RolesError extends RolesState {
  final String message;

  const RolesError(this.message);

  @override
  List<Object?> get props => [message];
}

class RolesActionSuccess extends RolesState {
  final String message;

  const RolesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
