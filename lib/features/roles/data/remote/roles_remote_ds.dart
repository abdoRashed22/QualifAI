import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class RolesRemoteDs {
  final Dio _dio;

  const RolesRemoteDs(this._dio);

  Future<List<dynamic>> getRoles() async {
    try {
      final r = await _dio.get(ApiEndpoints.roles);
      return r.data is List ? r.data : [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> createRole(String name, String description) async {
    try {
      await _dio.post(
        ApiEndpoints.roles,
        data: {'roleName': name, 'description': description},
      );
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      await _dio.delete(ApiEndpoints.roleById(id));
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<Map<String, dynamic>?> fetchRoleDetails(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.roleById(id));
      return res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map)
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> fetchRolePermissions(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.rolePermissions(id));
      if (res.data is List) {
        return (res.data as List)
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> assignRolePermissions(int roleId, List<int> permIds) async {
    try {
      await _dio.post(ApiEndpoints.rolePermissions(roleId), data: permIds);
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<List<dynamic>> getPermissions() async {
    try {
      final r = await _dio.get(ApiEndpoints.permissions);
      return r.data is List ? r.data : [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
