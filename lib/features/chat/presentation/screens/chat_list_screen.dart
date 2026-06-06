// lib/features/chat/presentation/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/permissions/permission_manager.dart';

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
      appBar: AppBar(
        title: const Text('المحادثات'),
        leading: Builder(
          builder: (ctx) {
            final sideRail = SideRailNavigation.of(ctx);
            if (sideRail != null) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => sideRail.openDrawer(),
              );
            }
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (ctx, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollegesLoaded) {
            final pm = PermissionManager(sl<HiveCache>());

            // ✅ تخصيص الواجهة لمدير الجودة فقط: يرى موظف الجودة فقط كجهة اتصال
            if (pm.isManager) {
              int collegeId = 0;
              final myData = sl<HiveCache>().getUserData();
              final idFromProfile = myData?['collegeId'] ?? myData?['id'] ?? 0;

              if (state.colleges.isNotEmpty) {
                final myEmail =
                    myData?['email']?.toString().toLowerCase() ?? '';
                // البحث عن الكلية الخاصة بهذا المدير تحديداً
                final matched = state.colleges.firstWhere(
                  (c) =>
                      (c['managerEmail']?.toString().toLowerCase() == myEmail),
                  orElse: () => null,
                );

                if (matched != null) {
                  collegeId =
                      matched['collegeId'] ?? matched['id'] ?? idFromProfile;
                } else {
                  collegeId = idFromProfile; // Fallback
                }
              } else {
                collegeId = idFromProfile;
              }

              print('Selected CollegeId => $collegeId');

              return ListView(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    onTap: () {
                      if (collegeId == 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('خطأ: معرّف الكلية غير صحيح')),
                        );
                        return;
                      }
                      context.push('/chat/$collegeId');
                    },
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.success.withOpacity(0.15),
                      child: Icon(Icons.support_agent,
                          color: AppColors.success, size: 24.sp),
                    ),
                    title: Text('موظف الجودة',
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.right),
                    subtitle: Text('اضغط هنا للتواصل مع موظف الجودة',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: Theme.of(context).disabledColor),
                        textAlign: TextAlign.right),
                    trailing: Icon(Icons.arrow_back_ios, size: 14.sp),
                  )
                ],
              );
            }

            // ✅ واجهة موظف الجودة الطبيعية: يرى جميع الكليات
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

                    context.push('/chat/$collegeId');
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
