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
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحادثات')),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (ctx, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollegesLoaded) {
            if (state.colleges.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 48.sp, color: Theme.of(context).disabledColor),
                    SizedBox(height: 12.h),
                    Text('لا توجد محادثات',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp)),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: state.colleges.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 0.5.h, thickness: 0.5),
              itemBuilder: (_, i) {
                final c = state.colleges[i] as Map<String, dynamic>? ?? {};

                // ✅ FIX: الـ API بيبعت 'collegeId' — استخدم الصح

                final collegeId = c['collegeId'] ?? c['id'] ?? 0;

                final collegeName = c['collegeName'] ?? c['name'] ?? 'كلية';

                final firstChar = collegeName.isNotEmpty ? collegeName[0] : '؟';

                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  onTap: () {
                    // ✅ FIX: تأكد إن الـ collegeId مش 0 قبل الـ navigation

                    if (collegeId == 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('خطأ: معرّف الكلية غير صحيح')),
                      );

                      return;
                    }

                    // ✅ FIX: navigate بالـ real ID

                    context.go('/chat/$collegeId');
                  },
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.navyBlue.withOpacity(0.15),
                    child: Text(
                      firstChar,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.sp,
                          color: AppColors.navyBlue,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(
                    collegeName,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.right,
                  ),
                  subtitle: Text(
                    'ابدأ المحادثة',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.right,
                  ),
                  trailing: Icon(Icons.arrow_back_ios, size: 14.sp),
                );
              },
            );
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
