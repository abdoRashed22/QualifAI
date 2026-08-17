import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/permissions_repository.dart';
import 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  final PermissionsRepository _repository;

  PermissionsCubit(this._repository) : super(PermissionsInitial());

  Future<void> loadPermissions() async {
    emit(PermissionsLoading());
    final result = await _repository.getPermissions();
    result.fold(
      (failure) => emit(PermissionsError(failure.message)),
      (permissions) => emit(PermissionsLoaded(permissions)),
    );
  }
}
