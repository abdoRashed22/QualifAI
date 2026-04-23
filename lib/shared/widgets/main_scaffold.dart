// lib/shared/widgets/main_scaffold.dart



import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

import '../../core/theme/app_colors.dart';

import '../../core/di/injection.dart';

import '../../core/cache/hive_cache.dart';



class MainScaffold extends StatelessWidget {

  final Widget child;

  final bool isAdmin;



  const MainScaffold({

    super.key,

    required this.child,

    this.isAdmin = false,

  });



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: child,

      bottomNavigationBar: isAdmin

          ? _AdminBottomNav(context)

          : _UserBottomNav(context),

    );

  }



  Widget _UserBottomNav(BuildContext context) {

    final location = GoRouterState.of(context).matchedLocation;

    final role = sl<HiveCache>().getRole() ?? '';

    final isManager = role == 'quality_manager' || role == 'system_admin';



    int currentIndex = 0;

    if (location.startsWith('/accreditation') ||

        location.startsWith('/standards') ||

        location.startsWith('/upload') ||

        location.startsWith('/ai-analysis')) {

      currentIndex = 1;

    } else if (location.startsWith('/reports')) currentIndex = 2;

    else if (location.startsWith('/notifications')) currentIndex = 3;

    else if (location.startsWith('/profile')) currentIndex = 4;



    return Container(

      decoration: BoxDecoration(

        border: Border(

          top: BorderSide(

            color: Theme.of(context).dividerColor,

            width: 0.5,

          ),

        ),

      ),

      child: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (i) {

          switch (i) {

            case 0: context.go(AppRoutes.dashboard); break;

            case 1: context.go(AppRoutes.accreditation); break;

            case 2: context.go(AppRoutes.reports); break;

            case 3: context.go(AppRoutes.notifications); break;

            case 4: context.go(AppRoutes.profile); break;

          }

        },

        items: const [

          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),

          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'الاعتماد'),

          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'التقارير'),

          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'الإشعارات'),

          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),

        ],

      ),

    );

  }



  Widget _AdminBottomNav(BuildContext context) {

    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;

    if (location.startsWith('/admin/employees')) {

      currentIndex = 1;

    } else if (location.startsWith('/admin/roles')) currentIndex = 2;

    else if (location.startsWith('/admin/colleges')) currentIndex = 3;

    else if (location.startsWith('/admin/pricing')) currentIndex = 4;

    else if (location.startsWith('/admin/activity')) currentIndex = 5;



    return BottomNavigationBar(

      currentIndex: currentIndex,

      onTap: (i) {

        switch (i) {

          case 0: context.go(AppRoutes.adminDashboard); break;

          case 1: context.go(AppRoutes.employees); break;

          case 2: context.go(AppRoutes.roles); break;

          case 3: context.go(AppRoutes.colleges); break;

          case 4: context.go(AppRoutes.pricing); break;

          case 5: context.go(AppRoutes.activityLog); break;

        }

      },

      items: const [

        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: '"لوحة التحكم"'),

        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'الموظفون'),

        BottomNavigationBarItem(icon: Icon(Icons.security_outlined), activeIcon: Icon(Icons.security), label: 'الأدوار'),

        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'الكليات'),

        BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), activeIcon: Icon(Icons.monetization_on), label: 'الأسعار'),

        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'سجل الأنشطة'),

      ],

    );

  }

}

