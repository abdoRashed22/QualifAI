// lib/features/admin/data/remote/admin_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class AdminRemoteDs {
  final Dio _dio;
  const AdminRemoteDs(this._dio);

  // Employees
  Future<List<dynamic>> getEmployees() async {
    try { final r = await _dio.get(ApiEndpoints.employees); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> createEmployee(Map<String, dynamic> data) async {
    try { await _dio.post(ApiEndpoints.employees, data: data); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    try { await _dio.put(ApiEndpoints.employeeById(id), data: data); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteEmployee(int id) async {
    try { await _dio.delete(ApiEndpoints.employeeById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Roles
  Future<List<dynamic>> getRoles() async {
    try { final r = await _dio.get(ApiEndpoints.roles); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> createRole(String name, String description) async {
    try { await _dio.post(ApiEndpoints.roles, data: {'roleName': name, 'description': description}); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteRole(int id) async {
    try { await _dio.delete(ApiEndpoints.roleById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<List<dynamic>> getPermissions() async {
    try { final r = await _dio.get(ApiEndpoints.permissions); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> setRolePermissions(int roleId, List<int> permIds) async {
    try { await _dio.post(ApiEndpoints.rolePermissions(roleId), data: permIds); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Colleges
  Future<List<dynamic>> getColleges() async {
    try { final r = await _dio.get(ApiEndpoints.colleges); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteCollege(int id) async {
    try { await _dio.delete(ApiEndpoints.collegeById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Plans
  Future<List<dynamic>> getPlans() async {
    try { final r = await _dio.get(ApiEndpoints.plans); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Activity Log
  Future<List<dynamic>> getActivityLog() async {
    try { final r = await _dio.get(ApiEndpoints.activityLog); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
}
