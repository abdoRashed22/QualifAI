// lib/features/chat/presentation/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/chat_cubit.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..loadColleges(),
      child: Scaffold(
        appBar: AppBar(title: const Text('المحادثات')),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (ctx, state) {
            if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
            if (state is ChatError) return Center(child: Text(state.message));
            if (state is CollegesLoaded) {
              if (state.colleges.isEmpty) {
                return const Center(child: Text('لا توجد محادثات'));
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.colleges.length,
                separatorBuilder: (_, __) => Divider(height: 0.5.h, thickness: 0.5),
                itemBuilder: (_, i) {
                  final c = state.colleges[i] as Map<String, dynamic>? ?? {};
                  final name = c['collegeName'] ?? c['name'] ?? 'كلية ${i + 1}';
                  final unread = (c['unreadCount'] ?? 0) as int;
                  return ListTile(
                    onTap: () => context.push(
                      AppRoutes.chatDetail.replaceFirst(':collegeId', '${c['id'] ?? 0}'),
                    ),
                    trailing: CircleAvatar(
                      backgroundColor: AppColors.blue.withOpacity(0.15),
                      child: Text(
                        name.isNotEmpty ? name[0] : 'ك',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      c['lastMessage'] ?? 'ابدأ المحادثة',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: unread > 0
                        ? Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : null,
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}