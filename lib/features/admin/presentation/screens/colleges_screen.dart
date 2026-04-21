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
      appBar: AppBar(title: const Text('Ø§Ù„ÙƒÙ„ÙŠØ§Øª')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is CollegesLoaded) {
            if (state.colleges.isEmpty) return const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ ÙƒÙ„ÙŠØ§Øª'));
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
                      child: Text('Ø­Ø°Ù', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)))),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(c['collegeName'] ?? c['name'] ?? 'ÙƒÙ„ÙŠØ©', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                    SizedBox(height: 4.h),
                    Text(c['universityName'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
                  ])),
                  SizedBox(width: 10.w),
                  Text('ðŸ›', style: TextStyle(fontSize: 28.sp)),
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

// â”€â”€ PricingScreen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      appBar: AppBar(title: const Text('Ø§Ù„Ø£Ø³Ø¹Ø§Ø± ÙˆØ§Ù„Ø§Ø´ØªØ±Ø§ÙƒØ§Øª')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is PlansLoaded) {
            if (state.plans.isEmpty) return const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨Ø§Ù‚Ø§Øª'));
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
                      child: Text('Ø§Ù„Ø£ÙƒØ«Ø± Ø·Ù„Ø¨Ø§Ù‹', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: AppColors.navyBlue, fontWeight: FontWeight.w700))),
                    Text(p['name'] ?? '', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: isPopular ? Colors.white : null)),
                    SizedBox(height: 4.h),
                    Text('Â£ ${p['price'] ?? ''}', style: TextStyle(fontFamily: 'Cairo', fontSize: 28.sp, fontWeight: FontWeight.w700, color: isPopular ? AppColors.cyan : AppColors.navyBlue)),
                    Text('/ Ø³Ù†ÙˆÙŠØ§Ù‹', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: isPopular ? Colors.white60 : null)),
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

// â”€â”€ ActivityLogScreen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      appBar: AppBar(title: const Text('Ø³Ø¬Ù„ Ø§Ù„Ø£Ù†Ø´Ø·Ø©')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is ActivityLoaded) {
            if (state.logs.isEmpty) return const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ø£Ù†Ø´Ø·Ø©'));
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
                      Text(log['employeeName'] ?? log['userName'] ?? 'Ù…Ø³ØªØ®Ø¯Ù…',
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
