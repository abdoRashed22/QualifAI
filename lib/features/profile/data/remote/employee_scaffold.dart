import 'package:flutter/material.dart';
import 'package:qualif_ai/features/profile/data/remote/nav_rail_item.dart';
import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';

import '../../../reviewer/presentation/screens/reviewer_dashboard_screen.dart';
import '../../../accreditation/presentation/screens/accreditation_types_screen.dart';
import '../../../deadlines/presentation/screens/deadlines_screen.dart';
import '../../../reports/presentation/screens/reports_list_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class EmployeeScaffold extends StatelessWidget {
  const EmployeeScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SideRailNavigation(
      appTitle: '         QualifAI',
      homeScreen: const ReviewerDashboardScreen(),
      mainItems: const [
        NavRailItem(
            icon: Icons.home,
            label: 'الرئيسية',
            screen: ReviewerDashboardScreen()),
        /* NavRailItem(
            icon: Icons.file_copy,
            label: 'الاعتماد',
            screen: AccreditationTypesScreen()),*/
        NavRailItem(
            icon: Icons.calendar_today,
            label: 'المواعيد النهائية',
            screen: DeadlinesScreen()),
        NavRailItem(
            icon: Icons.bar_chart_outlined,
            label: 'التقارير',
            screen: ReportsListScreen()),
        NavRailItem(
            icon: Icons.notifications_outlined,
            label: 'الإشعارات',
            screen: NotificationsScreen()),
        NavRailItem(
            icon: Icons.chat_bubble_outline,
            label: 'التواصل',
            screen: ChatListScreen()),
        NavRailItem(
            icon: Icons.person_outline,
            label: 'حسابي',
            screen: ProfileScreen()),
      ],
      bottomItems: const [
        NavRailItem(icon: Icons.help_outline, label: 'دعم', screen: SizedBox()),
        NavRailItem(icon: Icons.logout, label: 'الخروج', screen: SizedBox()),
      ],
    );
  }
}
