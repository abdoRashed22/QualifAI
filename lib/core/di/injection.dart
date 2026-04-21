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
  // â”€â”€ Core â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final cache = HiveCache();
  await cache.init();
  sl.registerSingleton<HiveCache>(cache);

  sl.registerSingleton<DioClient>(DioClient(sl<HiveCache>()));

  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<HiveCache>()));
  sl.registerFactory<LocaleCubit>(() => LocaleCubit(sl<HiveCache>()));

  // â”€â”€ Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<AuthRemoteDs>(
    () => AuthRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDs>(), sl<HiveCache>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));

  // â”€â”€ Dashboard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<DashboardRemoteDs>(
    () => DashboardRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDs>()),
  );
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(sl<DashboardRepository>()),
  );

  // â”€â”€ Accreditation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<AccreditationRemoteDs>(
    () => AccreditationRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AccreditationRepository>(
    () => AccreditationRepositoryImpl(sl<AccreditationRemoteDs>()),
  );
  sl.registerFactory<AccreditationCubit>(
    () => AccreditationCubit(sl<AccreditationRepository>()),
  );

  // â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<NotificationRemoteDs>(
    () => NotificationRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDs>()),
  );
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(sl<NotificationRepository>()),
  );

  // â”€â”€ Deadlines â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<DeadlinesRemoteDs>(
    () => DeadlinesRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DeadlinesRepository>(
    () => DeadlinesRepositoryImpl(sl<DeadlinesRemoteDs>()),
  );
  sl.registerFactory<DeadlinesCubit>(
    () => DeadlinesCubit(sl<DeadlinesRepository>()),
  );

  // â”€â”€ Chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<ChatRemoteDs>(
    () => ChatRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<ChatRemoteDs>()),
  );
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl<ChatRepository>()));

  // â”€â”€ Reports â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<ReportsRemoteDs>(
    () => ReportsRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl<ReportsRemoteDs>()),
  );
  sl.registerFactory<ReportsCubit>(() => ReportsCubit(sl<ReportsRepository>()));

  // â”€â”€ Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<ProfileRemoteDs>(
    () => ProfileRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDs>()),
  );
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ProfileRepository>()));

  // â”€â”€ Admin â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  sl.registerLazySingleton<AdminRemoteDs>(
    () => AdminRemoteDs(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDs>()),
  );
  sl.registerFactory<AdminCubit>(() => AdminCubit(sl<AdminRepository>()));
}
