import 'package:equatable/equatable.dart';

import '../../data/models/permission_model.dart';

abstract class PermissionsState extends Equatable {
  const PermissionsState();

  @override
  List<Object?> get props => [];
}

class PermissionsInitial extends PermissionsState {}

class PermissionsLoading extends PermissionsState {}

class PermissionsLoaded extends PermissionsState {
  final List<PermissionModel> permissions;

  const PermissionsLoaded(this.permissions);

  @override
  List<Object?> get props => [permissions];
}

class PermissionsError extends PermissionsState {
  final String message;

  const PermissionsError(this.message);

  @override
  List<Object?> get props => [message];
}
