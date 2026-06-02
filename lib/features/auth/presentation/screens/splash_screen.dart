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

  late Animation<double> _rotation;

  bool _navigated = false; // prevent double navigation

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.bounceInOut)));

    _scale = Tween<double>(begin: 0.5, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _rotation = Tween<double>(begin: -0.5, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

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
      } else if (role == 'reviewer' || role == 'employee') {
        context.go(AppRoutes.reviewerDashboard);
      } else {
        context.go(AppRoutes.dashboard);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
                RotationTransition(
                  turns: _rotation,
                  child: Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.cyan.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5)
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/2 51.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                Text('QualifAI',
                    style: GoogleFonts.cairo(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1)),
                SizedBox(height: 8.h),
                Text(
                  'نظام الجودة والاعتماد الأكاديمي',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white60,
                  ),
                ),
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
