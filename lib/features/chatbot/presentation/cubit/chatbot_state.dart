part of 'chatbot_cubit.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object> get props => [];
}

class ChatbotHidden extends ChatbotState {}

class ChatbotVisible extends ChatbotState {
  final List<types.Message> messages;

  const ChatbotVisible(this.messages);

  @override
  List<Object> get props => [messages];
}
