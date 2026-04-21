// lib/features/chat/presentation/cubit/chat_state.dart
part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class MessagesLoading extends ChatState {}

class CollegesLoaded extends ChatState {
  final List<dynamic> colleges;
  const CollegesLoaded(this.colleges);
  @override List<Object?> get props => [colleges];
}

class MessagesLoaded extends ChatState {
  final List<dynamic> messages;
  final int collegeId;
  const MessagesLoaded(this.messages, {required this.collegeId});
  @override List<Object?> get props => [messages, collegeId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override List<Object?> get props => [message];
}
