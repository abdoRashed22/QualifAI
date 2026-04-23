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

  ChatCubit(this._repo) : super(ChatInitial());

  Future<void> loadColleges() async {
    emit(ChatLoading());
    final r = await _repo.getColleges();
    r.fold((f) => emit(ChatError(f.message)), (list) => emit(CollegesLoaded(list)));
  }

  Future<void> openChat(int collegeId) async {
    _activeCollegeId = collegeId;
    emit(MessagesLoading());
    await _fetchMessages(collegeId);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchMessages(collegeId));
  }

  Future<void> _fetchMessages(int collegeId) async {
    final r = await _repo.getMessages(collegeId);
    r.fold(
      (f) { if (state is! MessagesLoaded) emit(ChatError(f.message)); },
      (list) => emit(MessagesLoaded(list, collegeId: collegeId)),
    );
  }

  Future<void> sendMessage(String content, int collegeId, {int? receiverId}) async {
    final r = await _repo.sendMessage(content, collegeId, receiverId);
    r.fold(
      (f) => emit(ChatError(f.message)),
      (_) => _fetchMessages(collegeId),
    );
  }

  void closeChat() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _activeCollegeId = null;
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
