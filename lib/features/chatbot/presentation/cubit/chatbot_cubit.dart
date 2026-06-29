import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:math';
import 'package:uuid/uuid.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final _aiUser = const types.User(id: 'ai', firstName: 'QualifAI');
  final _currentUser = const types.User(id: 'user', firstName: 'الموظف');
  final _random = Random();

  final List<String> _aiResponses = [
    'شكراً لك، أنا أقوم بمعالجة طلبك الآن.',
    'مفهوم. سأبحث عن المعلومات المطلوبة.',
    'لحظة من فضلك، جاري التحقق...',
    'تم استلام رسالتك. كيف يمكنني المساعدة بشكل أكبر؟'
  ];

  ChatbotCubit() : super(ChatbotHidden()) {
    _initializeChat();
  }

  void _initializeChat() {
    final now = DateTime.now();
    final uuid = const Uuid();

    // The initial state is hidden, but when it becomes visible, it will have this message.
    _messages = [
      types.TextMessage(
        author: _currentUser,
        createdAt:
            now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
        id: uuid.v4(),
        text: 'نعم، من فضلك اعرض لي المعايير التي تحتاج إلى عمل.',
      ),
      types.TextMessage(
        author: _aiUser,
        createdAt:
            now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
        id: uuid.v4(),
        text:
            'كلية الهندسة لديها نسبة اكتمال 85% للملفات المطلوبة. هل ترغب في معرفة تفاصيل أكثر عن المعايير غير المكتملة؟',
      ),
      types.TextMessage(
        author: _aiUser,
        createdAt:
            now.subtract(const Duration(minutes: 3)).millisecondsSinceEpoch,
        id: uuid.v4(),
        text: 'بالتأكيد. لحظة من فضلك، جاري البحث عن المعلومات...',
      ),
      types.TextMessage(
        author: _currentUser,
        createdAt:
            now.subtract(const Duration(minutes: 4)).millisecondsSinceEpoch,
        id: uuid.v4(),
        text: 'أهلاً، أريد الاستفسار عن حالة الاعتماد لكلية الهندسة.',
      ),
      types.TextMessage(
        author: _aiUser,
        createdAt:
            now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
        id: uuid.v4(),
        text: 'أهلاً بك! كيف يمكنني مساعدتك اليوم؟',
      ),
    ];
  }

  List<types.Message> _messages = [];

  void showChatbot() {
    if (state is ChatbotHidden) {
      emit(ChatbotVisible(List.from(_messages)));
    }
  }

  void hideChatbot() {
    emit(ChatbotHidden());
  }

  void sendMessage(types.PartialText message) {
    if (state is! ChatbotVisible) return;

    final userMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _messages.insert(0, userMessage);
    emit(ChatbotVisible(List.from(_messages)));

    // 🤖 إضافة رد تلقائي بعد ثانية واحدة
    Future.delayed(const Duration(milliseconds: 1200), () {
      // التأكد من أن الشات لا يزال مفتوحاً
      if (state is! ChatbotVisible) return;

      final responseText = _aiResponses[_random.nextInt(_aiResponses.length)];

      final aiReply = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: responseText,
      );

      _messages.insert(0, aiReply);
      emit(ChatbotVisible(List.from(_messages)));
    });
  }
}
