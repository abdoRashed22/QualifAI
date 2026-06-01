// lib/core/permissions/permission_manager.dart
//
// ─────────────────────────────────────────────────────────────────────────────
//  PERMISSION STRATEGY (matches web design exactly)
//
//  Three roles come from the API:
//    roleName: "مدير النظام"   → system_admin  → full access
//    roleName: "مدير الجوده"   → quality_manager → college scope
//    roleName: "موظف الجوده"   → quality_employee → accreditation scope
//
//  action field refines what a quality_manager / quality_employee can do:
//    "الوصول لجميع النظام"  → full system (treat same as admin for nav)
//    "الخاص بالكليه"         → college scope
//    "الخاص بالاعتماد"       → accreditation scope only
//
//  Screen visibility map (from web designs):
//
//  ADMIN (مدير النظام):
//    Dashboard, Employees, Roles, Colleges Mgmt, Subscription Mgmt,
//    Notifications, Activity Log, Pricing → full admin shell
//
//  QUALITY MANAGER (مدير الجوده) – college scope:
//    Dashboard (admin), Employees (read), Roles (read),
//    Accreditation (both types), Reports, Chat, Notifications, Profile, Deadlines
//
//  QUALITY EMPLOYEE (موظف الجوده) – accreditation scope:
//    Dashboard, Accreditation sections (upload files), Deadlines,
//    Notifications, Profile, Reports (own only), Chat (own college)
//    NO access to: Employees, Roles, Colleges Mgmt, Pricing, Activity Log
// ─────────────────────────────────────────────────────────────────────────────

import '../cache/hive_cache.dart';
import '../router/app_router.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum UserRole {
  systemAdmin, // مدير النظام
  qualityManager, // مدير الجوده
  qualityEmployee, // موظف الجوده
  unknown,
}

enum PermissionScope {
  fullSystem, // الوصول لجميع النظام
  college, // الخاص بالكليه
  accreditation, // الخاص بالاعتماد
  unknown,
}

// ── Nav item descriptor ───────────────────────────────────────────────────────

class NavItem {
  final String label;
  final String route;
  final String iconKey; // used by MainScaffold to pick icon
  const NavItem(
      {required this.label, required this.route, required this.iconKey});
}

// ── Main class ────────────────────────────────────────────────────────────────

class PermissionManager {
  final HiveCache cache;
  PermissionManager(this.cache);

  // ── Raw values from cache ──────────────────────────────────────────────────

  /// The raw roleName stored exactly as returned by API  e.g. "مدير الجوده"
  String get rawRoleName => (cache.getRoleName() ?? '').trim();

  /// The mapped English role key stored after login  e.g. "quality_manager"
  String get roleKey => (cache.getRole() ?? '').toLowerCase().trim();

  /// The action string from API  e.g. "الخاص بالاعتماد"
  String get actionRaw => (cache.getAction() ?? '').trim();

  int? get employeeId => cache.getEmployeeId();

  // ── Derived role ──────────────────────────────────────────────────────────

  UserRole get userRole {
    // First try the English key saved by _mapRole()
    switch (roleKey) {
      case 'system_admin':
      case 'admin':
        return UserRole.systemAdmin;
      case 'manager':
      case 'quality_manager':
        return UserRole.qualityManager;
      case 'reviewer':
      case 'employee':
      case 'quality_employee':
        return UserRole.qualityEmployee;
    }
    // Fallback: parse Arabic roleName directly
    if (rawRoleName.contains('مدير النظام') || rawRoleName.contains('system')) {
      return UserRole.systemAdmin;
    }
    if (rawRoleName.contains('مدير') || rawRoleName.contains('manager')) {
      return UserRole.qualityManager;
    }
    if (rawRoleName.contains('موظف') ||
        rawRoleName.contains('مراجع') ||
        rawRoleName.contains('reviewer') ||
        rawRoleName.contains('employee')) {
      return UserRole.qualityEmployee;
    }
    return UserRole.unknown;
  }

  // ── Derived scope ─────────────────────────────────────────────────────────

  PermissionScope get scope {
    // Admin always full
    if (userRole == UserRole.systemAdmin) {
      return PermissionScope.fullSystem;
    }

    final a = actionRaw.toLowerCase();

    if (a.contains('الوصول لجميع النظام') ||
        a.contains('full') ||
        a.contains('system')) {
      return PermissionScope.fullSystem;
    }
    if (a.contains('الخاص بالاعتماد') ||
        a.contains('accreditation') ||
        a.contains('اعتماد')) {
      return PermissionScope.accreditation;
    }

    // Default by role if action is empty / unrecognised
    if (userRole == UserRole.qualityManager) {
      return PermissionScope.college;
    }
    if (userRole == UserRole.qualityEmployee)
      return PermissionScope.accreditation;

    return PermissionScope.unknown;
  }

  // ── Convenience booleans ───────────────────────────────────────────────────

  bool get isAdmin => userRole == UserRole.systemAdmin;
  bool get isManager => userRole == UserRole.qualityManager;
  bool get isEmployee => userRole == UserRole.qualityEmployee;
  bool get isReviewer => roleKey == 'reviewer' || roleKey == 'employee';
  bool get isReviewOnly => isReviewer && !isEmployee;
  bool get hasFullAccess => scope == PermissionScope.fullSystem;
  bool get hasCollegeAccess =>
      scope == PermissionScope.fullSystem || scope == PermissionScope.college;

  // ── Feature flags (used by UI to show/hide buttons & sections) ────────────

  // Dashboard
  bool get canViewDashboard => true;

  /// Admin/Manager see global stats; Employee sees only own progress
  bool get showsGlobalProgress => isAdmin || hasCollegeAccess;

  // Accreditation
  bool get canViewAccreditation => isAdmin || isManager || isEmployee;
  // Allow admins, employees and managers to upload files (manager should be
  // able to add accreditation documents for their college).
  bool get canUploadFiles => isAdmin || isEmployee || isManager;
  bool get canStartAnalysis => isAdmin || isManager;
  bool get canViewAllColleges => isAdmin || isManager;

  // Reports
  bool get canViewReports => isAdmin || hasCollegeAccess;

  /// Managers/Admins can send notes back to quality employee
  bool get canSendReportNotes => isAdmin || isManager;
  bool get canViewPreviousReports => isAdmin || isManager;

  /// Quality manager can approve/reject accreditation
  bool get canAccreditCollege => isAdmin || isManager;

  // Employees & Roles (admin-level management)
  bool get canManageEmployees => isAdmin;
  bool get canManageRoles => isAdmin;
  bool get canViewEmployees => isAdmin || isManager; // manager: read-only

  // Colleges management (admin creates/suspends)
  bool get canManageColleges => isAdmin;

  // Subscriptions / Pricing
  bool get canManageSubscriptions => isAdmin;
  bool get canViewPricing => isAdmin;

  // Notifications
  bool get canViewNotifications => true;
  bool get canSendNotifications => isAdmin; // admin sends bulk notifications

  // Chat
  bool get canViewChat => true; // all see chat but scoped to their college
  bool get canViewAllChats => isAdmin || isManager;

  // Deadlines
  bool get canViewDeadlines => true;
  bool get canSetDeadlines => isAdmin || isManager;

  // Profile
  bool get canViewProfile => true;

  // Activity Log
  bool get canViewActivityLog => isAdmin;

  // ── Route guard ───────────────────────────────────────────────────────────

  bool canAccessRoute(String path) {
    // Admin-only routes (dashboard, colleges, pricing, activity log) → admin only
    if (path == AppRoutes.adminDashboard ||
        path.startsWith('/admin/colleges') ||
        path.startsWith('/admin/pricing') ||
        path.startsWith('/admin/roles') ||
        path == AppRoutes.activityLog) {
      return isAdmin;
    }

    // Employees & Roles → admin + manager (read-only)
    if (path == AppRoutes.deadlines) {
      return canViewDeadlines;
    }
    if (path.startsWith('/admin/roles')) {
      return isAdmin || isManager;
    }

    // Reports
    if (path.startsWith(AppRoutes.reports)) {
      return canViewReports;
    }

    // Chat
    if (path.startsWith(AppRoutes.chatList) || path.startsWith('/chat')) {
      return canViewChat;
    }

    // Deadlines
    if (path == AppRoutes.deadlines) {
      return canViewDeadlines;
    }

    // Accreditation + upload + AI
    if (path == AppRoutes.accreditation ||
        path.startsWith('/standards') ||
        path.startsWith('/upload') ||
        path.startsWith('/ai-analysis')) return canViewAccreditation;

    // Notifications, profile, dashboard – everyone
    return true;
  }

  // ── Default route after login ─────────────────────────────────────────────

  String get defaultRoute {
    if (isAdmin) return AppRoutes.adminDashboard;
    if (isReviewer) return AppRoutes.reviewerDashboard;
    return AppRoutes.dashboard;
  }

  // ── Navigation items for non-admin shell ─────────────────────────────────
  //
  //  Returns only the tabs visible to this user, in the correct order,
  //  matching the web design side-nav for each role.
  //  Manager sees: Dashboard, Accreditation, Deadlines, Reports, Employees, Roles, Chat, Notifications, Profile

  List<NavItem> get userNavItems {
    final items = <NavItem>[];

    // 1. Dashboard – always
    items.add(const NavItem(
      label: 'الرئيسية',
      route: AppRoutes.dashboard,
      iconKey: 'home',
    ));

    // 2. Accreditation – admin, manager, and quality employee only.
    if (canViewAccreditation) {
      items.add(const NavItem(
        label: 'الاعتماد',
        route: AppRoutes.accreditation,
        iconKey: 'accreditation',
      ));
    }

    // 3. Deadlines – all roles (manager can set, employee views)
    items.add(const NavItem(
      label: 'المواعيد النهائية',
      route: AppRoutes.deadlines,
      iconKey: 'deadlines',
    ));

    // 4. Reports – manager & admin
    if (canViewReports) {
      items.add(const NavItem(
        label: 'التقارير',
        route: AppRoutes.reports,
        iconKey: 'reports',
      ));
    }

    // 5. Employees – manager (read) and admin
    if (canViewEmployees) {
      items.add(const NavItem(
        label: 'الموظفين',
        route: AppRoutes.employees,
        iconKey: 'employees',
      ));
    }

    // 6. Roles – manager (read) and admin
    if (canManageRoles) {
      items.add(const NavItem(
        label: 'ادوار',
        route: AppRoutes.roles,
        iconKey: 'roles',
      ));
    }

    // 7. Chat – all roles
    items.add(const NavItem(
      label: 'التواصل',
      route: AppRoutes.chatList,
      iconKey: 'chat',
    ));

    // 8. Notifications – all roles
    items.add(const NavItem(
      label: 'الاشعارات',
      route: AppRoutes.notifications,
      iconKey: 'notifications',
    ));

    // 9. Profile – all roles
    items.add(const NavItem(
      label: 'حسابي',
      route: AppRoutes.profile,
      iconKey: 'profile',
    ));

    return items;
  }

  // ── Admin nav items ───────────────────────────────────────────────────────
  // Admin sees: Dashboard, Employees, Roles, Colleges, Pricing, Notifications, Activity

  static const List<NavItem> adminNavItems = [
    NavItem(
        label: 'الرئيسية',
        route: AppRoutes.adminDashboard,
        iconKey: 'dashboard'),
    NavItem(
        label: 'الموظفون', route: AppRoutes.employees, iconKey: 'employees'),
    NavItem(label: 'ادوار', route: AppRoutes.roles, iconKey: 'roles'),
    NavItem(
        label: 'ادارة الكليات', route: AppRoutes.colleges, iconKey: 'colleges'),
    NavItem(
        label: 'ادارة الاشتراكات',
        route: AppRoutes.pricing,
        iconKey: 'subscriptions'),
    NavItem(
        label: 'الاشعارات',
        route: AppRoutes.notifications,
        iconKey: 'notifications'),
    NavItem(
        label: 'سجل الانشطة',
        route: AppRoutes.activityLog,
        iconKey: 'activity'),
  ];

  // ── Progress scope helper ─────────────────────────────────────────────────
  //
  //  Dashboard uses this to decide WHAT data to load.
  //  Admin & Manager → load all sections for the selected accreditation type
  //  Employee → load only sections assigned to their employeeId

  bool get shouldFilterProgressByEmployee => isEmployee && !hasCollegeAccess;
}
