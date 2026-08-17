// lib/features/admin/presentation/cubit/admin_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/admin_repository.dart';

import '../../data/models/employee_model.dart';
import '../../data/models/college_model.dart';
import '../../data/models/plan_model.dart';

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

    final payload = {
      'firstName': data['firstName']?.toString().trim(),
      'lastName': data['lastName']?.toString().trim(),
      'email': data['email']?.toString().trim(),
      'password': data['password']?.toString(),
      'roleId': int.tryParse('${data['roleId'] ?? ''}') ?? 0,
    };

    if ((payload['roleId'] as int) <= 0) {
      payload['roleId'] = 1;
    }

    final r = await _repo.createEmployee(payload);

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

  Future<void> loadColleges({String? successMessage}) async {
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
          if (successMessage != null && successMessage.isNotEmpty) {
            emit(CollegesLoadedSuccess(list, successMessage));
          } else {
            emit(CollegesLoaded(list));
          }
        }
      },
    );
  }

  Future<void> createCollege(Map<String, dynamic> data) async {
    if (isClosed || _isDisposed) return;

    emit(AdminActionLoading());

    final payload = {
      'UniversityName': data['UniversityName']?.toString().trim() ?? '',
      'CollegeName': data['CollegeName']?.toString().trim() ?? '',
      'InstitutionType': data['InstitutionType'],
      'AccreditationType': data['AccreditationType'],
      'SubscriptionStartDate': data['SubscriptionStartDate']?.toString() ?? '',
      'ManagerEmail': data['ManagerEmail']?.toString().trim() ?? '',
      'ManagerPassword': data['ManagerPassword']?.toString() ?? '',
      if (data.containsKey('Image')) 'Image': data['Image'],
    };

    final r = await _repo.createCollege(payload);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        if (!isClosed && !_isDisposed) {
          emit(AdminError(f.message));
        }
      },
      (_) {
        if (!isClosed && !_isDisposed) {
          loadColleges(successMessage: 'تم إضافة الكلية');
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
          loadColleges(successMessage: 'تم حذف الكلية');
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

  Future<List<Map<String, dynamic>>> fetchEmployeesList() async {
    final r = await _repo.getEmployees();
    return r.fold(
      (_) => <Map<String, dynamic>>[],
      (list) => _mapEmployeeData(list),
    );
  }

  Future<void> updateEmployeeData(int id, Map<String, dynamic> data) async {
    if (isClosed || _isDisposed) return;
    emit(const AdminActionLoading());

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

    final r = await _repo.updateEmployee(id, payload);

    if (isClosed || _isDisposed) return;

    r.fold(
      (f) {
        emit(AdminError(f.message));
      },
      (_) {
        emit(const AdminActionSuccess('تم تحديث بيانات الموظف بنجاح'));
        loadEmployees();
      },
    );
  }

  List<Map<String, dynamic>> _mapEmployeeData(List<dynamic> data) {
    return data.whereType<Map<String, dynamic>>().map((emp) {
      final id = emp['employeeId'] ?? emp['id'] ?? 0;

      String firstName =
          (emp['firstName'] ?? emp['first_name'] ?? emp['name'] ?? '')
              .toString();

      String lastName = (emp['lastName'] ?? emp['last_name'] ?? '').toString();

      final email = (emp['email'] ?? emp['userEmail'] ?? emp['userName'] ?? '')
          .toString();

      // استخراج الاسم الأول والأخير من البريد الإلكتروني في حال عدم رجوعهما من الـ API
      if (email.isNotEmpty) {
        final parts = email.split('@');
        if (parts.isNotEmpty) {
          final username = parts.first;
          if (firstName.isEmpty) firstName = username;
          if (lastName.isEmpty || lastName == '-') lastName = username;
        }
      }

      final role =
          (emp['roleName'] ?? emp['role'] ?? emp['roleDisplayName'] ?? 'موظف')
              .toString();

      final fullName = '$firstName $lastName'.trim();

      debugPrint('RAW Employee => $emp');

      debugPrint(
        'Mapped => {id:$id , fullName:$fullName , email:$email , role:$role}',
      );

      return {
        'id': id,

        'firstName': firstName,
        'lastName': lastName,

        'fullName': fullName,

        'email': email,

        // نخزن userName كما هو
        'userName': email,

        'role': role,

        'profileImage': emp['profileImage'] ??
            emp['image'] ??
            emp['photo'] ??
            emp['avatarUrl'] ??
            '',
      };
    }).toList();
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}
