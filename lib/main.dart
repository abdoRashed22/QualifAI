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
