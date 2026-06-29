import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/chatbot_cubit.dart';

class ChatbotFloatingButton extends StatelessWidget {
  const ChatbotFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        // لا تظهر الزر إذا كانت واجهة الشات مفتوحة بالفعل
        if (state is ChatbotVisible) return const SizedBox.shrink();

        return Positioned(
          left: 24.w,
          bottom: 76.h,
          child: SafeArea(
            top: false,
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.read<ChatbotCubit>().showChatbot(),
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
