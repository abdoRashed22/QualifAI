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

  Future<void> sendMessage(String content, int collegeId,
      {int? receiverId}) async {
    try {
      // 🚀 الحل الجذري والنهائي:
      // الباك إند لا يقرأ الحقول من الـ FormData بشكل صحيح (يقوم بحفظها كـ 0).
      // لذلك سنقوم بإرسالها في الـ FormData (مُحولة لنصوص) + إرسالها كـ Query Parameters معاً كحل احتياطي!
      final queryParams = {
        'content': content,
        'collegeId': collegeId,
        if (receiverId != null) 'receiverId': receiverId,
      };

      await _dio.post(
        ApiEndpoints.sendMessage,
        data: FormData.fromMap({
          'Content': content,
          'CollegeId': collegeId.toString(), // تحويل إجباري لنص
          if (receiverId != null) 'ReceiverId': receiverId.toString(),
        }),
        queryParameters:
            queryParams, // إجبار الباك إند على قراءتها من الرابط في حال فشل قراءة الـ Body
      );
    } on DioException catch (e) {
      print("❌ Chat Send Error: ${e.response?.statusCode}");

      print("❌ Response: ${e.response?.data}");

      print("❌ Headers: ${e.requestOptions.headers}");

      throw dioToFailure(e);
    }
  }
}
