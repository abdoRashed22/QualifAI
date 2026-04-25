// lib/features/chat/presentation/cubit/chat_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;

  Timer? _refreshTimer;
  int? _activeCollegeId;
  bool _isDisposed = false;

  ChatCubit(this._repo) : super(ChatInitial());

  Future<void> loadColleges() async {
    if (isClosed || _isDisposed) return;

    emit(ChatLoading());

    try {
      final r = await _repo.getColleges();

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(ChatError(f.message));
          }
        },
        (list) {
          if (!isClosed && !_isDisposed) {
            emit(CollegesLoaded(list));
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(ChatError('Failed to load colleges: $e'));
      }
    }
  }

  Future<void> openChat(int collegeId) async {
    if (isClosed || _isDisposed) return;

    _activeCollegeId = collegeId;

    emit(MessagesLoading());

    await _fetchMessages(collegeId);

    _refreshTimer?.cancel();

    // ✅ خليها 5 ثواني (أحسن UX من Claude)
    if (!isClosed && !_isDisposed) {
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) {
          if (!isClosed && !_isDisposed) {
            _fetchMessages(collegeId);
          }
        },
      );
    }
  }

  Future<void> _fetchMessages(int collegeId) async {
    if (isClosed || _isDisposed) return;

    try {
      final r = await _repo.getMessages(collegeId);

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          // ✅ متكسرش الشات لو فيه رسائل بالفعل
          if (state is! MessagesLoaded && !isClosed && !_isDisposed) {
            emit(ChatError(f.message));
          }
        },
        (list) {
          if (!isClosed && !_isDisposed) {
            emit(MessagesLoaded(list, collegeId: collegeId));
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed && state is! MessagesLoaded) {
        emit(ChatError('Failed to load messages: $e'));
      }
    }
  }

  Future<void> sendMessage(
    String content,
    int collegeId, {
    int? receiverId,
  }) async {
    if (isClosed || _isDisposed) return;

    // ✅ Optimistic UI (من كودك القديم - مهم جدًا)
    final currentMessages = state is MessagesLoaded
        ? (state as MessagesLoaded).messages
        : <dynamic>[];

    final tempMsg = <String, dynamic>{
      'content': content,
      'sentAt': DateTime.now().toIso8601String(),
      'senderEmail': '__me__',
      'senderName': 'أنت',
      '__temp': true,
    };

    if (!isClosed && !_isDisposed) {
      emit(MessagesLoaded([...currentMessages, tempMsg], collegeId: collegeId));
    }

    try {
      final r = await _repo.sendMessage(content, collegeId, receiverId);

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          // ❌ فشل → شيل الرسالة المؤقتة
          if (!isClosed && !_isDisposed) {
            emit(MessagesLoaded(currentMessages, collegeId: collegeId));
            emit(ChatError(f.message));
          }
        },
        (_) {
          // ✅ نجاح → هات الداتا الحقيقية
          if (!isClosed && !_isDisposed) {
            _fetchMessages(collegeId);
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(MessagesLoaded(currentMessages, collegeId: collegeId));
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  void closeChat() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _activeCollegeId = null;
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    return super.close();
  }
}