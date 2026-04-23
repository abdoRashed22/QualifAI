// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _AdminItem(icon: Icons.people_outline,        label: 'الموظفون',               color: AppColors.blue,       route: AppRoutes.employees),
      const _AdminItem(icon: Icons.security_outlined,     label: 'الأدوار والصلاحيات',     color: AppColors.adminColor, route: AppRoutes.roles),
      const _AdminItem(icon: Icons.school_outlined,       label: 'الكليات',                color: AppColors.success,    route: AppRoutes.colleges),
      const _AdminItem(icon: Icons.monetization_on_outlined, label: 'الأسعار والاشتراكات', color: AppColors.warning,    route: AppRoutes.pricing),
      const _AdminItem(icon: Icons.history_outlined,      label: 'سجل الأنشطة',            color: AppColors.navyBlue,   route: AppRoutes.activityLog),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدير')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.navyBlue,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(children: [
                Text('🛡', style: TextStyle(fontSize: 36.sp)),
                SizedBox(width: 16.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'System Admin',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    'صلاحيات كاملة',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.white60),
                  ),
                ]),
              ]),
            ),
            SizedBox(height: 20.h),
            Text('الإدارة', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.3,
                children: items.map((item) => AppCard(
                  onTap: () => context.push(item.route),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(item.icon, size: 32.sp, color: item.color),
                    SizedBox(height: 8.h),
                    Text(
                      item.label,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminItem {
  final IconData icon;
  final String label, route;
  final Color color;
  const _AdminItem({required this.icon, required this.label, required this.color, required this.route});
}