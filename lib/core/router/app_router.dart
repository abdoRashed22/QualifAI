// lib/core/router/app_router.dart

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/accreditation/presentation/screens/accreditation_types_screen.dart';

import '../../features/accreditation/presentation/screens/standards_list_screen.dart';

import '../../features/accreditation/presentation/screens/standard_detail_screen.dart';

import '../../features/accreditation/presentation/screens/file_upload_screen.dart';

import '../../features/accreditation/presentation/screens/ai_analysis_screen.dart';

import '../../features/reports/presentation/screens/reports_list_screen.dart';

import '../../features/reports/presentation/screens/report_detail_screen.dart';

import '../../features/deadlines/presentation/screens/deadlines_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';

import '../../features/chat/presentation/screens/chat_list_screen.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

import '../../features/admin/presentation/screens/employees_screen.dart';

import '../../features/admin/presentation/screens/roles_screen.dart';

import '../../features/admin/presentation/screens/colleges_screen.dart';

import '../../shared/widgets/main_scaffold.dart';

import '../cache/hive_cache.dart';

import '../di/injection.dart';

// ✅ NEW: Placeholder screens عشان الـ app تـcompile — استبدلهم بملفات حقيقية لما تعملهم



abstract class AppRoutes {
  static const splash = '/';

  static const login = '/login';

  static const forgotPassword = '/forgot-password';

  static const dashboard = '/dashboard';

  static const accreditation = '/accreditation';

  static const standards = '/standards';

  static const standardDetail = '/standards/:sectionId';

  static const fileUpload = '/upload/:docId';

  static const aiAnalysis = '/ai-analysis/:docId';

  static const reports = '/reports';

  static const reportDetail = '/reports/:id';

  static const deadlines = '/deadlines';

  static const notifications = '/notifications';

  static const chatList = '/chat';

  static const chatDetail = '/chat/:collegeId';

  static const profile = '/profile';

  static const adminDashboard = '/admin';

  static const employees = '/admin/employees';

  static const roles = '/admin/roles';

  static const colleges = '/admin/colleges';

  static const pricing = '/admin/pricing';

  static const activityLog = '/admin/activity';
}

GoRouter buildRouter(HiveCache cache) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = cache.isLoggedIn;

      final path = state.matchedLocation;

      final isAuthRoute = path == AppRoutes.login ||
          path == AppRoutes.forgotPassword ||
          path == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      if (isLoggedIn && !isAuthRoute) {
        final role = (cache.getRole() ?? '').toLowerCase();

        // ✅ FIX: متطابق مع auth_repository_impl._mapRole الجديد

        final isAdmin = role == 'admin';

        final isEmployee = role == 'employee';

        final isManager = role == 'manager';

        // 🔐 حماية Routes

        if (path.startsWith('/admin') && !isAdmin) {
          return AppRoutes.dashboard;
        }

        // 🔥 أهم سطر

        if (path == AppRoutes.dashboard) {
          if (isAdmin) return AppRoutes.adminDashboard;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (ctx, _) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (ctx, _) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (ctx, _) => const ForgotPasswordScreen(),
      ),

      // ── Main Shell ────────────────────────────────────────────────────────────

      ShellRoute(
        builder: (ctx, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (ctx, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.accreditation,
            builder: (ctx, _) => const AccreditationTypesScreen(),
          ),
          GoRoute(
            path: AppRoutes.standards,
            builder: (ctx, state) {
              final type = state.uri.queryParameters['type'] ?? '1';

              return StandardsListScreen(accreditationType: int.parse(type));
            },
          ),
         GoRoute(
  path: AppRoutes.standardDetail,
  builder: (ctx, state) {
    final sectionId = int.parse(state.uri.queryParameters['sectionId']!);
    final accreditationType = int.parse(state.uri.queryParameters['type']!);

    return StandardDetailScreen(
      sectionId: sectionId,
      accreditationType: accreditationType,
    );
  },
),
          GoRoute(
            path: AppRoutes.fileUpload,
            builder: (ctx, state) {
              final docId = int.parse(state.pathParameters['docId']!);

              return FileUploadScreen(documentId: docId);
            },
          ),
          GoRoute(
            path: AppRoutes.aiAnalysis,
            builder: (ctx, state) {
              final docId = int.parse(state.pathParameters['docId']!);

              return AiAnalysisScreen(documentId: docId);
            },
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (ctx, _) => const ReportsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.reportDetail,
            builder: (ctx, state) {
              final id = int.parse(state.pathParameters['id']!);

              return ReportDetailScreen(reportId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.deadlines,
            builder: (ctx, _) => const DeadlinesScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (ctx, _) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.chatList,
            builder: (ctx, _) => const ChatListScreen(),
          ),
          GoRoute(
            path: AppRoutes.chatDetail,
            builder: (ctx, state) {
              final id = int.parse(state.pathParameters['collegeId']!);

              return ChatScreen(collegeId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (ctx, _) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Admin Shell ───────────────────────────────────────────────────────────

      ShellRoute(
        builder: (ctx, state, child) =>
            MainScaffold(isAdmin: true, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (ctx, _) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.employees,
            builder: (ctx, _) => const EmployeesScreen(),
          ),
          GoRoute(
            path: AppRoutes.roles,
            builder: (ctx, _) => const RolesScreen(),
          ),
          GoRoute(
            path: AppRoutes.colleges,
            builder: (ctx, _) => const CollegesScreen(),
          ),
          GoRoute(
            path: AppRoutes.pricing,
            builder: (ctx, _) => const PricingScreen(),
          ),
          GoRoute(
            path: AppRoutes.activityLog,
            builder: (ctx, _) => const ActivityLogScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('الصفحة غير موجودة', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctx.go(AppRoutes.login),
              child: const Text("العودة للرئيسية"),
            ),
          ],
        ),
      ),
    ),
  );
}
