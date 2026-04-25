// lib/features/admin/presentation/cubit/admin_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repo;
  bool _isDisposed = false;

  AdminCubit(this._repo) : super(AdminInitial());

  Future<void> loadEmployees() async {
    if (isClosed || _isDisposed) return;

    emit(AdminLoading());

    try {
      final r = await _repo.getEmployees();

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(AdminError(f.message));
          }
        },
        (list) {
          if (!isClosed && !_isDisposed) {
            // ✅ FIX: mapping علشان تحل مشكلة البيانات مش بتظهر
            final mapped = _mapEmployeeData(list);
            emit(EmployeesLoaded(mapped));
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(AdminError('حدث خطأ أثناء تحميل الموظفين'));
      }
    }
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final r = await _repo.createEmployee(data);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          emit(const AdminActionSuccess('تم إضافة الموظف'));
          loadEmployees();
        }
      },
    );
  }

  Future<void> deleteEmployee(int id) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final r = await _repo.deleteEmployee(id);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          emit(const AdminActionSuccess('تم حذف الموظف'));
          loadEmployees();
        }
      },
    );
  }

  Future<void> loadRoles() async {
    if (isClosed || _isDisposed) return;

    emit(AdminLoading());

    final rolesR = await _repo.getRoles();
    final permsR = await _repo.getPermissions();

    if (isClosed || _isDisposed) return;

    rolesR.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (roles) => permsR.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(RolesLoaded(roles, const []));
          }
        },
        (perms) {
          if (!isClosed && !_isDisposed) {
            emit(RolesLoaded(roles, perms));
          }
        },
      ),
    );
  }

  Future<void> createRole(String name, String desc) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final r = await _repo.createRole(name, desc);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          emit(const AdminActionSuccess('تم إنشاء الدور'));
          loadRoles();
        }
      },
    );
  }

  Future<void> deleteRole(int id) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final r = await _repo.deleteRole(id);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          emit(const AdminActionSuccess('تم حذف الدور'));
          loadRoles();
        }
      },
    );
  }

  Future<void> loadColleges() async {
    if (isClosed || _isDisposed) return;

    emit(AdminLoading());

    final r = await _repo.getColleges();

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (list) {
        if (!isClosed && !_isDisposed) {
          emit(CollegesLoaded(list));
        }
      },
    );
  }

  Future<void> deleteCollege(int id) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final r = await _repo.deleteCollege(id);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          emit(const AdminActionSuccess('تم حذف الكلية'));
          loadColleges();
        }
      },
    );
  }

  Future<void> loadPlans() async {
    if (isClosed || _isDisposed) return;

    emit(AdminLoading());

    final r = await _repo.getPlans();

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (list) {
        if (!isClosed && !_isDisposed) {
          emit(PlansLoaded(list));
        }
      },
    );
  }

  Future<void> loadActivityLog() async {
    if (isClosed || _isDisposed) return;

    emit(AdminLoading());

    final r = await _repo.getActivityLog();

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (list) {
        if (!isClosed && !_isDisposed) {
          emit(ActivityLoaded(list));
        }
      },
    );
  }

  // ✅ أهم fix فعلي عندك
  List<Map<String, dynamic>> _mapEmployeeData(List<dynamic> data) {
    return data.whereType<Map<String, dynamic>>().map((emp) {
      return {
        'id': emp['id'] ?? emp['employeeId'] ?? 0,
        'firstName': emp['firstName'] ?? emp['first_name'] ?? '',
        'lastName': emp['lastName'] ?? emp['last_name'] ?? '',
        'email': emp['email'] ?? '',
        'role': emp['role'] ?? emp['roleName'] ?? 'employee',
        'profileImage':
            emp['profileImage'] ?? emp['image'] ?? emp['photo'] ?? '',
      };
    }).toList();
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}