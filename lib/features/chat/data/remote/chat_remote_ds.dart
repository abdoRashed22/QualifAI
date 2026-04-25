// lib/features/chat/data/remote/chat_remote_ds.dart

import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';

import '../../../../core/errors/failures.dart';

class ChatRemoteDs {

  final Dio _dio;

  const ChatRemoteDs(this._dio);

  Future<List<dynamic>> getColleges() async {

    try {

      final res = await _dio.get(ApiEndpoints.chatColleges);

      if (res.data is List) return res.data as List;

      return [];

    } on DioException catch (e) {

      throw dioToFailure(e);

    }

  }

  Future<List<dynamic>> getMessages(int collegeId) async {

    try {

      final res = await _dio.get(ApiEndpoints.chatMessages(collegeId));

      if (res.data is List) return res.data as List;

      return [];

    } on DioException catch (e) {

      throw dioToFailure(e);

    }

  }

  Future<void> sendMessage(String content, int collegeId, {int? receiverId}) async {

    try {

      // ✅ FIX: 415 كان بسبب إن الـ body مش JSON — لازم نحدد contentType صراحة

      await _dio.post(

        ApiEndpoints.sendMessage,

        data: {

          'content': content,

          'collegeId': collegeId,

          if (receiverId != null) 'receiverId': receiverId,

        },

        options: Options(

          // ✅ FIX: force JSON content type على الـ POST

          contentType: 'application/json',

        ),

      );

    } on DioException catch (e) {

      print("❌ Chat Send Error: ${e.response?.statusCode}");

      print("❌ Response: ${e.response?.data}");

      print("❌ Headers: ${e.requestOptions.headers}");

      throw dioToFailure(e);

    }

  }

}