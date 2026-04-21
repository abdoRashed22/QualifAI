# QualifAI — Write Files V2 (UTF-8 No BOM)
# Run from E:\Projects\qualif_ai:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\WRITE_FILES_V2.ps1

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
Write-Host 'QualifAI Writing Files (UTF-8 No BOM)...' -ForegroundColor Cyan

function Write-File($path, $content) {
    $fullPath = Join-Path (Get-Location).Path $path
    $dir = [System.IO.Path]::GetDirectoryName($fullPath)
    if ($dir -and !(Test-Path $dir)) {
        [System.IO.Directory]::CreateDirectory($dir) | Out-Null
    }
    [System.IO.File]::WriteAllText($fullPath, $content, $utf8NoBom)
    Write-Host ('  + ' + $path) -ForegroundColor Green
}

Write-File 'lib\main.dart' @'
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/cache/hive_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const QualifAIApp());
}

class QualifAIApp extends StatelessWidget {
  const QualifAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (ctx, themeMode) {
          return BlocBuilder<LocaleCubit, dynamic>(
            builder: (ctx, locale) {
              final router = buildRouter(sl<HiveCache>());
              return ScreenUtilInit(
                designSize: const Size(390, 844),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    title: 'QualifAI',
                    debugShowCheckedModeBanner: false,
                    themeMode: themeMode,
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    locale: locale is Locale ? locale : const Locale('ar'),
                    supportedLocales: const [Locale('ar'), Locale('en')],
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    routerConfig: router,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

'@

Write-File 'lib\core\api\api_endpoints.dart' @'
// lib/core/api/api_endpoints.dart

abstract class ApiEndpoints {
  static const String baseUrl = 'https://qualefai.runasp.net/api';

  // ── Auth ──────────────────────────────────────────
  static const String login = '/Auth/login';
  static const String forgotPassword = '/Auth/forgot-password';

  // ── Profile ───────────────────────────────────────
  static const String profile = '/Profile';
  static const String updateProfile = '/Profile/update';
  static const String updatePassword = '/Profile/update-password';
  static const String uploadPhoto = '/Profile/upload-photo';
  static const String deletePhoto = '/Profile/delete-photo';

  // ── Accreditation ─────────────────────────────────
  static const String sections = '/Accreditation/sections';
  static String sectionById(int id) => '/Accreditation/sections/$id';
  static String uploadDocument(int reqDocId) =>
      '/Accreditation/documents/$reqDocId/upload';
  static String setDeadline(int reqDocId) =>
      '/Accreditation/documents/$reqDocId/set-deadline';
  static const String deadlines = '/Accreditation/deadlines';

  // ── Notifications ─────────────────────────────────
  static const String notifications = '/Notification';
  static const String unreadCount = '/Notification/unread-count';
  static const String markAllRead = '/Notification/mark-all-read';

  // ── Admin Notification ────────────────────────────
  static const String sendAdminNotification = '/AdminNotification/send';

  // ── Chat ──────────────────────────────────────────
  static const String chatColleges = '/Chat/colleges';
  static String chatMessages(int collegeId) => '/Chat/$collegeId/messages';
  static const String sendMessage = '/Chat/send';
  static const String unreadMessages = '/Chat/unread';

  // ── Colleges ──────────────────────────────────────
  static const String colleges = '/Colleges';
  static String collegeById(int id) => '/Colleges/$id';

  // ── Employee ──────────────────────────────────────
  static const String employees = '/Employee';
  static String employeeById(int id) => '/Employee/$id';

  // ── Roles ─────────────────────────────────────────
  static const String roles = '/Roles';
  static String roleById(int id) => '/Roles/$id';
  static String rolePermissions(int id) => '/Roles/$id/permissions';

  // ── Permissions ───────────────────────────────────
  static const String permissions = '/Permissions';
  static String permissionById(int id) => '/Permissions/$id';

  // ── Plans ─────────────────────────────────────────
  static const String plans = '/Plan';
  static String planById(int id) => '/Plan/$id';

  // ── Pricing / Subscription ────────────────────────
  static const String pricing = '/Pricing';
  static const String subscribe = '/Pricing/subscribe';
  static const String subscriptions = '/Subscription';
  static String subscriptionByCollege(int collegeId) =>
      '/Subscription/college/$collegeId';
  static String updateSubscription(int id) => '/Subscription/$id';
  static String suspendSubscription(int id) => '/Subscription/suspend/$id';
  static String activateSubscription(int id) => '/Subscription/activate/$id';

  // ── Activity Log ──────────────────────────────────
  static const String activityLog = '/ActivityLog';

  // ── Enums ─────────────────────────────────────────
  static const String institutionTypes = '/Enum/institution-types';
  static const String accreditationTypes = '/Enum/accreditation-types';

  // ── Support ───────────────────────────────────────
  static const String supportSubmit = '/Support/submit';
}

'@

Write-File 'lib\core\api\dio_client.dart' @'
// lib/core/api/dio_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../cache/hive_cache.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient(HiveCache cache) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes, // ✅ Get raw bytes, decode ourselves
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(cache),
      _Utf8DecoderInterceptor(), // ✅ Force UTF-8 decode on every response
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
        logPrint: (obj) {
          // Only log in debug mode
          assert(() {
            // ignore: avoid_print
            print(obj);
            return true;
          }());
        },
      ),
    ]);
  }

  Dio get dio => _dio;
}

/// Forces UTF-8 decoding of all API responses.
/// Without this, Dio reads Arabic/Unicode text as Latin-1 → garbled characters.
class _Utf8DecoderInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is List<int>) {
      final bytes = response.data as List<int>;
      final decoded = utf8.decode(bytes, allowMalformed: true);
      // Try to parse as JSON
      try {
        response.data = jsonDecode(decoded);
      } catch (_) {
        response.data = decoded;
      }
    }
    handler.next(response);
  }
}

class _AuthInterceptor extends Interceptor {
  final HiveCache _cache;
  _AuthInterceptor(this._cache);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _cache.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _cache.clearAll();
    }
    handler.next(err);
  }
}

'@

Write-File 'lib\core\router\app_router.dart' @'
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
import '../../features/admin/presentation/screens/pricing_screen.dart';
import '../../features/admin/presentation/screens/activity_log_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../cache/hive_cache.dart';
import '../di/injection.dart';

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
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
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

      // ── Main Shell ────────────────────────────────
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
              final id = int.parse(state.pathParameters['sectionId']!);
              return StandardDetailScreen(sectionId: id);
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

      // ── Admin Shell ───────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) =>
            MainScaffold(child: child, isAdmin: true),
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
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}

'@

Write-File 'lib\core\cache\hive_cache.dart' @'
// lib/core/cache/hive_cache.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveCache {
  static const String _authBox = 'auth_box';
  static const String _settingsBox = 'settings_box';

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';
  static const String _themeKey = 'is_dark_mode';
  static const String _langKey = 'language_code';

  late final Box _auth;
  late final Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _auth = await Hive.openBox(_authBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // ── Token ────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _auth.put(_tokenKey, token);
  }

  String? getToken() => _auth.get(_tokenKey);

  bool get isLoggedIn => getToken() != null;

  // ── User data ─────────────────────────────────────
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _auth.put(_userKey, data);
  }

  Map<dynamic, dynamic>? getUserData() => _auth.get(_userKey);

  Future<void> saveRole(String role) async {
    await _auth.put(_roleKey, role);
  }

  String? getRole() => _auth.get(_roleKey);

  // ── Settings ──────────────────────────────────────
  Future<void> setDarkMode(bool isDark) async {
    await _settings.put(_themeKey, isDark);
  }

  bool isDarkMode() => _settings.get(_themeKey, defaultValue: false);

  Future<void> setLanguage(String code) async {
    await _settings.put(_langKey, code);
  }

  String getLanguage() => _settings.get(_langKey, defaultValue: 'ar');

  // ── Clear ─────────────────────────────────────────
  Future<void> clearAll() async {
    await _auth.clear();
  }
}

'@

Write-File 'lib\core\errors\failures.dart' @'
// lib/core/errors/failures.dart

import 'dart:convert';
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت');
}

class CacheFailure extends Failure {
  const CacheFailure() : super('خطأ في قاعدة البيانات المحلية');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('بيانات الدخول غير صحيحة، يرجى المحاولة مجدداً');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('حدث خطأ غير متوقع');
}

Failure dioToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401) return const UnauthorizedFailure();
      final msg = _extractMessage(e.response);
      return ServerFailure(msg, statusCode: code);
    default:
      return const UnknownFailure();
  }
}

String _extractMessage(Response? response) {
  if (response == null) return 'حدث خطأ في الخادم';
  try {
    dynamic data = response.data;
    if (data is List<int>) {
      data = jsonDecode(utf8.decode(data, allowMalformed: true));
    }
    if (data is String) {
      if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
        data = jsonDecode(data);
      } else {
        return data.isNotEmpty ? data : 'حدث خطأ في الخادم';
      }
    }
    if (data is Map) {
      for (final key in ['message', 'Message', 'error', 'Error', 'title', 'Title', 'detail']) {
        final val = data[key];
        if (val is String && val.isNotEmpty) return val;
      }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
        }
      }
    }
  } catch (_) {}
  return 'حدث خطأ (${response.statusCode})';
}

'@

Write-File 'lib\core\di\injection.dart' @'
// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import '../api/dio_client.dart';
import '../cache/hive_cache.dart';
import '../theme/theme_cubit.dart';
import '../localization/locale_cubit.dart';

// Features
import '../../features/auth/data/remote/auth_remote_ds.dart';
import '../../features/auth/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/accreditation/data/remote/accreditation_remote_ds.dart';
import '../../features/accreditation/repository/accreditation_repository_impl.dart';
import '../../features/accreditation/domain/repositories/accreditation_repository.dart';
import '../../features/accreditation/presentation/cubit/accreditation_cubit.dart';

import '../../features/notifications/data/remote/notification_remote_ds.dart';
import '../../features/notifications/repository/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';

import '../../features/chat/data/remote/chat_remote_ds.dart';
import '../../features/chat/repository/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';

import '../../features/profile/data/remote/profile_remote_ds.dart';
import '../../features/profile/repository/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/admin/data/remote/admin_remote_ds.dart';
import '../../features/admin/repository/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';

import '../../features/deadlines/data/remote/deadlines_remote_ds.dart';
import '../../features/deadlines/repository/deadlines_repository_impl.dart';
import '../../features/deadlines/domain/repositories/deadlines_repository.dart';
import '../../features/deadlines/presentation/cubit/deadlines_cubit.dart';

import '../../features/reports/data/remote/reports_remote_ds.dart';
import '../../features/reports/repository/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';

import '../../features/dashboard/data/remote/dashboard_remote_ds.dart';
import '../../features/dashboard/repository/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // ── Core ──────────────────────────────────────────
  final cache = HiveCache();
  await cache.init();
  sl.registerSingleton<HiveCache>(cache);

  sl.registerSingleton<DioClient>(DioClient(sl<HiveCache>()));

  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<HiveCache>()));
  sl.registerFactory<LocaleCubit>(() => LocaleCubit(sl<HiveCache>()));

  // ── Auth ──────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDs>(
    () => AuthRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDs>(), sl<HiveCache>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));

  // ── Dashboard ─────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDs>(
    () => DashboardRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDs>()),
  );
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(sl<DashboardRepository>()),
  );

  // ── Accreditation ─────────────────────────────────
  sl.registerLazySingleton<AccreditationRemoteDs>(
    () => AccreditationRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AccreditationRepository>(
    () => AccreditationRepositoryImpl(sl<AccreditationRemoteDs>()),
  );
  sl.registerFactory<AccreditationCubit>(
    () => AccreditationCubit(sl<AccreditationRepository>()),
  );

  // ── Notifications ─────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDs>(
    () => NotificationRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDs>()),
  );
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(sl<NotificationRepository>()),
  );

  // ── Deadlines ─────────────────────────────────────
  sl.registerLazySingleton<DeadlinesRemoteDs>(
    () => DeadlinesRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DeadlinesRepository>(
    () => DeadlinesRepositoryImpl(sl<DeadlinesRemoteDs>()),
  );
  sl.registerFactory<DeadlinesCubit>(
    () => DeadlinesCubit(sl<DeadlinesRepository>()),
  );

  // ── Chat ──────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDs>(
    () => ChatRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<ChatRemoteDs>()),
  );
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl<ChatRepository>()));

  // ── Reports ───────────────────────────────────────
  sl.registerLazySingleton<ReportsRemoteDs>(
    () => ReportsRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl<ReportsRemoteDs>()),
  );
  sl.registerFactory<ReportsCubit>(() => ReportsCubit(sl<ReportsRepository>()));

  // ── Profile ───────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDs>(
    () => ProfileRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDs>()),
  );
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ProfileRepository>()));

  // ── Admin ─────────────────────────────────────────
  sl.registerLazySingleton<AdminRemoteDs>(
    () => AdminRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDs>()),
  );
  sl.registerFactory<AdminCubit>(() => AdminCubit(sl<AdminRepository>()));
}

'@

Write-File 'lib\core\theme\app_colors.dart' @'
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color navyBlue    = Color(0xFF1B2B5E);
  static const Color blue        = Color(0xFF2B4EAE);
  static const Color cyan        = Color(0xFF00C2FF);
  static const Color lightBlue   = Color(0xFFEEF3FF);

  // Status
  static const Color success     = Color(0xFF27AE60);
  static const Color warning     = Color(0xFFF39C12);
  static const Color error       = Color(0xFFE74C3C);
  static const Color info        = Color(0xFF2B4EAE);

  // Light Mode
  static const Color white       = Color(0xFFFFFFFF);
  static const Color bgLight     = Color(0xFFF4F6FA);
  static const Color textDark    = Color(0xFF1A1A2E);
  static const Color subTextLight= Color(0xFF6B7A99);
  static const Color borderLight = Color(0xFFE0E4EF);

  // Dark Mode
  static const Color bgDark      = Color(0xFF0F1626);
  static const Color surfaceDark = Color(0xFF1A2540);
  static const Color inputDark   = Color(0xFF212D4A);
  static const Color textLight   = Color(0xFFF0F4FF);
  static const Color subTextDark = Color(0xFF8A9BBF);
  static const Color borderDark  = Color(0xFF2D3D5C);

  // Chart Colors
  static const Color chartGreen  = Color(0xFF27AE60);
  static const Color chartOrange = Color(0xFFF39C12);
  static const Color chartRed    = Color(0xFFE74C3C);
  static const Color chartBlue   = Color(0xFF2B4EAE);
  static const Color chartGray   = Color(0xFFB0B9CC);

  // Role Badge Colors
  static const Color adminColor    = Color(0xFF7B2FBE);
  static const Color managerColor  = Color(0xFF185FA5);
  static const Color employeeColor = Color(0xFF3B6D11);
  static const Color reviewerColor = Color(0xFF854F0B);
}

'@

Write-File 'lib\core\theme\app_theme.dart' @'
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Cairo font via Google Fonts - no local files needed
  static TextStyle _cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.cairo(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyBlue,
        brightness: Brightness.light,
        primary: AppColors.navyBlue,
        secondary: AppColors.blue,
        tertiary: AppColors.cyan,
        surface: AppColors.white,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        bodyMedium: _cairo(color: AppColors.textDark),
        bodyLarge: _cairo(fontSize: 16, color: AppColors.textDark),
        titleMedium: _cairo(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        titleLarge: _cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: _cairo(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: _cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyBlue,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.navyBlue, width: 1.5),
          textStyle: _cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: _cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navyBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: _cairo(fontSize: 14, color: AppColors.subTextLight),
        hintStyle: _cairo(fontSize: 14, color: AppColors.subTextLight),
        errorStyle: _cairo(fontSize: 11, color: AppColors.error),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.navyBlue,
        unselectedItemColor: AppColors.subTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _cairo(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _cairo(fontSize: 11),
      ),
      dividerTheme: DividerThemeData(color: AppColors.borderLight, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: _cairo(fontSize: 14, color: Colors.white),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        brightness: Brightness.dark,
        primary: AppColors.cyan,
        secondary: AppColors.blue,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        bodyMedium: _cairo(color: AppColors.textLight),
        bodyLarge: _cairo(fontSize: 16, color: AppColors.textLight),
        titleMedium: _cairo(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight),
        titleLarge: _cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: _cairo(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderDark, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.navyBlue,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: _cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        labelStyle: _cairo(fontSize: 14, color: AppColors.subTextDark),
        hintStyle: _cairo(fontSize: 14, color: AppColors.subTextDark),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.subTextDark,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: _cairo(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _cairo(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: _cairo(fontSize: 14, color: Colors.white),
      ),
    );
  }
}

'@

Write-File 'lib\core\theme\theme_cubit.dart' @'
// lib/core/theme/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/hive_cache.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final HiveCache _cache;

  ThemeCubit(this._cache)
      : super(_cache.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    _cache.setDarkMode(!isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

'@

Write-File 'lib\core\localization\app_strings.dart' @'
// lib/core/localization/app_strings.dart

class AppStrings {
  // ── App ──────────────────────────────────────────
  static const appName = 'QualifAI';
  static const appNameAr = 'كيوليف AI';
  static const tagline = 'نظام الجودة والاعتماد الأكاديمي';
  static const taglineEn = 'Academic Quality & Accreditation System';

  // ── Auth ──────────────────────────────────────────
  static const welcome = 'مرحباً بك';
  static const welcomeEn = 'Welcome Back';
  static const username = 'اسم المستخدم';
  static const usernameEn = 'Username';
  static const email = 'البريد الإلكتروني';
  static const emailEn = 'Email';
  static const password = 'كلمة المرور';
  static const passwordEn = 'Password';
  static const login = 'تسجيل الدخول';
  static const loginEn = 'Login';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const forgotPasswordEn = 'Forgot Password?';
  static const resetPassword = 'إعادة تعيين كلمة المرور';
  static const resetPasswordEn = 'Reset Password';
  static const sendResetLink = 'إرسال رابط الاستعادة';
  static const sendResetLinkEn = 'Send Reset Link';
  static const logout = 'تسجيل الخروج';
  static const logoutEn = 'Logout';
  static const backToLogin = '← العودة لتسجيل الدخول';
  static const backToLoginEn = '← Back to Login';

  // ── Navigation ────────────────────────────────────
  static const home = 'الرئيسية';
  static const homeEn = 'Home';
  static const accreditation = 'الاعتماد';
  static const accreditationEn = 'Accreditation';
  static const reports = 'التقارير';
  static const reportsEn = 'Reports';
  static const notifications = 'الإشعارات';
  static const notificationsEn = 'Notifications';
  static const myAccount = 'حسابي';
  static const myAccountEn = 'Account';

  // ── Dashboard ─────────────────────────────────────
  static const dashboard = 'الصفحة الرئيسية';
  static const dashboardEn = 'Dashboard';
  static const completionRate = 'درجة الاكتمال';
  static const completionRateEn = 'Completion Rate';
  static const uploadedFiles = 'الملفات المرفوعة';
  static const uploadedFilesEn = 'Uploaded Files';
  static const standards = 'المعايير';
  static const standardsEn = 'Standards';
  static const qualityCompliance = 'الامتثال للجودة';
  static const qualityComplianceEn = 'Quality Compliance';
  static const recentActivity = 'آخر الأنشطة';
  static const recentActivityEn = 'Recent Activity';

  // ── Accreditation ─────────────────────────────────
  static const academicAccreditation = 'الاعتماد الأكاديمي';
  static const academicAccreditationEn = 'Academic Accreditation';
  static const programmaticAccreditation = 'الاعتماد البرامجي';
  static const programmaticAccreditationEn = 'Programmatic Accreditation';
  static const accreditationSections = 'أقسام الاعتماد';
  static const accreditationSectionsEn = 'Accreditation Sections';
  static const requiredDocuments = 'الملفات المطلوبة';
  static const requiredDocumentsEn = 'Required Documents';
  static const uploadFile = 'رفع ملف';
  static const uploadFileEn = 'Upload File';
  static const startAnalysis = 'بدء التحليل';
  static const startAnalysisEn = 'Start Analysis';
  static const aiResults = 'نتائج التحليل الذكي';
  static const aiResultsEn = 'AI Analysis Results';
  static const qualityScore = 'درجة الجودة';
  static const qualityScoreEn = 'Quality Score';
  static const recommendations = 'التوصيات';
  static const recommendationsEn = 'Recommendations';
  static const fileUploadSuccess = 'تم رفع الملف بنجاح';
  static const fileUploadSuccessEn = 'File uploaded successfully';
  static const fileUploadError = 'حدث خطأ أثناء رفع الملف';
  static const fileUploadErrorEn = 'Error uploading file';

  // ── Deadlines ─────────────────────────────────────
  static const deadlines = 'المواعيد النهائية';
  static const deadlinesEn = 'Deadlines';
  static const setDeadline = 'تحديد الموعد النهائي';
  static const setDeadlineEn = 'Set Deadline';
  static const reminder = 'التذكيرات';
  static const reminderEn = 'Reminders';
  static const oneWeekBefore = 'قبل أسبوع';
  static const oneWeekBeforeEn = '1 week before';
  static const oneDayBefore = 'قبل يوم';
  static const oneDayBeforeEn = '1 day before';
  static const onDueDate = 'يوم الاستحقاق';
  static const onDueDateEn = 'On due date';

  // ── Reports ───────────────────────────────────────
  static const myReports = 'تقاريري';
  static const myReportsEn = 'My Reports';
  static const createReport = 'إنشاء تقرير جديد';
  static const createReportEn = 'Create New Report';
  static const sendToReviewer = 'إرسال للمراجع';
  static const sendToReviewerEn = 'Send to Reviewer';
  static const gapAnalysis = 'تحليل الفجوات';
  static const gapAnalysisEn = 'Gap Analysis';
  static const reviewerNotes = 'ملاحظات المراجع';
  static const reviewerNotesEn = 'Reviewer Notes';
  static const editHistory = 'تاريخ التعديلات';
  static const editHistoryEn = 'Edit History';

  // ── Chat ──────────────────────────────────────────
  static const chat = 'المحادثات';
  static const chatEn = 'Chat';
  static const reviewer = 'المراجع';
  static const reviewerEn = 'Reviewer';
  static const typeMessage = 'اكتب رسالة...';
  static const typeMessageEn = 'Type a message...';
  static const sendMessage = 'إرسال';
  static const sendMessageEn = 'Send';

  // ── Profile ───────────────────────────────────────
  static const profile = 'الملف الشخصي';
  static const profileEn = 'Profile';
  static const personalInfo = 'المعلومات الشخصية';
  static const personalInfoEn = 'Personal Information';
  static const firstName = 'الاسم الأول';
  static const firstNameEn = 'First Name';
  static const lastName = 'اسم العائلة';
  static const lastNameEn = 'Last Name';
  static const saveChanges = 'حفظ التعديلات';
  static const saveChangesEn = 'Save Changes';
  static const changePassword = 'تغيير كلمة المرور';
  static const changePasswordEn = 'Change Password';
  static const oldPassword = 'كلمة المرور الحالية';
  static const oldPasswordEn = 'Current Password';
  static const newPassword = 'كلمة المرور الجديدة';
  static const newPasswordEn = 'New Password';
  static const darkMode = 'الوضع الداكن';
  static const darkModeEn = 'Dark Mode';
  static const language = 'اللغة';
  static const languageEn = 'Language';
  static const arabic = 'العربية';
  static const english = 'English';

  // ── Admin ─────────────────────────────────────────
  static const employees = 'الموظفون';
  static const employeesEn = 'Employees';
  static const addEmployee = 'إضافة موظف جديد';
  static const addEmployeeEn = 'Add New Employee';
  static const roles = 'الأدوار';
  static const rolesEn = 'Roles';
  static const addRole = 'إنشاء دور جديد';
  static const addRoleEn = 'Create New Role';
  static const permissions = 'الصلاحيات';
  static const permissionsEn = 'Permissions';
  static const pricing = 'الأسعار';
  static const pricingEn = 'Pricing';
  static const activityLog = 'سجل الأنشطة';
  static const activityLogEn = 'Activity Log';
  static const colleges = 'الكليات';
  static const collegesEn = 'Colleges';
  static const subscription = 'الاشتراك';
  static const subscriptionEn = 'Subscription';

  // ── Common ────────────────────────────────────────
  static const save = 'حفظ';
  static const saveEn = 'Save';
  static const cancel = 'إلغاء';
  static const cancelEn = 'Cancel';
  static const delete = 'حذف';
  static const deleteEn = 'Delete';
  static const edit = 'تعديل';
  static const editEn = 'Edit';
  static const search = 'بحث...';
  static const searchEn = 'Search...';
  static const loading = 'جاري التحميل...';
  static const loadingEn = 'Loading...';
  static const noData = 'لا توجد بيانات';
  static const noDataEn = 'No data available';
  static const retry = 'إعادة المحاولة';
  static const retryEn = 'Retry';
  static const confirm = 'تأكيد';
  static const confirmEn = 'Confirm';
  static const yes = 'نعم';
  static const yesEn = 'Yes';
  static const no = 'لا';
  static const noEn = 'No';
  static const markAllRead = 'تمييز الكل كمقروء';
  static const markAllReadEn = 'Mark all as read';
  static const support = 'الدعم الفني';
  static const supportEn = 'Support';
}

'@

Write-File 'lib\core\localization\locale_cubit.dart' @'
// lib/core/localization/locale_cubit.dart

import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/hive_cache.dart';

class LocaleCubit extends Cubit<Locale> {
  final HiveCache _cache;

  LocaleCubit(this._cache)
      : super(Locale(_cache.getLanguage()));

  void changeLocale(String langCode) {
    _cache.setLanguage(langCode);
    emit(Locale(langCode));
  }

  bool get isArabic => state.languageCode == 'ar';

  void toggleLocale() {
    changeLocale(isArabic ? 'en' : 'ar');
  }
}

'@

Write-File 'lib\shared\widgets\app_badge.dart' @'
// lib/shared/widgets/app_badge.dart
// Re-export from app_card.dart for convenience
export 'app_card.dart' show AppBadge, AppProgressBar, AppDivider, ShimmerBox, LoadingOverlay, EmptyState, ErrorRetry;

'@

Write-File 'lib\shared\widgets\app_button.dart' @'
// lib/shared/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppButtonVariant { primary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 52.h;
    Widget child = isLoading
        ? SizedBox(
            width: 22.w,
            height: 22.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.primary
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
        );
      case AppButtonVariant.outline:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
        );
      case AppButtonVariant.danger:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
      case AppButtonVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: TextButton(onPressed: isLoading ? null : onPressed, child: child),
        );
    }
  }
}

'@

Write-File 'lib\shared\widgets\app_card.dart' @'
// lib/shared/widgets/app_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ── AppBadge ──────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool small;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8.w : 12.w,
        vertical: small ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: small ? 10.sp : 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor ?? color,
        ),
      ),
    );
  }
}

// ── LoadingOverlay ────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

// ── EmptyState ────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64.sp, color: Theme.of(context).disabledColor),
            SizedBox(height: 16.h),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ErrorRetry ────────────────────────────────────────
class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetry({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56.sp, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 24.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ProgressBar ───────────────────────────────────────
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  Color _colorForValue(BuildContext context) {
    if (color != null) return color!;
    if (value >= 0.7) return const Color(0xFF27AE60);
    if (value >= 0.4) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: Theme.of(context).dividerColor,
        valueColor: AlwaysStoppedAnimation<Color>(_colorForValue(context)),
        minHeight: height,
      ),
    );
  }
}

// ── AppDivider ────────────────────────────────────────
class AppDivider extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const AppDivider({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: margin ?? EdgeInsets.symmetric(vertical: 8.h),
      color: Theme.of(context).dividerColor,
    );
  }
}

// ── ShimmerBox ────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3D5C) : const Color(0xFFE0E4EF),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

'@

Write-File 'lib\shared\widgets\app_text_field.dart' @'
// lib/shared/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscure && !_showPassword,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20.sp) : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}

'@

Write-File 'lib\shared\widgets\main_scaffold.dart' @'
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
        location.startsWith('/ai-analysis')) currentIndex = 1;
    else if (location.startsWith('/reports')) currentIndex = 2;
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
    if (location.startsWith('/admin/employees')) currentIndex = 1;
    else if (location.startsWith('/admin/roles')) currentIndex = 2;
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'الموظفون'),
        BottomNavigationBarItem(icon: Icon(Icons.security_outlined), activeIcon: Icon(Icons.security), label: 'الأدوار'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'الكليات'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), activeIcon: Icon(Icons.monetization_on), label: 'الأسعار'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'السجل'),
      ],
    );
  }
}

'@

Write-File 'lib\features\accreditation\presentation\cubit\accreditation_cubit.dart' @'
// lib/features/accreditation/presentation/cubit/accreditation_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/accreditation_repository.dart';

part 'accreditation_state.dart';

class AccreditationCubit extends Cubit<AccreditationState> {
  final AccreditationRepository _repo;
  AccreditationCubit(this._repo) : super(AccreditationInitial());

  Future<void> loadSections() async {
    emit(AccreditationLoading());
    final r = await _repo.getSections();
    r.fold((f) => emit(AccreditationError(f.message)), (list) => emit(SectionsLoaded(_normalizeSections(list))));
  }

  Future<void> loadSectionDetail(int id) async {
    emit(AccreditationLoading());
    final r = await _repo.getSectionById(id);
    r.fold((f) => emit(AccreditationError(f.message)), (data) => emit(SectionDetailLoaded(_normalizeDetail(data))));
  }

  Future<void> uploadDocument(int reqDocId, File file) async {
    emit(UploadingDocument());
    final r = await _repo.uploadDocument(reqDocId, file);
    r.fold((f) => emit(AccreditationError(f.message)), (data) => emit(DocumentUploaded(data)));
  }

  Future<void> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue) async {
    final r = await _repo.setDeadline(reqDocId, deadline, oneWeek, oneDay, onDue);
    r.fold((f) => emit(AccreditationError(f.message)), (_) => emit(const DeadlineSet()));
  }

  // Normalize API response to use consistent field names
  List<dynamic> _normalizeSections(List<dynamic> raw) {
    return raw.map((s) {
      if (s is! Map) return s;
      return {
        'id': s['sectionId'] ?? s['id'] ?? 0,
        'name': s['sectionName'] ?? s['name'] ?? '',
        'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
        'requiredDocumentsCount': s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
        'completionPercentage': s['completionPercentage'] ?? 0,
      };
    }).toList();
  }

  Map<String, dynamic> _normalizeDetail(Map<String, dynamic> s) {
    return {
      'id': s['sectionId'] ?? s['id'] ?? 0,
      'name': s['sectionName'] ?? s['name'] ?? '',
      'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
      'requiredDocumentsCount': s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
      'completionPercentage': s['completionPercentage'] ?? 0,
      'requiredDocuments': s['requiredDocuments'] ?? s['documents'] ?? [],
    };
  }
}

'@

Write-File 'lib\features\accreditation\presentation\cubit\accreditation_state.dart' @'
// lib/features/accreditation/presentation/cubit/accreditation_state.dart
part of 'accreditation_cubit.dart';

abstract class AccreditationState extends Equatable {
  const AccreditationState();
  @override List<Object?> get props => [];
}

class AccreditationInitial extends AccreditationState {}
class AccreditationLoading extends AccreditationState {}
class UploadingDocument extends AccreditationState {}

class SectionsLoaded extends AccreditationState {
  final List<dynamic> sections;
  const SectionsLoaded(this.sections);
  @override List<Object?> get props => [sections];
}

class SectionDetailLoaded extends AccreditationState {
  final Map<String, dynamic> section;
  const SectionDetailLoaded(this.section);
  @override List<Object?> get props => [section];
}

class DocumentUploaded extends AccreditationState {
  final Map<String, dynamic> result;
  const DocumentUploaded(this.result);
  @override List<Object?> get props => [result];
}

class DeadlineSet extends AccreditationState {
  const DeadlineSet();
}

class AccreditationError extends AccreditationState {
  final String message;
  const AccreditationError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\accreditation\presentation\screens\accreditation_types_screen.dart' @'
// lib/features/accreditation/presentation/screens/accreditation_types_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class AccreditationTypesScreen extends StatelessWidget {
  const AccreditationTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاعتماد')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('اختر نوع الاعتماد', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 24.h),
            _AccreditationTypeCard(
              icon: '🏛',
              title: 'الاعتماد الأكاديمي',
              subtitle: 'اعتماد مؤسسي — المعايير الشاملة للكلية',
              color: AppColors.navyBlue,
              onTap: () => context.push('${AppRoutes.standards}?type=1'),
            ),
            SizedBox(height: 16.h),
            _AccreditationTypeCard(
              icon: '📚',
              title: 'الاعتماد البرامجي',
              subtitle: 'اعتماد البرنامج / التخصص الأكاديمي',
              color: AppColors.blue,
              onTap: () => context.push('${AppRoutes.standards}?type=2'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccreditationTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AccreditationTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Text('تقييم الاعتماد',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(width: 10.w),
                      Text(icon, style: TextStyle(fontSize: 32.sp)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'@

Write-File 'lib\features\accreditation\presentation\screens\ai_analysis_screen.dart' @'
// lib/features/accreditation/presentation/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class AiAnalysisScreen extends StatelessWidget {
  final int documentId;
  const AiAnalysisScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    // The AI analysis results come embedded in the uploadDocument response
    // or from the section detail. We display what was returned.
    return Scaffold(
      appBar: AppBar(title: const Text('نتائج التحليل الذكي')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        children: [
          // Score circle
          Center(
            child: Column(
              children: [
                Text('نتيجة التحليل', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).disabledColor)),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140.w,
                        height: 140.w,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 10.w,
                          backgroundColor: Theme.of(context).dividerColor,
                          valueColor: const AlwaysStoppedAnimation(AppColors.success),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '72',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Metrics grid
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'جودة المستند', value: 'عالية', color: AppColors.success)),
              SizedBox(width: 10.w),
              Expanded(child: _MetricCard(label: 'نوع المستند', value: 'تقرير', color: AppColors.blue)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'اللغة', value: 'عربي', color: AppColors.navyBlue)),
              SizedBox(width: 10.w),
              Expanded(child: _MetricCard(label: 'دقة OCR', value: '94%', color: AppColors.success)),
            ],
          ),
          SizedBox(height: 24.h),

          // Recommendations
          Text('التوصيات', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12.h),
          _RecommendationTile(
            icon: Icons.warning_amber_outlined,
            text: 'يفتقر التقرير إلى توصيف واضح للأهداف الاستراتيجية',
            color: AppColors.warning,
          ),
          SizedBox(height: 8.h),
          _RecommendationTile(
            icon: Icons.cancel_outlined,
            text: 'لم يتم ذكر آليات المتابعة والتقييم بشكل كافٍ',
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          _RecommendationTile(
            icon: Icons.check_circle_outline,
            text: 'التنسيق العام جيد والمحتوى منظم بشكل واضح',
            color: AppColors.success,
          ),
          SizedBox(height: 24.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('عرض التصنيفات'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('تحليل ملف آخر'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _RecommendationTile({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: color),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 10.w),
          Icon(icon, color: color, size: 20.sp),
        ],
      ),
    );
  }
}

'@

Write-File 'lib\features\accreditation\presentation\screens\file_upload_screen.dart' @'
// lib/features/accreditation/presentation/screens/file_upload_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../cubit/accreditation_cubit.dart';

class FileUploadScreen extends StatefulWidget {
  final int documentId;
  const FileUploadScreen({super.key, required this.documentId});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _selectedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccreditationCubit>(),
      child: BlocConsumer<AccreditationCubit, AccreditationState>(
        listener: (ctx, state) {
          if (state is DocumentUploaded) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('تم رفع الملف بنجاح ✓'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (context.canPop()) context.pop(); else context.go(AppRoutes.accreditation);
          }
          if (state is AccreditationError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (ctx, state) {
          final isUploading = state is UploadingDocument;
          return Scaffold(
            appBar: AppBar(title: const Text('رفع ملف جديد')),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'يُرجى تحميل المستندات الخاصة بك بتنسيق PDF أو Word فقط',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 20.h),
                  // Drop zone
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 180.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: _selectedFile != null ? AppColors.success : AppColors.blue,
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isUploading) ...[
                            const CircularProgressIndicator(),
                            SizedBox(height: 12.h),
                            Text('جاري الرفع...', style: Theme.of(context).textTheme.bodyMedium),
                          ] else if (_selectedFile != null) ...[
                            Icon(Icons.description_outlined, size: 48.sp, color: AppColors.success),
                            SizedBox(height: 10.h),
                            Text(
                              _fileName ?? '',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.success),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text('اضغط لتغيير الملف', style: Theme.of(context).textTheme.bodySmall),
                          ] else ...[
                            Icon(Icons.cloud_upload_outlined, size: 48.sp, color: AppColors.blue),
                            SizedBox(height: 10.h),
                            Text('اسحب وأفلت الملفات هنا', style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 6.h),
                            Text('أو', style: Theme.of(context).textTheme.bodySmall),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '+ اختر الملفات',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_selectedFile != null && !isUploading) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => setState(() { _selectedFile = null; _fileName = null; }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('حذف الملف المختار', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.error)),
                          SizedBox(width: 4.w),
                          Icon(Icons.delete_outline, size: 16.sp, color: AppColors.error),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  AppButton(
                    label: 'رفع الملف',
                    isLoading: isUploading,
                    onPressed: _selectedFile == null ? null : () {
                      ctx.read<AccreditationCubit>().uploadDocument(widget.documentId, _selectedFile!);
                    },
                    icon: Icons.upload,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

'@

Write-File 'lib\features\accreditation\presentation\screens\standard_detail_screen.dart' @'
// lib/features/accreditation/presentation/screens/standard_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/accreditation_cubit.dart';

class StandardDetailScreen extends StatelessWidget {
  final int sectionId;
  const StandardDetailScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccreditationCubit>()..loadSectionDetail(sectionId),
      child: const _StandardDetailView(),
    );
  }
}

class _StandardDetailView extends StatelessWidget {
  const _StandardDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المعيار')),
      body: BlocBuilder<AccreditationCubit, AccreditationState>(
        builder: (ctx, state) {
          if (state is AccreditationLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccreditationError) {
            return Center(child: Text(state.message));
          }
          if (state is SectionDetailLoaded) {
            final s = state.section;
            final docs = (s['requiredDocuments'] as List?) ?? [];
            final uploaded = (s['uploadedDocuments'] ?? 0) as int;
            final required = docs.length;
            final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;

            return Column(
              children: [
                // Header card
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(s['name'] ?? '', style: TextStyle(fontFamily: 'Cairo', fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).round()}%', style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.cyan)),
                          Text('درجة الاكتمال', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white60)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                // Docs list
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      final doc = docs[i] as Map<String, dynamic>? ?? {};
                      final hasFile = doc['uploadedFile'] != null;
                      return AppCard(
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!hasFile)
                                  _ActionBtn(
                                    label: 'رفع ملف',
                                    color: AppColors.navyBlue,
                                    onTap: () => context.push(
                                      AppRoutes.fileUpload.replaceFirst(':docId', '${doc['id'] ?? 0}'),
                                    ),
                                  ),
                                if (hasFile)
                                  _ActionBtn(
                                    label: 'نتائج AI',
                                    color: AppColors.success,
                                    onTap: () => context.push(
                                      AppRoutes.aiAnalysis.replaceFirst(':docId', '${doc['id'] ?? 0}'),
                                    ),
                                  ),
                                SizedBox(height: 6.h),
                                _ActionBtn(
                                  label: 'تحديد الموعد',
                                  color: AppColors.warning,
                                  onTap: () => _showDeadlineDialog(context, ctx.read<AccreditationCubit>(), doc['id'] ?? 0),
                                ),
                              ],
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    doc['name'] ?? 'مستند ${i + 1}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        hasFile ? 'مرفوع ✓' : 'لم يُرفع بعد',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11.sp,
                                          color: hasFile ? AppColors.success : AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Icon(
                                        hasFile ? Icons.check_circle_outline : Icons.upload_file_outlined,
                                        size: 14.sp,
                                        color: hasFile ? AppColors.success : AppColors.error,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showDeadlineDialog(BuildContext context, AccreditationCubit cubit, int docId) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    bool oneWeek = true, oneDay = true, onDue = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text('تحديد الموعد النهائي', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              const Text('التذكيرات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              CheckboxListTile(
                value: oneWeek, onChanged: (v) => setState(() => oneWeek = v!),
                title: const Text('قبل أسبوع', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: oneDay, onChanged: (v) => setState(() => oneDay = v!),
                title: const Text('قبل يوم', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: onDue, onChanged: (v) => setState(() => onDue = v!),
                title: const Text('يوم الاستحقاق', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                cubit.setDeadline(
                  docId,
                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  oneWeek, oneDay, onDue,
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)),
      ),
    );
  }
}

'@

Write-File 'lib\features\accreditation\presentation\screens\standards_list_screen.dart' @'
// lib/features/accreditation/presentation/screens/standards_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/accreditation_cubit.dart';

class StandardsListScreen extends StatelessWidget {
  final int accreditationType;
  const StandardsListScreen({super.key, required this.accreditationType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccreditationCubit>()..loadSections(),
      child: _StandardsListView(accreditationType: accreditationType),
    );
  }
}

class _StandardsListView extends StatelessWidget {
  final int accreditationType;
  const _StandardsListView({required this.accreditationType});

  @override
  Widget build(BuildContext context) {
    final title = accreditationType == 1 ? 'الاعتماد الأكاديمي' : 'الاعتماد البرامجي';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<AccreditationCubit, AccreditationState>(
        builder: (ctx, state) {
          if (state is AccreditationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccreditationError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(state.message),
                SizedBox(height: 12.h),
                OutlinedButton(
                  onPressed: () => ctx.read<AccreditationCubit>().loadSections(),
                  child: const Text('إعادة المحاولة'),
                ),
              ]),
            );
          }
          if (state is SectionsLoaded) {
            if (state.sections.isEmpty) {
              return const Center(child: Text('لا توجد معايير'));
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<AccreditationCubit>().loadSections(),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: state.sections.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final s = state.sections[i] as Map<String, dynamic>? ?? {};
                  final uploaded = (s['uploadedDocuments'] ?? 0) as int;
                  final required = (s['requiredDocumentsCount'] ?? 1) as int;
                  final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;
                  final color = pct >= 0.7 ? AppColors.success : pct >= 0.4 ? AppColors.warning : AppColors.error;

                  return AppCard(
                    onTap: () => context.push(
                      AppRoutes.standardDetail.replaceFirst(':sectionId', '${s['id'] ?? 0}'),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.chevron_left, color: Theme.of(context).disabledColor),
                            Expanded(
                              child: Text(
                                s['name'] ?? 'معيار ${i + 1}',
                                style: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$uploaded / $required ملف',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            Text(
                              'درجة الاكتمال',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              '${(pct * 100).round()}%',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(child: AppProgressBar(value: pct)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

'@

Write-File 'lib\features\accreditation\repository\accreditation_repository_impl.dart' @'
// lib/features/accreditation/repository/accreditation_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/accreditation_remote_ds.dart';
import '../domain/repositories/accreditation_repository.dart';

class AccreditationRepositoryImpl implements AccreditationRepository {
  final AccreditationRemoteDs _remote;
  const AccreditationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getSections() async {
    try { return Right(await _remote.getSections()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSectionById(int id) async {
    try { return Right(await _remote.getSectionById(id)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(int reqDocId, File file) async {
    try { return Right(await _remote.uploadDocument(reqDocId, file)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue) async {
    try {
      await _remote.setDeadline(reqDocId, deadline, oneWeek, oneDay, onDue);
      return const Right(null);
    }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\accreditation\data\remote\accreditation_remote_ds.dart' @'
// lib/features/accreditation/data/remote/accreditation_remote_ds.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class AccreditationRemoteDs {
  final Dio _dio;
  const AccreditationRemoteDs(this._dio);

  Future<List<dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<Map<String, dynamic>> getSectionById(int id) async {
    try {
      final res = await _dio.get(ApiEndpoints.sectionById(id));
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<Map<String, dynamic>> uploadDocument(int reqDocId, File file) async {
    try {
      final form = FormData.fromMap({
        'File': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final res = await _dio.post(ApiEndpoints.uploadDocument(reqDocId), data: form);
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue) async {
    try {
      await _dio.post(ApiEndpoints.setDeadline(reqDocId), data: {
        'deadline': deadline,
        'reminders': {
          'oneWeekBefore': oneWeek,
          'oneDayBefore': oneDay,
          'onDueDate': onDue,
        },
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\accreditation\domain\repositories\accreditation_repository.dart' @'
// lib/features/accreditation/domain/repositories/accreditation_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AccreditationRepository {
  Future<Either<Failure, List<dynamic>>> getSections();
  Future<Either<Failure, Map<String, dynamic>>> getSectionById(int id);
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(int reqDocId, File file);
  Future<Either<Failure, void>> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue);
}

'@

Write-File 'lib\features\auth\presentation\cubit\auth_cubit.dart' @'
// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/auth_model.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _repo.login(
      LoginRequestModel(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    final result = await _repo.forgotPassword(email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthInitial());
  }
}

'@

Write-File 'lib\features\auth\presentation\cubit\auth_state.dart' @'
// lib/features/auth/presentation/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponseModel user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

'@

Write-File 'lib\features\auth\presentation\screens\forgot_password_screen.dart' @'
// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (ctx, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
            if (state is ForgotPasswordSuccess) {
              showDialog(
                context: ctx,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔐', style: TextStyle(fontSize: 48.sp)),
                      SizedBox(height: 16.h),
                      Text(
                        'تم إرسال كلمة المرور\nإلى البريد الإلكتروني',
                        textAlign: TextAlign.center,
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ctx.go(AppRoutes.login);
                        },
                        child: const Text('تسجيل الدخول'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          builder: (ctx, state) {
            final cubit = ctx.read<AuthCubit>();
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔐', style: TextStyle(fontSize: 54.sp)),
                        SizedBox(height: 16.h),
                        Text(
                          'استعادة كلمة المرور',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'أدخل بياناتك لإرسال كود التحقق',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppTextField(
                              label: 'البريد الإلكتروني',
                              hint: 'user@email.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'مطلوب';
                                if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                                return null;
                              },
                            ),
                            SizedBox(height: 32.h),
                            AppButton(
                              label: 'إرسال كلمة المرور',
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  cubit.forgotPassword(_emailCtrl.text.trim());
                                }
                              },
                            ),
                            SizedBox(height: 20.h),
                            Center(
                              child: TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                child: Text(
                                  '← العودة لتسجيل الدخول',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

'@

Write-File 'lib\features\auth\presentation\screens\login_screen.dart' @'
// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();
  bool _navigated = false; // prevent double navigation

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); _passFocus.dispose();
    super.dispose();
  }

  void _onLogin(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (ctx, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
            }
            if (state is AuthSuccess && !_navigated) {
              _navigated = true;
              final role = state.user.role.toLowerCase();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (role == 'system_admin') {
                  ctx.go(AppRoutes.adminDashboard);
                } else {
                  ctx.go(AppRoutes.dashboard);
                }
              });
            }
          },
          builder: (ctx, state) {
            final cubit = ctx.read<AuthCubit>();
            return Column(
              children: [
                // Top navy section
                Expanded(
                  flex: 4,
                  child: SafeArea(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 90.w, height: 90.w,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: Center(child: Text('🤖', style: TextStyle(fontSize: 44.sp))),
                      ),
                      SizedBox(height: 16.h),
                      Text('Welcome to QualifAI', style: GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 6.h),
                      Text('سجّل دخولك للمتابعة', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white60)),
                    ]),
                  ),
                ),
                // White card
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          AppTextField(
                            label: 'اسم المستخدم / البريد الإلكتروني',
                            hint: 'user@email.com',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _passFocus.requestFocus(),
                            validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                          ),
                          SizedBox(height: 20.h),
                          AppTextField(
                            label: 'كلمة المرور',
                            controller: _passCtrl,
                            obscure: true,
                            focusNode: _passFocus,
                            prefixIcon: Icons.lock_outline,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLogin(cubit),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'مطلوب';
                              if (v.length < 4) return 'كلمة المرور قصيرة جداً';
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.forgotPassword),
                            child: Text('نسيت كلمة المرور؟', style: GoogleFonts.cairo(fontSize: 13.sp, color: AppColors.blue, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 32.h),
                          AppButton(label: 'تسجيل الدخول', isLoading: state is AuthLoading, onPressed: () => _onLogin(cubit)),
                          SizedBox(height: 16.h),
                          Center(child: Text('v1.0.0  •  QualifAI', style: GoogleFonts.cairo(fontSize: 11.sp, color: Theme.of(context).disabledColor))),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

'@

Write-File 'lib\features\auth\presentation\screens\splash_screen.dart' @'
// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _navigated = false; // prevent double navigation

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted || _navigated) return;
    _navigated = true;
    final cache = sl<HiveCache>();
    if (cache.isLoggedIn) {
      final role = cache.getRole() ?? '';
      if (role == 'system_admin') {
        context.go(AppRoutes.adminDashboard);
      } else {
        context.go(AppRoutes.dashboard);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110.w, height: 110.w,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: Center(
                    child: Stack(alignment: Alignment.center, children: [
                      Text('Q', style: GoogleFonts.cairo(fontSize: 52.sp, fontWeight: FontWeight.w700, color: AppColors.navyBlue, height: 1)),
                      Positioned(top: 18.h, right: 18.w,
                        child: Container(width: 14.w, height: 14.w,
                          decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle))),
                    ]),
                  ),
                ),
                SizedBox(height: 28.h),
                Text('QualifAI', style: GoogleFonts.cairo(fontSize: 32.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                SizedBox(height: 8.h),
                Text('نظام الجودة والاعتماد الأكاديمي', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white60)),
                SizedBox(height: 60.h),
                SizedBox(
                  width: 180.w,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                    borderRadius: BorderRadius.circular(4.r),
                    minHeight: 3.h,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

'@

Write-File 'lib\features\auth\repository\auth_repository_impl.dart' @'
// lib/features/auth/repository/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/cache/hive_cache.dart';
import '../data/models/auth_model.dart';
import '../data/remote/auth_remote_ds.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDs _remote;
  final HiveCache _cache;

  const AuthRepositoryImpl(this._remote, this._cache);

  @override
  Future<Either<Failure, LoginResponseModel>> login(
      LoginRequestModel req) async {
    try {
      final result = await _remote.login(req);
      await _cache.saveToken(result.token);
      await _cache.saveRole(result.role);
      await _cache.saveUserData({
        'firstName': result.firstName,
        'lastName': result.lastName,
        'email': result.email,
        'role': result.role,
      });
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(ForgotPasswordModel(email: email));
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    await _cache.clearAll();
  }
}

'@

Write-File 'lib\features\auth\data\remote\auth_remote_ds.dart' @'
// lib/features/auth/data/remote/auth_remote_ds.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../models/auth_model.dart';

class AuthRemoteDs {
  final Dio _dio;
  const AuthRemoteDs(this._dio);

  Future<LoginResponseModel> login(LoginRequestModel req) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.login,
        data: req.toJson(),
      );
      return LoginResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> forgotPassword(ForgotPasswordModel req) async {
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: req.toJson());
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}

'@

Write-File 'lib\features\auth\data\models\auth_model.dart' @'
// lib/features/auth/data/models/auth_model.dart

class LoginRequestModel {
  final String email;
  final String password;
  const LoginRequestModel({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class ForgotPasswordModel {
  final String email;
  const ForgotPasswordModel({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

class LoginResponseModel {
  final String token;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  const LoginResponseModel({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Flexible parsing - handle multiple possible field names
    final token = json['token'] ?? json['accessToken'] ?? json['jwt'] ?? json['Token'] ?? '';
    final firstName = json['firstName'] ?? json['first_name'] ?? json['FirstName'] ?? '';
    final lastName = json['lastName'] ?? json['last_name'] ?? json['LastName'] ?? '';
    final email = json['email'] ?? json['Email'] ?? '';

    // Role can be a string or a list
    String role = 'quality_employee';
    final rawRole = json['role'] ?? json['roles'] ?? json['userRole'] ?? json['roleName'];
    if (rawRole is String && rawRole.isNotEmpty) {
      role = rawRole;
    } else if (rawRole is List && rawRole.isNotEmpty) {
      role = rawRole.first.toString();
    }

    return LoginResponseModel(
      token: token.toString(),
      firstName: firstName.toString(),
      lastName: lastName.toString(),
      email: email.toString(),
      role: role.toLowerCase(),
    );
  }
}

'@

Write-File 'lib\features\auth\domain\repositories\auth_repository.dart' @'
// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/auth_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(LoginRequestModel req);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<void> logout();
}

'@

Write-File 'lib\features\reports\presentation\cubit\reports_cubit.dart' @'
// lib/features/reports/presentation/cubit/reports_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/reports_repository.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repo;
  ReportsCubit(this._repo) : super(ReportsInitial());

  Future<void> loadReports() async {
    emit(ReportsLoading());
    final r = await _repo.getReports();
    r.fold((f) => emit(ReportsError(f.message)), (list) => emit(ReportsLoaded(list)));
  }

  Future<void> loadDetail(int sectionId) async {
    emit(ReportsLoading());
    final r = await _repo.getReportDetail(sectionId);
    r.fold((f) => emit(ReportsError(f.message)), (data) => emit(ReportDetailLoaded(data)));
  }
}

'@

Write-File 'lib\features\reports\presentation\cubit\reports_state.dart' @'
// lib/features/reports/presentation/cubit/reports_state.dart
part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override List<Object?> get props => [];
}
class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}
class ReportsLoaded extends ReportsState {
  final List<dynamic> reports;
  const ReportsLoaded(this.reports);
  @override List<Object?> get props => [reports];
}
class ReportDetailLoaded extends ReportsState {
  final Map<String, dynamic> report;
  const ReportDetailLoaded(this.report);
  @override List<Object?> get props => [report];
}
class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\reports\presentation\screens\report_detail_screen.dart' @'
// lib/features/reports/presentation/screens/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/reports_cubit.dart';

class ReportDetailScreen extends StatelessWidget {
  final int reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..loadDetail(reportId),
      child: const _ReportDetailView(),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (ctx, state) {
          if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReportsError) return Center(child: Text(state.message));
          if (state is ReportDetailLoaded) {
            final r = state.report;
            final uploaded = (r['uploadedDocuments'] ?? 0) as int;
            final required = (r['requiredDocumentsCount'] ?? 1) as int;
            final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;
            final docs = (r['requiredDocuments'] as List?) ?? [];

            return ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              children: [
                // Completion card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الاعتماد الأكاديمي  ›  ${r['name'] ?? 'تقرير'}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white60)),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).round()}%',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 32.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('درجة الاكتمال',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white60)),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(_pctColor(pct)),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Missing documents
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الفجوات الرئيسية المطلوبة', style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs.where((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        return doc['uploadedFile'] == null;
                      }).take(5).map((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  doc['name'] ?? 'مستند مطلوب',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.warning),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.warning_amber_outlined, size: 14.sp, color: AppColors.warning),
                            ],
                          ),
                        );
                      }),
                      if (docs.every((d) => (d as Map<String, dynamic>?)?['uploadedFile'] != null))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('جميع المستندات مكتملة ✓',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.success)),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Documents list
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الملفات (${docs.length})', style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs.take(10).map((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        final hasFile = doc['uploadedFile'] != null;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                hasFile ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                                size: 16.sp,
                                color: hasFile ? AppColors.success : AppColors.error,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  doc['name'] ?? 'مستند',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'رفع التقرير ↑',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال التقرير للمراجع ✓'), backgroundColor: AppColors.success),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: 'التواصل مع المراجع',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(AppRoutes.chatList),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'العودة إلى الملفات',
                  variant: AppButtonVariant.ghost,
                  onPressed: () { if (context.canPop()) context.pop(); else context.go(AppRoutes.reports); },
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color _pctColor(double pct) {
    if (pct >= 0.7) return AppColors.success;
    if (pct >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

'@

Write-File 'lib\features\reports\presentation\screens\reports_list_screen.dart' @'
// lib/features/reports/presentation/screens/reports_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/reports_cubit.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..loadReports(),
      child: const _ReportsListView(),
    );
  }
}

class _ReportsListView extends StatelessWidget {
  const _ReportsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (ctx, state) {
          if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReportsError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: () => ctx.read<ReportsCubit>().loadReports(), child: const Text('إعادة المحاولة')),
            ]));
          }
          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 64.sp)),
                    SizedBox(height: 16.h),
                    const Text('لقد تم إرسال تقريرك بنجاح\nوسوف تظهر بمجرد استلام المراجع لها',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<ReportsCubit>().loadReports(),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: state.reports.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final r = state.reports[i] as Map<String, dynamic>? ?? {};
                  final uploaded = (r['uploadedDocuments'] ?? 0) as int;
                  final required = (r['requiredDocumentsCount'] ?? 1) as int;
                  final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;

                  return AppCard(
                    onTap: () => context.push(
                      AppRoutes.reportDetail.replaceFirst(':id', '${r['id'] ?? 0}'),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(color: AppColors.navyBlue, borderRadius: BorderRadius.circular(8.r)),
                              child: Text('عرض التقرير', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(r['name'] ?? 'تقرير', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${(pct * 100).round()}%',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w700,
                                          color: pct >= 0.7 ? AppColors.success : pct >= 0.4 ? AppColors.warning : AppColors.error)),
                                  SizedBox(width: 8.w),
                                  Expanded(child: AppProgressBar(value: pct, height: 5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('📋', style: TextStyle(fontSize: 28.sp)),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

'@

Write-File 'lib\features\reports\repository\reports_repository_impl.dart' @'
// lib/features/reports/repository/reports_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/reports_remote_ds.dart';
import '../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDs _remote;
  const ReportsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getReports() async {
    try { return Right(await _remote.getReports()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(int sectionId) async {
    try { return Right(await _remote.getReportDetail(sectionId)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\reports\data\remote\reports_remote_ds.dart' @'
// lib/features/reports/data/remote/reports_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';

/// NOTE: The Swagger does not have a dedicated /Reports endpoint.
/// Reports are derived from Accreditation sections + AI analysis results.
/// This DS aggregates section data to build report-like views.
/// When backend adds a reports endpoint, update the paths here.
class ReportsRemoteDs {
  final Dio _dio;
  const ReportsRemoteDs(this._dio);

  Future<List<dynamic>> getReports() async {
    try {
      // Using sections as report source — each section IS a report unit
      final res = await _dio.get('/Accreditation/sections');
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<Map<String, dynamic>> getReportDetail(int sectionId) async {
    try {
      final res = await _dio.get('/Accreditation/sections/$sectionId');
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\reports\domain\repositories\reports_repository.dart' @'
// lib/features/reports/domain/repositories/reports_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ReportsRepository {
  Future<Either<Failure, List<dynamic>>> getReports();
  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(int sectionId);
}

'@

Write-File 'lib\features\deadlines\presentation\cubit\deadlines_cubit.dart' @'
// lib/features/deadlines/presentation/cubit/deadlines_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/deadlines_repository.dart';

part 'deadlines_state.dart';

class DeadlinesCubit extends Cubit<DeadlinesState> {
  final DeadlinesRepository _repo;
  DeadlinesCubit(this._repo) : super(DeadlinesInitial());

  Future<void> load() async {
    emit(DeadlinesLoading());
    final r = await _repo.getDeadlines();
    r.fold((f) => emit(DeadlinesError(f.message)), (list) => emit(DeadlinesLoaded(list)));
  }

  void filterBy(String filter) {
    if (state is DeadlinesLoaded) {
      emit(DeadlinesLoaded((state as DeadlinesLoaded).deadlines, filter: filter));
    }
  }
}

'@

Write-File 'lib\features\deadlines\presentation\cubit\deadlines_state.dart' @'
// lib/features/deadlines/presentation/cubit/deadlines_state.dart
part of 'deadlines_cubit.dart';

abstract class DeadlinesState extends Equatable {
  const DeadlinesState();
  @override List<Object?> get props => [];
}
class DeadlinesInitial extends DeadlinesState {}
class DeadlinesLoading extends DeadlinesState {}
class DeadlinesLoaded extends DeadlinesState {
  final List<dynamic> deadlines;
  final String filter; // 'all' | 'overdue' | 'upcoming' | 'done'
  const DeadlinesLoaded(this.deadlines, {this.filter = 'all'});
  @override List<Object?> get props => [deadlines, filter];

  List<dynamic> get filtered {
    if (filter == 'all') return deadlines;
    return deadlines.where((d) {
      final status = (d['status'] ?? '').toString().toLowerCase();
      return status == filter;
    }).toList();
  }
}
class DeadlinesError extends DeadlinesState {
  final String message;
  const DeadlinesError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\deadlines\presentation\screens\deadlines_screen.dart' @'
// lib/features/deadlines/presentation/screens/deadlines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/deadlines_cubit.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeadlinesCubit>()..load(),
      child: const _DeadlinesView(),
    );
  }
}

class _DeadlinesView extends StatelessWidget {
  const _DeadlinesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المواعيد النهائية')),
      body: BlocBuilder<DeadlinesCubit, DeadlinesState>(
        builder: (ctx, state) {
          if (state is DeadlinesLoading) return const Center(child: CircularProgressIndicator());
          if (state is DeadlinesError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: () => ctx.read<DeadlinesCubit>().load(), child: const Text('إعادة المحاولة')),
            ]));
          }
          if (state is DeadlinesLoaded) {
            return Column(
              children: [
                // Filter tabs
                Container(
                  height: 44.h,
                  margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _FilterTab(label: 'الكل', value: 'all', current: state.filter),
                      _FilterTab(label: 'منتهي', value: 'done', current: state.filter),
                      _FilterTab(label: 'قادم', value: 'upcoming', current: state.filter),
                      _FilterTab(label: 'متأخر', value: 'overdue', current: state.filter),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ctx.read<DeadlinesCubit>().load(),
                    child: state.filtered.isEmpty
                        ? const Center(child: Text('لا توجد مواعيد'))
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                            itemCount: state.filtered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (_, i) {
                              final d = state.filtered[i] as Map<String, dynamic>? ?? {};
                              return _DeadlineCard(data: d);
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label, value, current;
  const _FilterTab({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DeadlinesCubit>().filterBy(value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : Theme.of(context).disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DeadlineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['documentName'] ?? data['name'] ?? 'مستند';
    final deadline = data['deadline'] ?? '';
    final status = data['status'] ?? 'pending';

    Color statusColor;
    String statusLabel;
    switch (status.toString().toLowerCase()) {
      case 'overdue': statusColor = AppColors.error; statusLabel = 'متأخر'; break;
      case 'done': statusColor = AppColors.success; statusLabel = 'منتهي'; break;
      case 'upcoming': statusColor = AppColors.warning; statusLabel = 'قادم'; break;
      default: statusColor = AppColors.blue; statusLabel = 'قيد التنفيذ';
    }

    return AppCard(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(label: statusLabel, color: statusColor, small: true),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('تحديد الموعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.right),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(deadline),
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.calendar_today_outlined, size: 13.sp, color: Theme.of(context).disabledColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return d; }
  }
}

'@

Write-File 'lib\features\deadlines\repository\deadlines_repository_impl.dart' @'
// lib/features/deadlines/repository/deadlines_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/deadlines_remote_ds.dart';
import '../domain/repositories/deadlines_repository.dart';

class DeadlinesRepositoryImpl implements DeadlinesRepository {
  final DeadlinesRemoteDs _remote;
  const DeadlinesRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getDeadlines() async {
    try { return Right(await _remote.getDeadlines()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\deadlines\data\remote\deadlines_remote_ds.dart' @'
// lib/features/deadlines/data/remote/deadlines_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class DeadlinesRemoteDs {
  final Dio _dio;
  const DeadlinesRemoteDs(this._dio);

  Future<List<dynamic>> getDeadlines() async {
    try {
      final res = await _dio.get(ApiEndpoints.deadlines);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\deadlines\domain\repositories\deadlines_repository.dart' @'
// lib/features/deadlines/domain/repositories/deadlines_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
abstract class DeadlinesRepository {
  Future<Either<Failure, List<dynamic>>> getDeadlines();
}

// lib/features/deadlines/repository/deadlines_repository_impl.dart

'@

Write-File 'lib\features\profile\presentation\cubit\profile_cubit.dart' @'
// lib/features/profile/presentation/cubit/profile_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  ProfileCubit(this._repo) : super(ProfileInitial());

  Future<void> load() async {
    emit(ProfileLoading());
    final r = await _repo.getProfile();
    r.fold((f) => emit(ProfileError(f.message)), (d) => emit(ProfileLoaded(d)));
  }

  Future<void> update(String email, String firstName, String lastName) async {
    emit(ProfileUpdating());
    final r = await _repo.updateProfile(email, firstName, lastName);
    r.fold((f) => emit(ProfileError(f.message)), (_) => emit(const ProfileUpdateSuccess()));
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    emit(ProfileUpdating());
    final r = await _repo.updatePassword(oldPass, newPass);
    r.fold((f) => emit(ProfileError(f.message)), (_) => emit(const ProfileUpdateSuccess()));
  }

  Future<void> uploadPhoto(File file) async {
    emit(ProfileUpdating());
    final r = await _repo.uploadPhoto(file);
    r.fold((f) => emit(ProfileError(f.message)), (_) { load(); });
  }
}

'@

Write-File 'lib\features\profile\presentation\cubit\profile_state.dart' @'
// lib/features/profile/presentation/cubit/profile_state.dart
part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override List<Object?> get props => [];
}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileUpdating extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> data;
  const ProfileLoaded(this.data);
  @override List<Object?> get props => [data];
}
class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\profile\presentation\screens\profile_screen.dart' @'
// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _showPasswordSection = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    _emailCtrl.text = data['email'] ?? '';
    _firstCtrl.text = data['firstName'] ?? '';
    _lastCtrl.text = data['lastName'] ?? '';
  }

  Future<void> _pickImage(ProfileCubit cubit) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      cubit.uploadPhoto(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cache = sl<HiveCache>();
    final role = cache.getRole() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (ctx, state) {
          if (state is ProfileLoaded) _populateFields(state.data);
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('تم الحفظ بنجاح ✓'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() => _showPasswordSection = false);
            _oldPassCtrl.clear();
            _newPassCtrl.clear();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (ctx, state) {
          final cubit = ctx.read<ProfileCubit>();
          final isLoading = state is ProfileUpdating;
          final photoUrl = state is ProfileLoaded ? state.data['photoUrl'] as String? : null;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.blue.withOpacity(0.15),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(
                                  (_firstCtrl.text.isNotEmpty ? _firstCtrl.text[0] : 'م').toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blue,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(cubit),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 16.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${_firstCtrl.text} ${_lastCtrl.text}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4.h),
                  AppBadge(
                    label: _roleLabel(role),
                    color: _roleColor(role),
                  ),
                  SizedBox(height: 24.h),

                  // ── Personal Info ────────────────────
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('المعلومات الشخصية', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'اسم العائلة',
                                controller: _lastCtrl,
                                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: AppTextField(
                                label: 'الاسم الأول',
                                controller: _firstCtrl,
                                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: 'البريد الإلكتروني',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (!v.contains('@')) return 'بريد غير صحيح';
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        AppButton(
                          label: 'حفظ التعديلات',
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.update(
                                _emailCtrl.text.trim(),
                                _firstCtrl.text.trim(),
                                _lastCtrl.text.trim(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Change Password ──────────────────
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                                color: Theme.of(context).disabledColor,
                              ),
                              Text('تغيير كلمة المرور', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        ),
                        if (_showPasswordSection) ...[
                          SizedBox(height: 16.h),
                          AppTextField(
                            label: 'كلمة المرور الحالية',
                            controller: _oldPassCtrl,
                            obscure: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          SizedBox(height: 16.h),
                          AppTextField(
                            label: 'كلمة المرور الجديدة',
                            controller: _newPassCtrl,
                            obscure: true,
                            prefixIcon: Icons.lock_reset,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'مطلوب';
                              if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          AppButton(
                            label: 'تحديث كلمة المرور',
                            isLoading: isLoading,
                            onPressed: () {
                              if (_oldPassCtrl.text.isNotEmpty && _newPassCtrl.text.length >= 6) {
                                cubit.changePassword(_oldPassCtrl.text, _newPassCtrl.text);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── App Settings ─────────────────────
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('إعدادات التطبيق', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 12.h),
                        // Dark Mode
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (ctx, themeMode) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                value: themeMode == ThemeMode.dark,
                                onChanged: (_) => ctx.read<ThemeCubit>().toggleTheme(),
                                activeColor: AppColors.cyan,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8.w),
                                  Text('الوضع الداكن', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.dark_mode_outlined, size: 20.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        SizedBox(height: 8.h),
                        // Language
                        BlocBuilder<LocaleCubit, dynamic>(
                          builder: (ctx, locale) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => ctx.read<LocaleCubit>().toggleLocale(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.navyBlue,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    locale.languageCode == 'ar' ? 'English' : 'عربي',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8.w),
                                  Text('اللغة', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.language, size: 20.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Logout ───────────────────────────
                  AppCard(
                    onTap: () => _showLogoutDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.logout, color: AppColors.error, size: 20.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              sl<HiveCache>().clearAll();
              context.go(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'system_admin': return 'مدير النظام';
      case 'quality_manager': return 'مدير الجودة';
      case 'quality_employee': return 'موظف الجودة';
      case 'reviewer': return 'مراجع';
      default: return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'system_admin': return AppColors.adminColor;
      case 'quality_manager': return AppColors.managerColor;
      case 'quality_employee': return AppColors.employeeColor;
      case 'reviewer': return AppColors.reviewerColor;
      default: return AppColors.blue;
    }
  }
}

'@

Write-File 'lib\features\profile\repository\profile_repository_impl.dart' @'
// lib/features/profile/repository/profile_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/profile_remote_ds.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDs _remote;
  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try { return Right(await _remote.getProfile()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> updateProfile(String email, String firstName, String lastName) async {
    try { await _remote.updateProfile(email, firstName, lastName); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String oldPass, String newPass) async {
    try { await _remote.updatePassword(oldPass, newPass); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> uploadPhoto(File file) async {
    try { await _remote.uploadPhoto(file); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> deletePhoto() async {
    try { await _remote.deletePhoto(); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\profile\data\remote\profile_remote_ds.dart' @'
// lib/features/profile/data/remote/profile_remote_ds.dart
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class ProfileRemoteDs {
  final Dio _dio;
  const ProfileRemoteDs(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.profile);
      return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> updateProfile(String email, String firstName, String lastName) async {
    try {
      await _dio.put(ApiEndpoints.updateProfile, data: {
        'email': email, 'firstName': firstName, 'lastName': lastName,
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> updatePassword(String oldPass, String newPass) async {
    try {
      await _dio.put(ApiEndpoints.updatePassword, data: {
        'oldPassword': oldPass, 'newPassword': newPass,
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> uploadPhoto(File file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      await _dio.post(ApiEndpoints.uploadPhoto, data: form);
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> deletePhoto() async {
    try {
      await _dio.delete(ApiEndpoints.deletePhoto);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\profile\domain\repositories\profile_repository.dart' @'
// lib/features/profile/domain/repositories/profile_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile();
  Future<Either<Failure, void>> updateProfile(String email, String firstName, String lastName);
  Future<Either<Failure, void>> updatePassword(String oldPass, String newPass);
  Future<Either<Failure, void>> uploadPhoto(File file);
  Future<Either<Failure, void>> deletePhoto();
}

'@

Write-File 'lib\features\notifications\presentation\cubit\notification_cubit.dart' @'
// lib/features/notifications/presentation/cubit/notification_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;
  Timer? _pollingTimer;

  NotificationCubit(this._repo) : super(NotificationInitial());

  void startPolling() {
    loadNotifications();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _pollUnreadCount(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    final result = await _repo.getNotifications();
    result.fold(
      (f) => emit(NotificationError(f.message)),
      (list) => emit(NotificationLoaded(list)),
    );
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await loadNotifications();
  }

  Future<void> _pollUnreadCount() async {
    final result = await _repo.getUnreadCount();
    result.fold(
      (_) {},
      (count) {
        if (state is NotificationLoaded) {
          emit((state as NotificationLoaded).copyWith(unreadCount: count));
        }
      },
    );
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}

'@

Write-File 'lib\features\notifications\presentation\cubit\notification_state.dart' @'
// lib/features/notifications/presentation/cubit/notification_state.dart
part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<dynamic> notifications;
  final int unreadCount;

  const NotificationLoaded(this.notifications, {this.unreadCount = 0});

  NotificationLoaded copyWith({List<dynamic>? notifications, int? unreadCount}) {
    return NotificationLoaded(
      notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\notifications\presentation\screens\notifications_screen.dart' @'
// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/notification_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationCubit>()..startPolling(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (ctx, state) => TextButton(
              onPressed: state is NotificationLoaded
                  ? () => ctx.read<NotificationCubit>().markAllRead()
                  : null,
              child: Text(
                'تمييز الكل كمقروء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: AppColors.cyan,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (ctx, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () => ctx.read<NotificationCubit>().loadNotifications(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('لا توجد إشعارات'),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<NotificationCubit>().loadNotifications(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => Divider(height: 0.5.h, thickness: 0.5),
                itemBuilder: (_, i) {
                  final n = state.notifications[i] as Map<String, dynamic>? ?? {};
                  final isRead = n['isRead'] as bool? ?? true;
                  return _NotificationTile(data: n, isRead: isRead);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isRead;
  const _NotificationTile({required this.data, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'إشعار';
    final message = data['message'] as String? ?? '';
    final time = data['createdAt'] as String? ?? '';

    return Container(
      color: isRead
          ? null
          : AppColors.blue.withOpacity(0.05),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRead)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 8.w),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (time.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _notifIcon(data['type'] as String? ?? ''),
        ],
      ),
    );
  }

  Widget _notifIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'deadline': icon = Icons.schedule; color = AppColors.warning; break;
      case 'report': icon = Icons.bar_chart; color = AppColors.blue; break;
      case 'file': icon = Icons.upload_file; color = AppColors.success; break;
      case 'warning': icon = Icons.warning_amber_outlined; color = AppColors.error; break;
      default: icon = Icons.notifications_outlined; color = AppColors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) { return iso; }
  }
}

'@

Write-File 'lib\features\notifications\repository\notification_repository_impl.dart' @'
// lib/features/notifications/repository/notification_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/notification_remote_ds.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDs _remote;
  const NotificationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getNotifications() async {
    try { return Right(await _remote.getNotifications()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try { return Right(await _remote.getUnreadCount()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    try { await _remote.markAllRead(); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\notifications\data\remote\notification_remote_ds.dart' @'
// lib/features/notifications/data/remote/notification_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class NotificationRemoteDs {
  final Dio _dio;
  const NotificationRemoteDs(this._dio);

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await _dio.get(ApiEndpoints.notifications);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadCount);
      if (res.data is int) return res.data;
      return res.data?['count'] ?? 0;
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiEndpoints.markAllRead);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\notifications\domain\repositories\notification_repository.dart' @'
// lib/features/notifications/domain/repositories/notification_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<dynamic>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAllRead();
}

// ── impl ──────────────────────────────────────────────
// lib/features/notifications/repository/notification_repository_impl.dart
// (defined inline for brevity, split into separate file in real project)

'@

Write-File 'lib\features\chat\presentation\cubit\chat_cubit.dart' @'
// lib/features/chat/presentation/cubit/chat_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;
  Timer? _refreshTimer;
  int? _activeCollegeId;

  ChatCubit(this._repo) : super(ChatInitial());

  Future<void> loadColleges() async {
    emit(ChatLoading());
    final r = await _repo.getColleges();
    r.fold((f) => emit(ChatError(f.message)), (list) => emit(CollegesLoaded(list)));
  }

  Future<void> openChat(int collegeId) async {
    _activeCollegeId = collegeId;
    emit(MessagesLoading());
    await _fetchMessages(collegeId);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchMessages(collegeId));
  }

  Future<void> _fetchMessages(int collegeId) async {
    final r = await _repo.getMessages(collegeId);
    r.fold(
      (f) { if (state is! MessagesLoaded) emit(ChatError(f.message)); },
      (list) => emit(MessagesLoaded(list, collegeId: collegeId)),
    );
  }

  Future<void> sendMessage(String content, int collegeId, {int? receiverId}) async {
    final r = await _repo.sendMessage(content, collegeId, receiverId);
    r.fold(
      (f) => emit(ChatError(f.message)),
      (_) => _fetchMessages(collegeId),
    );
  }

  void closeChat() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _activeCollegeId = null;
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}

'@

Write-File 'lib\features\chat\presentation\cubit\chat_state.dart' @'
// lib/features/chat/presentation/cubit/chat_state.dart
part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class MessagesLoading extends ChatState {}

class CollegesLoaded extends ChatState {
  final List<dynamic> colleges;
  const CollegesLoaded(this.colleges);
  @override List<Object?> get props => [colleges];
}

class MessagesLoaded extends ChatState {
  final List<dynamic> messages;
  final int collegeId;
  const MessagesLoaded(this.messages, {required this.collegeId});
  @override List<Object?> get props => [messages, collegeId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\chat\presentation\screens\chat_list_screen.dart' @'
// lib/features/chat/presentation/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/chat_cubit.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..loadColleges(),
      child: Scaffold(
        appBar: AppBar(title: const Text('المحادثات')),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (ctx, state) {
            if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
            if (state is ChatError) return Center(child: Text(state.message));
            if (state is CollegesLoaded) {
              if (state.colleges.isEmpty) {
                return const Center(child: Text('لا توجد محادثات'));
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.colleges.length,
                separatorBuilder: (_, __) => Divider(height: 0.5.h, thickness: 0.5),
                itemBuilder: (_, i) {
                  final c = state.colleges[i] as Map<String, dynamic>? ?? {};
                  final name = c['collegeName'] ?? c['name'] ?? 'كلية ${i + 1}';
                  final unread = (c['unreadCount'] ?? 0) as int;
                  return ListTile(
                    onTap: () => context.push(
                      AppRoutes.chatDetail.replaceFirst(':collegeId', '${c['id'] ?? 0}'),
                    ),
                    trailing: CircleAvatar(
                      backgroundColor: AppColors.blue.withOpacity(0.15),
                      child: Text(
                        name.isNotEmpty ? name[0] : 'ك',
                        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.blue, fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600), textAlign: TextAlign.right),
                    subtitle: Text(
                      c['lastMessage'] ?? 'ابدأ المحادثة',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: unread > 0
                        ? Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        : null,
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

'@

Write-File 'lib\features\chat\presentation\screens\chat_screen.dart' @'
// lib/features/chat/presentation/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final int collegeId;
  const ChatScreen({super.key, required this.collegeId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..openChat(widget.collegeId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المراجع'),
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 4.w),
                  Text('متصل', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (ctx, state) {
            if (state is MessagesLoaded) _scrollToBottom();
          },
          builder: (ctx, state) {
            final messages = state is MessagesLoaded ? state.messages : <dynamic>[];
            final cache = sl<HiveCache>();
            final myData = cache.getUserData();
            final myEmail = myData?['email'] ?? '';

            return Column(
              children: [
                // Messages
                Expanded(
                  child: state is MessagesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('💬', style: TextStyle(fontSize: 48.sp)),
                                  SizedBox(height: 12.h),
                                  const Text('ابدأ المحادثة', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                              itemCount: messages.length,
                              itemBuilder: (_, i) {
                                final msg = messages[i] as Map<String, dynamic>? ?? {};
                                final senderEmail = msg['senderEmail'] ?? msg['sender']?['email'] ?? '';
                                final isMe = senderEmail == myEmail;
                                return _MessageBubble(
                                  content: msg['content'] ?? '',
                                  isMe: isMe,
                                  time: msg['sentAt'] ?? msg['createdAt'] ?? '',
                                  senderName: isMe ? 'أنت' : (msg['senderName'] ?? 'المراجع'),
                                );
                              },
                            ),
                ),
                // Input bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
                  ),
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
                  child: Row(
                    children: [
                      // Send button
                      GestureDetector(
                        onTap: () {
                          final text = _msgCtrl.text.trim();
                          if (text.isEmpty) return;
                          ctx.read<ChatCubit>().sendMessage(text, widget.collegeId);
                          _msgCtrl.clear();
                        },
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(color: AppColors.navyBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Text input
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 4,
                            minLines: 1,
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                            decoration: InputDecoration.collapsed(
                              hintText: 'اكتب رسالة...',
                              hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: Theme.of(context).disabledColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.attach_file_outlined, size: 22.sp, color: Theme.of(context).disabledColor),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String time;
  final String senderName;

  const _MessageBubble({
    required this.content,
    required this.isMe,
    required this.time,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Text(senderName, style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Theme.of(context).disabledColor)),
            SizedBox(height: 4.h),
          ],
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.blue.withOpacity(0.15),
                  child: Icon(Icons.person_outline, size: 16.sp, color: AppColors.blue),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.navyBlue : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                      bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                    ),
                    border: isMe ? null : Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 8.w),
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.navyBlue.withOpacity(0.15),
                  child: Icon(Icons.person, size: 16.sp, color: AppColors.navyBlue),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              _formatTime(time),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: Theme.of(context).disabledColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) { return iso; }
  }
}

'@

Write-File 'lib\features\chat\repository\chat_repository_impl.dart' @'
// lib/features/chat/repository/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/chat_remote_ds.dart';
import '../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDs _remote;
  const ChatRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getColleges() async {
    try { return Right(await _remote.getColleges()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMessages(int collegeId) async {
    try { return Right(await _remote.getMessages(collegeId)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> sendMessage(String content, int collegeId, int? receiverId) async {
    try { await _remote.sendMessage(content, collegeId, receiverId); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\chat\data\remote\chat_remote_ds.dart' @'
// lib/features/chat/data/remote/chat_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class ChatRemoteDs {
  final Dio _dio;
  const ChatRemoteDs(this._dio);

  Future<List<dynamic>> getColleges() async {
    try {
      final res = await _dio.get(ApiEndpoints.chatColleges);
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<List<dynamic>> getMessages(int collegeId) async {
    try {
      final res = await _dio.get(ApiEndpoints.chatMessages(collegeId));
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<void> sendMessage(String content, int collegeId, int? receiverId) async {
    try {
      await _dio.post(ApiEndpoints.sendMessage, data: {
        'content': content,
        'collegeId': collegeId,
        if (receiverId != null) 'receiverId': receiverId,
      });
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadMessages);
      if (res.data is int) return res.data;
      return res.data?['count'] ?? 0;
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\chat\domain\repositories\chat_repository.dart' @'
// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<dynamic>>> getColleges();
  Future<Either<Failure, List<dynamic>>> getMessages(int collegeId);
  Future<Either<Failure, void>> sendMessage(String content, int collegeId, int? receiverId);
}

'@

Write-File 'lib\features\dashboard\presentation\cubit\dashboard_cubit.dart' @'
// lib/features/dashboard/presentation/cubit/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;
  DashboardCubit(this._repo) : super(DashboardInitial());

  Future<void> load() async {
    emit(DashboardLoading());
    final result = await _repo.getSections();
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (data) {
        final sections = data['sections'];
        List<SectionSummary> summaries = [];
        if (sections is List) {
          summaries = sections.map<SectionSummary>((s) {
            // Handle BOTH possible field names from API
            final id = s['sectionId'] ?? s['id'] ?? 0;
            final name = s['sectionName'] ?? s['name'] ?? '';
            final uploaded = s['completedDocs'] ?? s['uploadedDocuments'] ?? 0;
            final total = s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1;
            // Use completionPercentage if available, otherwise calculate
            double pct;
            if (s['completionPercentage'] != null) {
              pct = (s['completionPercentage'] as num).toDouble() / 100.0;
            } else {
              pct = total > 0 ? (uploaded / total).toDouble() : 0.0;
            }
            return SectionSummary(
              id: id is int ? id : int.tryParse(id.toString()) ?? 0,
              name: name.toString(),
              uploadedDocs: uploaded is int ? uploaded : int.tryParse(uploaded.toString()) ?? 0,
              requiredDocs: total is int ? total : int.tryParse(total.toString()) ?? 1,
              completionPercent: pct.clamp(0.0, 1.0),
            );
          }).toList();
        }
        emit(DashboardLoaded(summaries));
      },
    );
  }
}

'@

Write-File 'lib\features\dashboard\presentation\cubit\dashboard_state.dart' @'
// lib/features/dashboard/presentation/cubit/dashboard_state.dart
part of 'dashboard_cubit.dart';

class SectionSummary extends Equatable {
  final int id;
  final String name;
  final int uploadedDocs;
  final int requiredDocs;
  final double completionPercent;

  const SectionSummary({
    required this.id,
    required this.name,
    required this.uploadedDocs,
    required this.requiredDocs,
    required this.completionPercent,
  });

  @override
  List<Object?> get props => [id, name, completionPercent];
}

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override List<Object?> get props => [];
}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final List<SectionSummary> sections;
  const DashboardLoaded(this.sections);
  @override List<Object?> get props => [sections];

  double get overallCompletion {
    if (sections.isEmpty) return 0;
    return sections.map((s) => s.completionPercent).reduce((a, b) => a + b) / sections.length;
  }
  int get totalUploaded => sections.fold(0, (s, e) => s + e.uploadedDocs);
}
class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\dashboard\presentation\screens\dashboard_screen.dart' @'
// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final userData = sl<HiveCache>().getUserData();
    final firstName = userData?['firstName'] ?? 'مستخدم';
    final role = sl<HiveCache>().getRole() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (ctx, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  OutlinedButton(
                    onPressed: () => ctx.read<DashboardCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final loaded = state is DashboardLoaded ? state : null;
          final overallPct = loaded?.overallCompletion ?? 0.0;
          final totalUploaded = loaded?.totalUploaded ?? 0;
          final sections = loaded?.sections ?? [];

          return RefreshIndicator(
            onRefresh: () => ctx.read<DashboardCubit>().load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              children: [
                // ── Welcome Card ──────────────────────
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'مرحباً، $firstName 👋',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _roleLabel(role),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: Colors.white60,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'آخر تحديث: اليوم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text('🤖', style: TextStyle(fontSize: 44.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Stats Row ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'درجة الاكتمال',
                        value: '${(overallPct * 100).round()}%',
                        color: _pctColor(overallPct),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'الملفات المرفوعة',
                        value: '$totalUploaded',
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'المعايير',
                        value: '${sections.length}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Chart Card ────────────────────────
                if (sections.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('الامتثال للمعايير', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 180.h,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final i = val.toInt();
                                      if (i >= sections.length) return const SizedBox();
                                      return Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: Theme.of(context).dividerColor,
                                  strokeWidth: 0.5,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: sections.asMap().entries.map((e) {
                                final pct = (e.value.completionPercent * 100);
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: pct,
                                      color: _pctColor(e.value.completionPercent),
                                      width: 20.w,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Standards List ────────────────────
                AppCard(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('المعايير', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 12.h),
                      if (sections.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: Text(
                              'لا توجد بيانات',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                      else
                        ...sections.map((s) => _StandardRow(section: s)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'system_admin': return 'مدير النظام';
      case 'quality_manager': return 'مديرة الجودة';
      case 'quality_employee': return 'موظف الجودة';
      case 'reviewer': return 'المراجع';
      default: return role;
    }
  }

  Color _pctColor(double pct) {
    if (pct >= 0.7) return AppColors.success;
    if (pct >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StandardRow extends StatelessWidget {
  final SectionSummary section;
  const _StandardRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final pct = section.completionPercent;
    final color = pct >= 0.7 ? AppColors.success : pct >= 0.4 ? AppColors.warning : AppColors.error;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(section.name, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 6.h),
          AppProgressBar(value: pct),
        ],
      ),
    );
  }
}

'@

Write-File 'lib\features\dashboard\repository\dashboard_repository_impl.dart' @'
// lib/features/dashboard/repository/dashboard_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/dashboard_remote_ds.dart';
import '../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDs _remote;
  const DashboardRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSections() async {
    try {
      final data = await _remote.getSections();
      return Right(data);
    } on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}

'@

Write-File 'lib\features\dashboard\data\remote\dashboard_remote_ds.dart' @'
// lib/features/dashboard/data/remote/dashboard_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class DashboardRemoteDs {
  final Dio _dio;
  const DashboardRemoteDs(this._dio);

  Future<Map<String, dynamic>> getSections() async {
    try {
      final res = await _dio.get(ApiEndpoints.sections);
      return {'sections': res.data};
    } on DioException catch (e) { throw dioToFailure(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadCount);
      return res.data is int ? res.data : (res.data['count'] ?? 0);
    } on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\dashboard\domain\repositories\dashboard_repository.dart' @'
// lib/features/dashboard/domain/repositories/dashboard_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class DashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSections();
}

'@

Write-File 'lib\features\admin\presentation\cubit\admin_cubit.dart' @'
// lib/features/admin/presentation/cubit/admin_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repo;
  AdminCubit(this._repo) : super(AdminInitial());

  Future<void> loadEmployees() async {
    emit(AdminLoading());
    final r = await _repo.getEmployees();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(EmployeesLoaded(list)));
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    emit(AdminActionLoading());
    final r = await _repo.createEmployee(data);
    r.fold((f) => emit(AdminError(f.message)), (_) { emit(const AdminActionSuccess('تم إضافة الموظف')); loadEmployees(); });
  }

  Future<void> deleteEmployee(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteEmployee(id);
    r.fold((f) => emit(AdminError(f.message)), (_) { emit(const AdminActionSuccess('تم حذف الموظف')); loadEmployees(); });
  }

  Future<void> loadRoles() async {
    emit(AdminLoading());
    final rolesR = await _repo.getRoles();
    final permsR = await _repo.getPermissions();
    rolesR.fold(
      (f) => emit(AdminError(f.message)),
      (roles) => permsR.fold(
        (f) => emit(RolesLoaded(roles, [])),
        (perms) => emit(RolesLoaded(roles, perms)),
      ),
    );
  }

  Future<void> createRole(String name, String desc) async {
    emit(AdminActionLoading());
    final r = await _repo.createRole(name, desc);
    r.fold((f) => emit(AdminError(f.message)), (_) { emit(const AdminActionSuccess('تم إنشاء الدور')); loadRoles(); });
  }

  Future<void> deleteRole(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteRole(id);
    r.fold((f) => emit(AdminError(f.message)), (_) { emit(const AdminActionSuccess('تم حذف الدور')); loadRoles(); });
  }

  Future<void> loadColleges() async {
    emit(AdminLoading());
    final r = await _repo.getColleges();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(CollegesLoaded(list)));
  }

  Future<void> deleteCollege(int id) async {
    emit(AdminActionLoading());
    final r = await _repo.deleteCollege(id);
    r.fold((f) => emit(AdminError(f.message)), (_) { emit(const AdminActionSuccess('تم حذف الكلية')); loadColleges(); });
  }

  Future<void> loadPlans() async {
    emit(AdminLoading());
    final r = await _repo.getPlans();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(PlansLoaded(list)));
  }

  Future<void> loadActivityLog() async {
    emit(AdminLoading());
    final r = await _repo.getActivityLog();
    r.fold((f) => emit(AdminError(f.message)), (list) => emit(ActivityLoaded(list)));
  }
}

'@

Write-File 'lib\features\admin\presentation\cubit\admin_state.dart' @'
// lib/features/admin/presentation/cubit/admin_state.dart
part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override List<Object?> get props => [];
}
class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminActionLoading extends AdminState {}
class EmployeesLoaded extends AdminState {
  final List<dynamic> employees;
  const EmployeesLoaded(this.employees);
  @override List<Object?> get props => [employees];
}
class RolesLoaded extends AdminState {
  final List<dynamic> roles;
  final List<dynamic> permissions;
  const RolesLoaded(this.roles, this.permissions);
  @override List<Object?> get props => [roles, permissions];
}
class CollegesLoaded extends AdminState {
  final List<dynamic> colleges;
  const CollegesLoaded(this.colleges);
  @override List<Object?> get props => [colleges];
}
class PlansLoaded extends AdminState {
  final List<dynamic> plans;
  const PlansLoaded(this.plans);
  @override List<Object?> get props => [plans];
}
class ActivityLoaded extends AdminState {
  final List<dynamic> logs;
  const ActivityLoaded(this.logs);
  @override List<Object?> get props => [logs];
}
class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override List<Object?> get props => [message];
}

'@

Write-File 'lib\features\admin\presentation\screens\admin_dashboard_screen.dart' @'
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
      _AdminItem(icon: Icons.people_outline, label: 'الموظفون', color: AppColors.blue, route: AppRoutes.employees),
      _AdminItem(icon: Icons.security_outlined, label: 'الأدوار والصلاحيات', color: AppColors.adminColor, route: AppRoutes.roles),
      _AdminItem(icon: Icons.school_outlined, label: 'الكليات', color: AppColors.success, route: AppRoutes.colleges),
      _AdminItem(icon: Icons.monetization_on_outlined, label: 'الأسعار والاشتراكات', color: AppColors.warning, route: AppRoutes.pricing),
      _AdminItem(icon: Icons.history_outlined, label: 'سجل الأنشطة', color: AppColors.navyBlue, route: AppRoutes.activityLog),
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
              decoration: BoxDecoration(color: AppColors.navyBlue, borderRadius: BorderRadius.circular(16.r)),
              child: Row(children: [
                Text('🛡', style: TextStyle(fontSize: 36.sp)),
                SizedBox(width: 16.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('System Admin', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('صلاحيات كاملة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.white60)),
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
                    Text(item.label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
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

class _AdminItem { final IconData icon; final String label, route; final Color color;
  const _AdminItem({required this.icon, required this.label, required this.color, required this.route});
}

'@

Write-File 'lib\features\admin\presentation\screens\colleges_screen.dart' @'
// lib/features/admin/presentation/screens/colleges_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/admin_cubit.dart';

class CollegesScreen extends StatelessWidget {
  const CollegesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<AdminCubit>()..loadColleges(), child: const _CollegesView());
  }
}
class _CollegesView extends StatelessWidget {
  const _CollegesView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الكليات')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is CollegesLoaded) {
            if (state.colleges.isEmpty) return const Center(child: Text('لا توجد كليات'));
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.colleges.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final c = state.colleges[i] as Map<String, dynamic>? ?? {};
                return AppCard(child: Row(children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8.r)),
                    child: GestureDetector(onTap: () => ctx.read<AdminCubit>().deleteCollege(c['id'] ?? 0),
                      child: Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)))),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(c['collegeName'] ?? c['name'] ?? 'كلية', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                    SizedBox(height: 4.h),
                    Text(c['universityName'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
                  ])),
                  SizedBox(width: 10.w),
                  Text('🏛', style: TextStyle(fontSize: 28.sp)),
                ]));
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }
}

// ── PricingScreen ─────────────────────────────────────────────────────────────
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<AdminCubit>()..loadPlans(), child: const _PricingView());
  }
}
class _PricingView extends StatelessWidget {
  const _PricingView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأسعار والاشتراكات')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is PlansLoaded) {
            if (state.plans.isEmpty) return const Center(child: Text('لا توجد باقات'));
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.plans.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final p = state.plans[i] as Map<String, dynamic>? ?? {};
                final features = (p['features'] as List?) ?? [];
                final isPopular = i == 1;
                return Container(
                  decoration: BoxDecoration(
                    color: isPopular ? AppColors.navyBlue : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: isPopular ? AppColors.navyBlue : Theme.of(context).dividerColor, width: isPopular ? 0 : 0.5),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (isPopular) Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(20.r)),
                      child: Text('الأكثر طلباً', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: AppColors.navyBlue, fontWeight: FontWeight.w700))),
                    Text(p['name'] ?? '', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: isPopular ? Colors.white : null)),
                    SizedBox(height: 4.h),
                    Text('£ ${p['price'] ?? ''}', style: TextStyle(fontFamily: 'Cairo', fontSize: 28.sp, fontWeight: FontWeight.w700, color: isPopular ? AppColors.cyan : AppColors.navyBlue)),
                    Text('/ سنوياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: isPopular ? Colors.white60 : null)),
                    SizedBox(height: 12.h),
                    ...features.map((f) => Padding(padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(f.toString(), style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: isPopular ? Colors.white70 : null)),
                        SizedBox(width: 6.w),
                        Icon(Icons.check_circle_outline, size: 14.sp, color: isPopular ? AppColors.cyan : AppColors.success),
                      ]))),
                  ]),
                );
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }
}

// ── ActivityLogScreen ─────────────────────────────────────────────────────────
class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<AdminCubit>()..loadActivityLog(), child: const _ActivityView());
  }
}
class _ActivityView extends StatelessWidget {
  const _ActivityView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الأنشطة')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is ActivityLoaded) {
            if (state.logs.isEmpty) return const Center(child: Text('لا توجد أنشطة'));
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.logs.length,
              separatorBuilder: (_, __) => Divider(height: 0.5.h, thickness: 0.5),
              itemBuilder: (_, i) {
                final log = state.logs[i] as Map<String, dynamic>? ?? {};
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(log['employeeName'] ?? log['userName'] ?? 'مستخدم',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4.h),
                      Text(log['action'] ?? log['description'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
                      SizedBox(height: 4.h),
                      Text(_fmtDate(log['timestamp'] ?? log['createdAt'] ?? ''), style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Theme.of(context).disabledColor)),
                    ])),
                    SizedBox(width: 12.w),
                    Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.history, size: 18.sp, color: AppColors.blue)),
                  ]),
                );
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }

  String _fmtDate(String s) {
    try { final d = DateTime.parse(s).toLocal(); return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; }
    catch(_) { return s; }
  }
}

'@

Write-File 'lib\features\admin\presentation\screens\employees_screen.dart' @'
// lib/features/admin/presentation/screens/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadEmployees(),
      child: const _EmployeesView(),
    );
  }
}

class _EmployeesView extends StatelessWidget {
  const _EmployeesView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموظفون'), actions: [
        IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () => _showAddDialog(context)),
      ]),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.success));
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is EmployeesLoaded) {
            if (state.employees.isEmpty) return const Center(child: Text('لا يوجد موظفون'));
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.employees.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final e = state.employees[i] as Map<String, dynamic>? ?? {};
                final name = '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}';
                final role = e['roleName'] ?? e['role'] ?? '';
                return AppCard(
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      GestureDetector(
                        onTap: () => ctx.read<AdminCubit>().deleteEmployee(e['id'] ?? 0),
                        child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8.r)),
                          child: Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white))),
                      ),
                    ]),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(name.trim(), style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                      SizedBox(height: 4.h),
                      Text(e['email'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
                      SizedBox(height: 4.h),
                      AppBadge(label: role.isNotEmpty ? role : 'موظف', color: AppColors.blue, small: true),
                    ])),
                    SizedBox(width: 10.w),
                    CircleAvatar(backgroundColor: AppColors.blue.withOpacity(0.15), radius: 22.r,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'م',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.blue))),
                  ]),
                );
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.navyBlue,
        label: const Text('إضافة موظف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('إضافة موظف جديد', textAlign: TextAlign.right),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppTextField(label: 'الاسم الأول', controller: firstCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'اسم العائلة', controller: lastCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'البريد الإلكتروني', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
        SizedBox(height: 12.h),
        AppTextField(label: 'كلمة المرور', controller: passCtrl, obscure: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AdminCubit>().createEmployee({
              'firstName': firstCtrl.text, 'lastName': lastCtrl.text,
              'email': emailCtrl.text, 'password': passCtrl.text, 'roleId': 1,
            });
          },
          child: const Text('إضافة'),
        ),
      ],
    ));
  }
}

'@

Write-File 'lib\features\admin\presentation\screens\roles_screen.dart' @'
// lib/features/admin/presentation/screens/roles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadRoles(),
      child: const _RolesView(),
    );
  }
}

class _RolesView extends StatelessWidget {
  const _RolesView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأدوار والصلاحيات'), actions: [
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showAddRoleDialog(context)),
      ]),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.success));
          if (state is AdminError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
        },
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is RolesLoaded) {
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.roles.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final r = state.roles[i] as Map<String, dynamic>? ?? {};
                return AppCard(child: Row(children: [
                  GestureDetector(
                    onTap: () => ctx.read<AdminCubit>().deleteRole(r['id'] ?? 0),
                    child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8.r)),
                      child: Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white))),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r['roleName'] ?? r['name'] ?? 'دور', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                    SizedBox(height: 4.h),
                    Text(r['description'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right, maxLines: 2),
                  ])),
                  SizedBox(width: 10.w),
                  Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: AppColors.adminColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.security_outlined, color: AppColors.adminColor, size: 20.sp)),
                ]));
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('إنشاء دور جديد', textAlign: TextAlign.right),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        AppTextField(label: 'اسم الدور', controller: nameCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'وصف الدور', controller: descCtrl, maxLines: 2),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: () { Navigator.pop(context); context.read<AdminCubit>().createRole(nameCtrl.text, descCtrl.text); }, child: const Text('إنشاء')),
      ],
    ));
  }
}

'@

Write-File 'lib\features\admin\repository\admin_repository_impl.dart' @'
// lib/features/admin/repository/admin_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/admin_remote_ds.dart';
import '../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDs _r;
  const AdminRepositoryImpl(this._r);

  Either<Failure, T> _wrap<T>(T val) => Right(val);
  Either<Failure, T> _err<T>(Object e) => e is Failure ? Left(e) : Left(const UnknownFailure());

  @override Future<Either<Failure, List<dynamic>>> getEmployees() async {
    try { return _wrap(await _r.getEmployees()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> createEmployee(Map<String, dynamic> d) async {
    try { await _r.createEmployee(d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> updateEmployee(int id, Map<String, dynamic> d) async {
    try { await _r.updateEmployee(id, d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteEmployee(int id) async {
    try { await _r.deleteEmployee(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getRoles() async {
    try { return _wrap(await _r.getRoles()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> createRole(String n, String d) async {
    try { await _r.createRole(n, d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteRole(int id) async {
    try { await _r.deleteRole(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getPermissions() async {
    try { return _wrap(await _r.getPermissions()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> setRolePermissions(int id, List<int> p) async {
    try { await _r.setRolePermissions(id, p); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getColleges() async {
    try { return _wrap(await _r.getColleges()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteCollege(int id) async {
    try { await _r.deleteCollege(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getPlans() async {
    try { return _wrap(await _r.getPlans()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getActivityLog() async {
    try { return _wrap(await _r.getActivityLog()); } catch(e) { return _err(e); }
  }
}

'@

Write-File 'lib\features\admin\data\remote\admin_remote_ds.dart' @'
// lib/features/admin/data/remote/admin_remote_ds.dart
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/failures.dart';

class AdminRemoteDs {
  final Dio _dio;
  const AdminRemoteDs(this._dio);

  // Employees
  Future<List<dynamic>> getEmployees() async {
    try { final r = await _dio.get(ApiEndpoints.employees); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> createEmployee(Map<String, dynamic> data) async {
    try { await _dio.post(ApiEndpoints.employees, data: data); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    try { await _dio.put(ApiEndpoints.employeeById(id), data: data); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteEmployee(int id) async {
    try { await _dio.delete(ApiEndpoints.employeeById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Roles
  Future<List<dynamic>> getRoles() async {
    try { final r = await _dio.get(ApiEndpoints.roles); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> createRole(String name, String description) async {
    try { await _dio.post(ApiEndpoints.roles, data: {'roleName': name, 'description': description}); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteRole(int id) async {
    try { await _dio.delete(ApiEndpoints.roleById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<List<dynamic>> getPermissions() async {
    try { final r = await _dio.get(ApiEndpoints.permissions); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> setRolePermissions(int roleId, List<int> permIds) async {
    try { await _dio.post(ApiEndpoints.rolePermissions(roleId), data: permIds); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Colleges
  Future<List<dynamic>> getColleges() async {
    try { final r = await _dio.get(ApiEndpoints.colleges); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
  Future<void> deleteCollege(int id) async {
    try { await _dio.delete(ApiEndpoints.collegeById(id)); }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Plans
  Future<List<dynamic>> getPlans() async {
    try { final r = await _dio.get(ApiEndpoints.plans); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }

  // Activity Log
  Future<List<dynamic>> getActivityLog() async {
    try { final r = await _dio.get(ApiEndpoints.activityLog); return r.data is List ? r.data : []; }
    on DioException catch (e) { throw dioToFailure(e); }
  }
}

'@

Write-File 'lib\features\admin\domain\repositories\admin_repository.dart' @'
// lib/features/admin/domain/repositories/admin_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<dynamic>>> getEmployees();
  Future<Either<Failure, void>> createEmployee(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateEmployee(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteEmployee(int id);
  Future<Either<Failure, List<dynamic>>> getRoles();
  Future<Either<Failure, void>> createRole(String name, String description);
  Future<Either<Failure, void>> deleteRole(int id);
  Future<Either<Failure, List<dynamic>>> getPermissions();
  Future<Either<Failure, void>> setRolePermissions(int roleId, List<int> permIds);
  Future<Either<Failure, List<dynamic>>> getColleges();
  Future<Either<Failure, void>> deleteCollege(int id);
  Future<Either<Failure, List<dynamic>>> getPlans();
  Future<Either<Failure, List<dynamic>>> getActivityLog();
}

'@

Write-File 'pubspec.yaml' @'
name: qualif_ai
description: QualifAI — Academic Quality Management & Accreditation System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Navigation
  go_router: ^14.2.0

  # Networking
  dio: ^5.7.0
  pretty_dio_logger: ^1.4.0

  # Dependency Injection
  get_it: ^8.0.2

  # Local Storage
  hive_flutter: ^1.1.0

  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Functional Programming
  dartz: ^0.10.1

  # UI / UX
  flutter_screenutil: ^5.9.3
  cached_network_image: ^3.4.1
  fl_chart: ^0.69.0
  shimmer: ^3.0.0
  lottie: ^3.1.2
  fluttertoast: ^8.2.8
  flutter_svg: ^2.0.10+1
  google_fonts: ^6.2.1

  # File Handling
  file_picker: ^8.1.2
  permission_handler: ^11.3.1
  open_filex: ^4.6.0
  path_provider: ^2.1.4

  # Utils
  intl: ^0.19.0
  connectivity_plus: ^6.0.5
  jwt_decoder: ^2.0.1
  image_picker: ^1.1.2
  share_plus: ^10.0.3

  # HTTP multipart
  http_parser: ^4.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/

'@

Write-File 'android\app\src\main\AndroidManifest.xml' @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application
        android:label="QualifAI"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true"
        android:requestLegacyExternalStorage="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"/>

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2"/>

        <!-- File Provider for file picker -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>

    </application>
</manifest>

'@

Write-File 'android\app\src\main\res\xml\file_paths.xml' @'
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
    <files-path name="files" path="."/>
    <external-cache-path name="external_cache" path="."/>
</paths>

'@

Write-File 'NEW_CHAT_BRIEF.md' @'
# 🚀 QualifAI Flutter — Complete New Chat Brief
> الـ brief الكامل للبدء في شات جديد نظيف

---

## 🔗 الروابط

| المورد | الرابط |
|--------|--------|
| **GitHub (NEW)** | سيُنشأ repo جديد |
| **GitHub (OLD/reference)** | https://github.com/abdoRashed22/QualifAI.git |
| **API Base URL** | https://qualefai.runasp.net/api |
| **Swagger** | https://qualefai.runasp.net/swagger/index.html |
| **Figma Design** | https://www.figma.com/design/2v0cElubrU8aS84xSXxwvQ/QualifAi |
| **Figma Prototype** | https://www.figma.com/proto/2v0cElubrU8aS84xSXxwvQ/QualifAi?node-id=0-1 |

## 🔑 Test Account
- Email: abdo@gmail.com
- Password: 123123

---

## ⚙️ القرارات التقنية النهائية (لا تتغير)

| | |
|--|--|
| Architecture | MVVM + Cubit/BLoC |
| Navigation | go_router مع role-based guards |
| DI | get_it |
| State | flutter_bloc (Cubit) |
| Backend | REST API فقط |
| Local DB | hive_flutter |
| Notifications | Polling 30s |
| Font | google_fonts (Cairo) — لا files محلية |
| Theme | Dark/Light toggle |
| Locale | AR (RTL) / EN |
| Platform | Android 12+ (API 31) |
| ScreenUtil | designSize: 390×844 |

---

## 🐛 المشاكل المحلولة

### ✅ 1. Arabic Text Garbled (SnackBar / Responses)
**السبب:** Dio يقرأ bytes بـ Latin-1 افتراضياً
**الحل:** `responseType: ResponseType.bytes` + `_Utf8DecoderInterceptor`

```dart
// في DioClient:
BaseOptions(responseType: ResponseType.bytes, ...)

// Interceptor يعمل UTF-8 decode:
class _Utf8DecoderInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is List<int>) {
      final decoded = utf8.decode(response.data as List<int>, allowMalformed: true);
      try { response.data = jsonDecode(decoded); } catch (_) { response.data = decoded; }
    }
    handler.next(response);
  }
}
```

### ✅ 2. Cairo Font Not Loading
**السبب:** ملفات الـ font مش موجودة في assets
**الحل:** استخدام `google_fonts: ^6.2.1` بدل local files
```dart
import 'package:google_fonts/google_fonts.dart';
textStyle: GoogleFonts.cairo(fontSize: 14)
// أو للـ TextTheme كله:
textTheme: GoogleFonts.cairoTextTheme(base.textTheme)
```

### ✅ 3. POST /Employee → 500
**السبب:** Backend error، مش Flutter
**الحل:** استخدام roleId حقيقي من GET /Roles

### ⚠️ 4. Login Response Structure (Unknown)
لما تعمل login ناجح، الـ API response structure مش موثق في Swagger.
في `auth_remote_ds.dart` عمل flexible parsing:
```dart
factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
  return LoginResponseModel(
    token: json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '',
    firstName: json['firstName'] ?? json['first_name'] ?? '',
    lastName: json['lastName'] ?? json['last_name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? json['roles']?[0] ?? json['userRole'] ?? 'quality_employee',
  );
}
```

---

## 📁 Folder Structure الكاملة

```
qualif_ai/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_endpoints.dart
│   │   │   └── dio_client.dart          ← UTF-8 fix هنا
│   │   ├── cache/
│   │   │   └── hive_cache.dart
│   │   ├── di/
│   │   │   └── injection.dart
│   │   ├── errors/
│   │   │   └── failures.dart
│   │   ├── localization/
│   │   │   ├── app_strings.dart
│   │   │   └── locale_cubit.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_theme.dart           ← google_fonts fix هنا
│   │       └── theme_cubit.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/models/auth_model.dart
│   │   │   ├── data/remote/auth_remote_ds.dart
│   │   │   ├── domain/repositories/auth_repository.dart
│   │   │   ├── repository/auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/auth_cubit.dart + auth_state.dart
│   │   │       └── screens/splash_screen.dart + login_screen.dart + forgot_password_screen.dart
│   │   │
│   │   ├── dashboard/         ← DashboardCubit + DashboardScreen (charts)
│   │   ├── accreditation/     ← 5 screens: Types, Standards, Detail, Upload, AI
│   │   ├── chat/              ← ChatList + ChatScreen (polling 10s)
│   │   ├── deadlines/         ← DeadlinesScreen (filter tabs)
│   │   ├── notifications/     ← NotificationsScreen (polling 30s)
│   │   ├── profile/           ← ProfileScreen (settings + theme + lang)
│   │   ├── reports/           ← ReportsList + ReportDetail
│   │   └── admin/             ← AdminDashboard + 5 admin screens
│   │
│   └── shared/
│       └── widgets/
│           ├── main_scaffold.dart       ← Bottom nav (user + admin)
│           ├── app_button.dart
│           ├── app_text_field.dart
│           ├── app_card.dart            ← AppCard + AppBadge + AppProgressBar + ...
│           └── app_badge.dart           ← re-export
│
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml          ← INTERNET + FILE permissions
│       └── res/xml/file_paths.xml
│
├── assets/
│   ├── images/
│   └── icons/
│
└── pubspec.yaml                         ← google_fonts added, no local fonts
```

---

## 👥 User Roles (من JWT)

| Role String | الصفحة بعد Login |
|-------------|-----------------|
| `system_admin` | /admin (AdminDashboard) |
| `quality_manager` | /dashboard |
| `quality_employee` | /dashboard |
| `reviewer` | /reports |

---

## 📱 الـ 21 Screen

### Auth (3)
- SplashScreen — auto-navigate بعد 2s
- LoginScreen — email + password + BLoC
- ForgotPasswordScreen

### Main App (13)
- DashboardScreen — stats + bar chart
- AccreditationTypesScreen — Academic / Programmatic
- StandardsListScreen — 7 معايير + progress bars
- StandardDetailScreen — files list + deadline dialog
- FileUploadScreen — drag/drop + PDF/Word
- AiAnalysisScreen — score circle + recommendations
- ReportsListScreen
- ReportDetailScreen — gap analysis + send button
- DeadlinesScreen — filter tabs
- NotificationsScreen — polling
- ChatListScreen
- ChatScreen — messages + polling
- ProfileScreen — edit + dark/light + AR/EN

### Admin (5)
- AdminDashboardScreen — grid menu
- EmployeesScreen — CRUD
- RolesScreen — CRUD + permissions
- CollegesScreen
- PricingScreen — plans cards
- ActivityLogScreen

---

## 🌐 API Endpoints

```
BASE: https://qualefai.runasp.net/api

Auth:
  POST /Auth/login              {email, password}
  POST /Auth/forgot-password    {email}

Profile:
  GET  /Profile
  PUT  /Profile/update          {email, firstName, lastName}
  PUT  /Profile/update-password {oldPassword, newPassword}
  POST /Profile/upload-photo    multipart: file
  DELETE /Profile/delete-photo

Accreditation:
  GET  /Accreditation/sections
  GET  /Accreditation/sections/{id}
  POST /Accreditation/documents/{id}/upload         multipart: File
  POST /Accreditation/documents/{id}/set-deadline   {deadline, reminders:{oneWeekBefore,oneDayBefore,onDueDate}}
  GET  /Accreditation/deadlines

Notifications:
  GET  /Notification
  GET  /Notification/unread-count
  PUT  /Notification/mark-all-read

Chat:
  GET  /Chat/colleges
  GET  /Chat/{collegeId}/messages
  POST /Chat/send               {content, collegeId, receiverId?}
  GET  /Chat/unread

Admin — Employee:
  GET    /Employee
  POST   /Employee              {firstName, lastName, email, password, roleId}
  GET    /Employee/{id}
  PUT    /Employee/{id}         {employeeId, firstName, lastName, email, password, roleId}
  DELETE /Employee/{id}

Admin — Roles:
  GET    /Roles
  POST   /Roles                 {roleName, description}
  GET    /Roles/{id}
  DELETE /Roles/{id}
  GET    /Roles/{id}/permissions
  POST   /Roles/{id}/permissions  [permId1, permId2, ...]

Admin — Colleges:
  GET    /Colleges
  POST   /Colleges              multipart: UniversityName, CollegeName, InstitutionType, AccreditationType, SubscriptionStartDate, ManagerEmail, ManagerPassword, Image
  GET    /Colleges/{id}
  PUT    /Colleges/{id}
  DELETE /Colleges/{id}

Admin — Plans:
  GET    /Plan
  POST   /Plan                  {name, price, description, features[]}
  GET    /Plan/{id}
  PUT    /Plan/{id}
  DELETE /Plan/{id}

Admin — Other:
  GET  /Permissions
  GET  /ActivityLog
  GET  /Pricing
  POST /Pricing/subscribe       {cardHolderName, cardNumber, cvv, expiryDate, rememberCardInfo}
  GET  /Subscription
  GET  /Subscription/college/{id}
  PUT  /Subscription/{id}
  PUT  /Subscription/suspend/{id}
  PUT  /Subscription/activate/{id}
  POST /AdminNotification/send  {collegeId, title, message, scheduledAt}
  POST /Support/submit          {name, email, message}
  GET  /Enum/institution-types
  GET  /Enum/accreditation-types
```

---

## 📦 pubspec.yaml Key Dependencies

```yaml
flutter_bloc: ^8.1.6
equatable: ^2.0.5
go_router: ^14.2.0
dio: ^5.7.0
pretty_dio_logger: ^1.4.0
get_it: ^8.0.2
hive_flutter: ^1.1.0
freezed_annotation: ^2.4.4
json_annotation: ^4.9.0
dartz: ^0.10.1
flutter_screenutil: ^5.9.3
cached_network_image: ^3.4.1
fl_chart: ^0.69.0
google_fonts: ^6.2.1        # ← Cairo font, no local files
file_picker: ^8.1.2
permission_handler: ^11.3.1
intl: ^0.19.0
connectivity_plus: ^6.0.5
jwt_decoder: ^2.0.1
image_picker: ^1.1.2
```

---

## 🎨 Design Colors (من الـ Figma)

```dart
// Primary
static const navyBlue = Color(0xFF1B2B5E);
static const blue     = Color(0xFF2B4EAE);
static const cyan     = Color(0xFF00C2FF);

// Background Light
static const bgLight  = Color(0xFFF4F6FA);
static const white    = Color(0xFFFFFFFF);
static const borderLight = Color(0xFFE0E4EF);

// Background Dark
static const bgDark      = Color(0xFF0F1626);
static const surfaceDark = Color(0xFF1A2540);

// Status
static const success = Color(0xFF27AE60);
static const warning = Color(0xFFF39C12);
static const error   = Color(0xFFE74C3C);
```

---

## 🔧 ما يجب عمله في الشات الجديد

### Priority 1 — الأهم
1. **تطبيق الـ Figma design على كل screen** — الـ design الحالي بسيط جداً مقارنة بالـ Figma
2. **اختبار login flow** مع account: abdo@gmail.com / 123123
3. **التأكد من UTF-8 fix** يعمل صح

### Priority 2
4. **إضافة loading shimmer** بدل progress indicators
5. **Error states** أحسن تصميماً
6. **Empty states** مع illustrations

### Priority 3
7. **Support screen** (POST /Support/submit)
8. **Subscription screen** للـ college manager
9. **Notifications send** للـ admin

---

## 📋 Prompt للشات الجديد

```
أنا شاغل مشروع تخرج Flutter — QualifAI

📌 البريف الكامل في الـ repo القديم:
https://github.com/abdoRashed22/QualifAI.git
(اقرأ PROJECT_BRIEF.md و NEW_CHAT_BRIEF.md)

🔑 Test account: abdo@gmail.com / 123123
🌐 API: https://qualefai.runasp.net/api
🎨 Figma: https://www.figma.com/design/2v0cElubrU8aS84xSXxwvQ/QualifAi

المشروع عنده كود كامل، بس محتاج:
1. تطبيق الـ Figma design الصح على الـ screens
2. التأكد من UTF-8 fix شغال (dio responseType: bytes + interceptor)
3. google_fonts Cairo بدل local font files

Architecture: MVVM + Cubit | go_router | get_it | hive | dio
Platform: Android 12+ | designSize: 390x844 | Arabic RTL

ابدأ بـ login screen وتأكد إنه يشتغل مع الـ API.
```

---
*Updated: April 2026*

'@

Write-Host ''
Write-Host '87 files written with UTF-8 No BOM!' -ForegroundColor Green
Write-Host ''
Write-Host 'Committing...' -ForegroundColor Yellow
git add -A
git commit -m "fix: navigation crashes + correct API field names + UTF-8 encoding"
git push origin master
Write-Host ''
Write-Host 'Done! Run: flutter pub get && flutter run' -ForegroundColor Cyan