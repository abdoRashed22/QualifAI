import 'package:flutter/material.dart';
import 'package:qualif_ai/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:qualif_ai/features/admin/presentation/screens/colleges_screen.dart';
import 'package:qualif_ai/features/admin/presentation/screens/employees_screen.dart';
import 'package:qualif_ai/features/admin/presentation/screens/roles_screen.dart';
import 'package:qualif_ai/features/profile/data/remote/nav_rail_item.dart';
import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';

import '../../../../core/permissions/pricing_screen.dart' as admin_pricing;
import '../../../notifications/presentation/screens/notifications_screen.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SideRailNavigation(
      appTitle: 'QualifAI',
      homeScreen: const AdminDashboardScreen(),
      mainItems: const [
        NavRailItem(
            icon: Icons.home,
            label: 'الصفحة الرئيسية',
            screen: AdminDashboardScreen()),
        NavRailItem(
            icon: Icons.account_balance,
            label: 'ادارة الكليات',
            screen: CollegesScreen()),
        NavRailItem(
            icon: Icons.people, label: 'الموظفون', screen: EmployeesScreen()),
        NavRailItem(icon: Icons.shield, label: 'ادوار', screen: RolesScreen()),
        NavRailItem(
            icon: Icons.monetization_on,
            label: 'ادارة الاشتراكات',
            screen: admin_pricing.PricingScreen()),
        NavRailItem(
            icon: Icons.notifications_outlined,
            label: 'الاشعارات',
            screen: NotificationsScreen()),
        NavRailItem(
            icon: Icons.history,
            label: 'سجل النشاط',
            screen: ActivityLogScreen()),
      ],
      bottomItems: const [
        NavRailItem(icon: Icons.help_outline, label: 'دعم', screen: SizedBox()),
        NavRailItem(icon: Icons.logout, label: 'الخروج', screen: SizedBox()),
      ],
    );
  }
}
