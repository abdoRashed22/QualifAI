// lib/core/api/api_endpoints.dart

abstract class ApiEndpoints {
  static const String baseUrl = 'https://qualefai.runasp.net/api';

  // ── Auth ─────────────────────────────────────────
  static const String login = '/Auth/login';
  static const String forgotPassword = '/Auth/forgot-password';

  // ✅ ADDED (Claude)
  static const String logout = '/Auth/logout';

  // ── Profile ─────────────────────────────────────
  static const String profile = '/Profile';
  static const String updateProfile = '/Profile/update';
  static const String updatePassword = '/Profile/update-password';
  static const String uploadPhoto = '/Profile/upload-photo';
  static const String deletePhoto = '/Profile/delete-photo';

  // ✅ ADDED (Claude - alias consistency fix)
  static const String uploadProfilePhoto = '/Profile/upload-photo';

  // ── Accreditation ───────────────────────────────
  static const String sections = '/Accreditation/sections';

  static String sectionById(int id) => '/Accreditation/sections/$id';

  static String uploadDocument(int reqDocId) =>
      '/Accreditation/documents/$reqDocId/upload';

  static String getDocumentAnalysis(int reqDocId) =>
      '/Accreditation/documents/$reqDocId/analysis';

  static String setDeadline(int reqDocId) =>
      '/Accreditation/documents/$reqDocId/set-deadline';

  static const String deadlines = '/Accreditation/deadlines';

  // ── Notifications ───────────────────────────────
  static const String notifications = '/Notification';
  static const String unreadCount = '/Notification/unread-count';
  static const String markAllRead = '/Notification/mark-all-read';

  // ── Admin Notification ──────────────────────────
  static const String sendAdminNotification = '/AdminNotification/send';

  // ── Chat ────────────────────────────────────────
  static const String chatColleges = '/Chat/colleges';

  static String chatMessages(int collegeId) => '/Chat/$collegeId/messages';

  static const String sendMessage = '/Chat/send';
  static const String unreadMessages = '/Chat/unread';

  // ── Colleges ────────────────────────────────────
  static const String colleges = '/Colleges';

  static String collegeById(int id) => '/Colleges/$id';

  // ── Employee ────────────────────────────────────
  static const String employees = '/Employee';

  static String employeeById(int id) => '/Employee/$id';

  // ── Roles ───────────────────────────────────────
  static const String roles = '/Roles';

  static String roleById(int id) => '/Roles/$id';

  static String rolePermissions(int id) => '/Roles/$id/permissions';

  // ── Permissions ─────────────────────────────────
  static const String permissions = '/Permissions';

  static String permissionById(int id) => '/Permissions/$id';

  // ── Plans ───────────────────────────────────────
  static const String plans = '/Plan';

  static String planById(int id) => '/Plan/$id';

  // ── Pricing / Subscription ──────────────────────
  static const String pricing = '/Pricing';
  static const String subscribe = '/Pricing/subscribe';
  static const String subscriptions = '/Subscription';

  static String subscriptionByCollege(int collegeId) =>
      '/Subscription/college/$collegeId';

  static String updateSubscription(int id) => '/Subscription/$id';

  static String suspendSubscription(int id) => '/Subscription/suspend/$id';

  static String activateSubscription(int id) => '/Subscription/activate/$id';

  // ── Activity Log ────────────────────────────────
  static const String activityLog = '/ActivityLog';

  // ── Enums ───────────────────────────────────────
  static const String institutionTypes = '/Enum/institution-types';
  static const String accreditationTypes = '/Enum/accreditation-types';

  // ── Support ─────────────────────────────────────
  static const String supportSubmit = '/Support/submit';

  // =================================================
  // ✅ CLAUDE ADDITIONS (NEW MODULES ONLY)
  // =================================================

  // Admin
  static const String getEmployees = '/Admin/employees';
  static const String createEmployee = '/Admin/employees/create';

  static String deleteEmployee(int id) => '/Admin/employees/$id/delete';

  static String updateEmployee(int id) => '/Admin/employees/$id/update';

  // Reports
  static const String reports = '/Reports';

  static String reportDetail(int id) => '/Reports/$id';

  // Notifications (alt clean endpoint version)
  static const String notificationsV2 = '/Notifications';
}
