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
                Text('Ù†Ø¸Ø§Ù… Ø§Ù„Ø¬ÙˆØ¯Ø© ÙˆØ§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯ Ø§Ù„Ø£ÙƒØ§Ø¯ÙŠÙ…ÙŠ', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white60)),
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
