import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:qualif_ai/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:qualif_ai/core/theme/app_colors.dart';

class ChatbotEntryScreen extends StatelessWidget {
  const ChatbotEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        if (state is! ChatbotVisible) {
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: AppColors.bgDark.withOpacity(0.85),
          appBar: AppBar(
            backgroundColor: AppColors.navyBlue,
            title: const Text('المساعد الذكي'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<ChatbotCubit>().hideChatbot(),
            ),
          ),
          body: Chat(
              messages: state.messages,
              onSendPressed: (partialText) {
                context.read<ChatbotCubit>().sendMessage(partialText);
              },
              onAttachmentPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('يمكنك هنا إضافة رفع الصور والملفات')),
                );
              },
              user: const types.User(id: 'user'),
              inputOptions: const InputOptions(
                sendButtonVisibilityMode: SendButtonVisibilityMode.editing,
              ),
              theme: DefaultChatTheme(
                primaryColor: AppColors.blue,
                secondaryColor: AppColors.surfaceDark,
                backgroundColor: Colors.transparent,
                inputBackgroundColor: AppColors.inputDark,
                inputTextColor: AppColors.textLight,
                inputContainerDecoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border(
                    top: BorderSide(color: AppColors.borderDark),
                  ),
                ),
                inputBorderRadius: BorderRadius.zero,
                attachmentButtonIcon: Icon(
                  Icons.attach_file,
                  color: AppColors.subTextDark,
                ),
                sendButtonIcon: const Icon(
                  Icons.send,
                  color: AppColors.cyan,
                ),
                sentMessageBodyTextStyle: const TextStyle(
                    fontFamily: 'Cairo', color: Colors.white, fontSize: 15),
                receivedMessageBodyTextStyle: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textLight,
                  fontSize: 15,
                ),
                dateDividerTextStyle: TextStyle(color: AppColors.subTextDark),
                userNameTextStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.cyan,
                    fontWeight: FontWeight.bold),
              ),
              l10n: const ChatL10nEn(
                inputPlaceholder: 'اكتب رسالتك هنا...',
              ),
              showUserAvatars: true,
              showUserNames: true),
        );
      },
    );
  }
}
