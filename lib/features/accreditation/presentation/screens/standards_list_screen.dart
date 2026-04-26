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
      create: (_) =>
          sl<AccreditationCubit>()..loadSectionsByType(accreditationType),
      child: _StandardsListView(accreditationType: accreditationType),
    );
  }
}

class _StandardsListView extends StatelessWidget {
  final int accreditationType;

  const _StandardsListView({required this.accreditationType});

  @override
  Widget build(BuildContext context) {
   final accreditationTitles = {
    1: 'الاعتماد الأكاديمي',
    2: 'الاعتماد البرامجي',
    3: 'الاعتماد المؤسسي',
  };

  final title = accreditationTitles[accreditationType] ?? 'الاعتماد';

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
                  onPressed: () =>
                      ctx.read<AccreditationCubit>().loadSectionsByType(accreditationType),
                  child: const Text('إعادة المحاولة'),
                ),
              ]),
            );
          }

          if (state is SectionsLoaded) {
            if (state.sections.isEmpty) {
              return const Center(child: Text('لا توجد أقسام'));
            }

            return RefreshIndicator(
              onRefresh: () => ctx.read<AccreditationCubit>().loadSectionsByType(accreditationType),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: state.sections.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final s = state.sections[i] as Map<String, dynamic>? ?? {};

                  final uploaded = (s['uploadedDocuments'] ?? 0) as int;

                  final required = (s['requiredDocumentsCount'] ?? 1) as int;

                  final pct = required > 0
                      ? (uploaded / required).clamp(0.0, 1.0)
                      : 0.0;

                  final color = pct >= 0.7
                      ? AppColors.success
                      : pct >= 0.4
                          ? AppColors.warning
                          : AppColors.error;

                  return AppCard(
                    onTap: () => context.push(
                      '${AppRoutes.standardDetail}?sectionId=${s['sectionId'] ?? 0}&type=$accreditationType',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.chevron_left,
                                color: Theme.of(context).disabledColor),
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