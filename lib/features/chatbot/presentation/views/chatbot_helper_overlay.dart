import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualif_ai/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:qualif_ai/features/chatbot/presentation/screens/chatbot_entry_screen.dart';

/// A widget that displays the main content and overlays the chatbot UI when visible.
class ChatbotHelperOverlay extends StatelessWidget {
  final Widget child;

  const ChatbotHelperOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatbotCubit(),
      child: Builder(builder: (context) {
        return Stack(
          children: [
            // Main app content
            child,
            // Chatbot overlay
            BlocBuilder<ChatbotCubit, ChatbotState>(
              builder: (context, state) => state is ChatbotVisible
                  ? const ChatbotEntryScreen()
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }
}
