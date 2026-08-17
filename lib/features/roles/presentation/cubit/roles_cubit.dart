import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/roles_repository.dart';
import 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  final RolesRepository _repository;

  RolesCubit(this._repository) : super(RolesInitial());

  Future<void> loadRoles() async {
    emit(RolesLoading());
    final result = await _repository.getRoles();
    result.fold(
      (failure) => emit(RolesError(failure.message)),
      (roles) => emit(RolesLoaded(roles, const [])),
    );
  }

  Future<void> loadPermissions() async {
    final result = await _repository.getPermissions();
    result.fold(
      (failure) => emit(RolesError(failure.message)),
      (perms) {
        final current = state;
        if (current is RolesLoaded) {
          emit(RolesLoaded(current.roles, perms));
        } else {
          emit(RolesLoaded(const [], perms));
        }
      },
    );
  }

  Future<void> createRole(String name, String description) async {
    emit(RolesActionLoading());
    final result = await _repository.createRole(name, description);
    result.fold(
      (failure) => emit(RolesError(failure.message)),
      (_) {
        emit(const RolesActionSuccess('تم إنشاء الدور'));
        loadRoles();
      },
    );
  }

  Future<void> deleteRole(int id) async {
    emit(RolesActionLoading());
    final result = await _repository.deleteRole(id);
    result.fold(
      (failure) => emit(RolesError(failure.message)),
      (_) {
        emit(const RolesActionSuccess('تم حذف الدور'));
        loadRoles();
      },
    );
  }

  Future<Map<String, dynamic>?> fetchRoleDetails(int id) async {
    final result = await _repository.fetchRoleDetails(id);
    return result.fold((_) => null, (details) => details);
  }

  Future<List<int>> fetchRolePermissions(int id) async {
    final result = await _repository.fetchRolePermissions(id);
    return result.fold((_) => const [], (ids) => ids);
  }

  Future<void> assignRolePermissions(
      int roleId, List<int> permissionIds) async {
    emit(RolesActionLoading());
    final result =
        await _repository.assignRolePermissions(roleId, permissionIds);
    result.fold(
      (failure) => emit(RolesError(failure.message)),
      (_) {
        emit(const RolesActionSuccess('تم تحديث الصلاحيات بنجاح'));
        loadRoles();
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchEmployeesList() async {
    try {
      final res = await sl<Dio>().get(ApiEndpoints.employees);
      if (res.data is! List) return const [];

      final items = res.data as List;
      return items.whereType<Map>().map((emp) {
        final map = Map<String, dynamic>.from(emp as Map);
        final id = map['employeeId'] ?? map['id'] ?? 0;
        final firstName =
            (map['firstName'] ?? map['first_name'] ?? map['name'] ?? '')
                .toString();
        final lastName = (map['lastName'] ?? map['last_name'] ?? '').toString();
        final email =
            (map['email'] ?? map['userEmail'] ?? map['userName'] ?? '')
                .toString();
        final role =
            (map['roleName'] ?? map['role'] ?? map['roleDisplayName'] ?? 'موظف')
                .toString();

        return {
          'id': id,
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$firstName $lastName'.trim(),
          'email': email,
          'userName': email,
          'role': role,
          'profileImage': map['profileImage'] ??
              map['image'] ??
              map['photo'] ??
              map['avatarUrl'] ??
              '',
        };
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> updateEmployeeData(int id, Map<String, dynamic> data) async {
    final payload = {
      'firstName': data['firstName']?.toString().trim(),
      'lastName': data['lastName']?.toString().trim(),
      'email': data['email']?.toString().trim(),
      'roleId': int.tryParse('${data['roleId'] ?? ''}') ?? 0,
    };

    if (data.containsKey('password') &&
        data['password'] != null &&
        data['password'].toString().isNotEmpty) {
      payload['password'] = data['password']?.toString();
    }

    try {
      await sl<Dio>().put(ApiEndpoints.employeeById(id), data: payload);
      emit(const RolesActionSuccess('تم تحديث بيانات الموظف بنجاح'));
      loadRoles();
    } catch (_) {
      emit(const RolesError('حدث خطأ أثناء تحديث بيانات الموظف'));
    }
  }
}
