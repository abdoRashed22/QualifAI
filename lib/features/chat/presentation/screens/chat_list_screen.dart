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

class _ChatListView extends StatefulWidget {
  const _ChatListView();

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView> {
  String _searchQuery = '';

  Future<void> _onRefresh() async {
    await context.read<ChatCubit>().loadColleges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text('المحادثات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.navyBlue,
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: TextField(
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'بحث في المحادثات...',
                  hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      color: theme.disabledColor),
                  prefixIcon: Icon(Icons.search,
                      color: theme.disabledColor, size: 20.sp),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
              ),
            ),

            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (ctx, state) {
                  if (state is ChatLoading || state is ChatInitial) {
                    return _buildLoadingSkeleton();
                  }

                  if (state is CollegesLoaded) {
                    final pm = PermissionManager(sl<HiveCache>());

                    // ✅ تخصيص الواجهة لمدير الجودة فقط: يرى موظف الجودة فقط كجهة اتصال
                    if (pm.isManager) {
                      int collegeId = 0;
                      final myData = sl<HiveCache>().getUserData();
                      final idFromProfile =
                          myData?['collegeId'] ?? myData?['id'] ?? 0;

                      if (state.colleges.isNotEmpty) {
                        final myEmail =
                            myData?['email']?.toString().toLowerCase() ?? '';
                        // البحث عن الكلية الخاصة بهذا المدير تحديداً
                        final matched = state.colleges.firstWhere(
                          (c) => (c['managerEmail']?.toString().toLowerCase() ==
                              myEmail),
                          orElse: () => null,
                        );

                        if (matched != null) {
                          collegeId = matched['collegeId'] ??
                              matched['id'] ??
                              idFromProfile;
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
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            onTap: () {
                              if (collegeId == 0) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('خطأ: معرّف الكلية غير صحيح')),
                                );
                                return;
                              }
                              context.push('/chat/$collegeId');
                            },
                            leading: Hero(
                              tag: 'avatar_employee',
                              child: CircleAvatar(
                                radius: 26.r,
                                backgroundColor:
                                    AppColors.navyBlue.withOpacity(0.1),
                                child: Icon(Icons.support_agent,
                                    color: AppColors.navyBlue, size: 28.sp),
                              ),
                            ),
                            title: Text(
                              'موظف الجودة',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'اضغط هنا للتواصل مع فريق الجودة',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    color: theme.disabledColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('الآن',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        color: AppColors.success)),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle),
                                  child: Text('1',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          height: 1)),
                                ),
                              ],
                            ),
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
                                size: 48.sp,
                                color: Theme.of(context).disabledColor),
                            SizedBox(height: 12.h),
                            Text('لا توجد محادثات',
                                style: TextStyle(
                                    fontFamily: 'Cairo', fontSize: 14.sp)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.colleges.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 0.5.h, thickness: 0.5),
                      itemBuilder: (_, i) {
                        final c =
                            state.colleges[i] as Map<String, dynamic>? ?? {};

                        // ✅ FIX: الـ API بيبعت 'collegeId' — استخدم الصح

                        final collegeId = c['collegeId'] ?? c['id'] ?? 0;

                        final collegeName =
                            c['collegeName'] ?? c['name'] ?? 'كلية';

                        final firstChar =
                            collegeName.isNotEmpty ? collegeName[0] : '؟';

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          onTap: () {
                            // ✅ FIX: تأكد إن الـ collegeId مش 0 قبل الـ navigation

                            if (collegeId == 0) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('خطأ: معرّف الكلية غير صحيح')),
                              );

                              return;
                            }

                            // ✅ FIX: navigate بالـ real ID

                            context.push('/chat/$collegeId');
                          },
                          leading: CircleAvatar(
                            radius: 24.r,
                            backgroundColor:
                                AppColors.navyBlue.withOpacity(0.15),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48.sp, color: AppColors.error),
                          SizedBox(height: 16.h),
                          Text('حدث خطأ في الاتصال',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold)),
                          TextButton(
                              // onRefresh: _onRefresh,
                              onPressed: () {},
                              child: const Text('إعادة المحاولة')),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer-like loading skeleton
  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      itemCount: 6,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      separatorBuilder: (_, __) =>
          Divider(height: 1.h, thickness: 0.5, indent: 80.w, endIndent: 16.w),
      itemBuilder: (_, __) => ListTile(
        leading: Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.1),
              shape: BoxShape.circle),
        ),
        title: Container(
          height: 14.h,
          width: double.infinity,
          margin: EdgeInsets.only(right: 40.w, bottom: 8.h),
          decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r)),
        ),
        subtitle: Container(
          height: 12.h,
          width: double.infinity,
          margin: EdgeInsets.only(right: 80.w),
          decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r)),
        ),
      ),
    );
  }
}
