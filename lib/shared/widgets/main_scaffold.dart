// lib/shared/widgets/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qualif_ai/features/chatbot/presentation/widgets/chatbot_floating_button.dart';

import '../../core/router/app_router.dart';
import '../../core/di/injection.dart';
import '../../core/cache/hive_cache.dart';
import '../../core/permissions/permission_manager.dart';

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
      bottomNavigationBar:
          isAdmin ? _AdminBottomNav(context) : _UserBottomNav(context),
    );
  }

  Widget _UserBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final permissionManager = PermissionManager(sl<HiveCache>());
    final navItems = permissionManager.userNavItems;

    int currentIndex = navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    if (currentIndex < 0) currentIndex = 0;

    // ✅ تم إصلاح الـ Container والـ BoxDecoration هنا بشكل صحيح
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
        type: BottomNavigationBarType.fixed,
        onTap: (i) => context.go(navItems[i].route),
        items: navItems.map((item) {
          final icon = _navIcon(item.iconKey);
          return BottomNavigationBarItem(
            icon: icon,
            activeIcon: icon,
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _AdminBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;

    if (location.startsWith('/admin/employees')) {
      currentIndex = 1;
    } else if (location.startsWith('/admin/roles')) {
      currentIndex = 2;
    } else if (location.startsWith('/admin/colleges')) {
      currentIndex = 3;
    } else if (location.startsWith('/admin/pricing')) {
      currentIndex = 4;
    } else if (location.startsWith('/admin/activity')) {
      currentIndex = 5;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.adminDashboard);
            break;
          case 1:
            context.go(AppRoutes.employees);
            break;
          case 2:
            context.go(AppRoutes.roles);
            break;
          case 3:
            context.go(AppRoutes.colleges);
            break;
          case 4:
            context.go(AppRoutes.adminPricing);
            break;
          case 5:
            context.go(AppRoutes.activityLog);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'لوحة التحكم'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'الموظفون'),
        BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security),
            label: 'الأدوار'),
        BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'الكليات'),
        BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'الأسعار'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'سجل الأنشطة'),
      ],
    );
  }

  Icon _navIcon(String iconKey) {
    switch (iconKey) {
      case 'home':
        return const Icon(Icons.home_outlined);
      case 'accreditation':
        return const Icon(Icons.assignment_outlined);
      case 'deadlines':
        return const Icon(Icons.schedule_outlined);
      case 'reports':
        return const Icon(Icons.bar_chart_outlined);
      case 'employees':
        return const Icon(Icons.people_outline);
      case 'roles':
        return const Icon(Icons.security_outlined);
      case 'chat':
        return const Icon(Icons.chat_bubble_outline);
      case 'notifications':
        return const Icon(Icons.notifications_outlined);
      case 'profile':
        return const Icon(Icons.person_outline);
      case 'subscriptions':
        return const Icon(Icons.monetization_on_outlined);
      default:
        return const Icon(Icons.circle_outlined);
    }
  }
}
