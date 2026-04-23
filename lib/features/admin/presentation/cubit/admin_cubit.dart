// lib/features/admin/presentation/cubit/admin_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repo;
  AdminCubit(this._repo) : super(AdminInitial());

  Future<void> loadEmployees() async {
    emit(AdminLoading());
    final r = await _repo.getEmployees();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(EmployeesLoaded(list)));
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    emit(AdminActionLoading());
    final r = await _repo.createEmployee(data);
    r.fold(
      (f) => emit(AdminError(f.message)),
      (_) { emit(const AdminActionSuccess('تم إضافة الموظف')); loadEmployees(); },
    );
  }

  Future<void> deleteEmployee(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteEmployee(id);
    r.fold(
      (f) => emit(AdminError(f.message)),
      (_) { emit(const AdminActionSuccess('تم حذف الموظف')); loadEmployees(); },
    );
  }

  Future<void> loadRoles() async {
    emit(AdminLoading());
    final rolesR = await _repo.getRoles();
    final permsR = await _repo.getPermissions();
    rolesR.fold(
      (f) => emit(AdminError(f.message)),
      (roles) => permsR.fold(
        (f) => emit(RolesLoaded(roles, const [])),
        (perms) => emit(RolesLoaded(roles, perms)),
      ),
    );
  }

  Future<void> createRole(String name, String desc) async {
    emit(AdminActionLoading());
    final r = await _repo.createRole(name, desc);
    r.fold(
      (f) => emit(AdminError(f.message)),
      (_) { emit(const AdminActionSuccess('تم إنشاء الدور')); loadRoles(); },
    );
  }

  Future<void> deleteRole(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteRole(id);
    r.fold(
      (f) => emit(AdminError(f.message)),
      (_) { emit(const AdminActionSuccess('تم حذف الدور')); loadRoles(); },
    );
  }

  Future<void> loadColleges() async {
    emit(AdminLoading());
    final r = await _repo.getColleges();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(CollegesLoaded(list)));
  }

  Future<void> deleteCollege(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteCollege(id);
    r.fold(
      (f) => emit(AdminError(f.message)),
      (_) { emit(const AdminActionSuccess('تم حذف الكلية')); loadColleges(); },
    );
  }

  Future<void> loadPlans() async {
    emit(AdminLoading());
    final r = await _repo.getPlans();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(PlansLoaded(list)));
  }

  Future<void> loadActivityLog() async {
    emit(AdminLoading());
    final r = await _repo.getActivityLog();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(ActivityLoaded(list)));
  }
}