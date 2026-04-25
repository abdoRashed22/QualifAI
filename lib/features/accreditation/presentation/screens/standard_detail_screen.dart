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
          if (state is AccreditationLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is AccreditationError) {
            return Center(child: Text(state.message));
          }

          if (state is SectionDetailLoaded) {
            final s = state.section;

            final docs = (s['requiredDocuments'] as List?) ?? [];

            final uploaded = (s['uploadedDocuments'] ?? 0) as int;

            final required = docs.length;

            final pct =
                required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;

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
                      Text(s['name'] ?? '',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).round()}%',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cyan)),
                          Text('درجة الاكتمال',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: Colors.white60)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.cyan),
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

                      final hasFile = doc['hasFile'] ?? false;

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
                                      AppRoutes.fileUpload.replaceFirst(
                                          ':docId', '${doc['id'] ?? 0}'),
                                    ),
                                  ),
                                if (hasFile)
                                  _ActionBtn(
                                    label: 'نتائج AI', // تم تصحيح النص هنا
                                    color: AppColors.success,
                                    onTap: () => context.push(
                                      AppRoutes.aiAnalysis.replaceFirst(
                                          ':docId', '${doc['id'] ?? 0}'),
                                    ),
                                  ),
                                SizedBox(height: 6.h),
                                _ActionBtn(
                                  label: 'تحديد الموعد النهائي',
                                  color: AppColors.warning,
                                  onTap: () => _showDeadlineDialog(
                                      context,
                                      ctx.read<AccreditationCubit>(),
                                      doc['id'] ?? 0),
                                ),
                              ],
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    doc['name'] ??
                                        'مستند ${i + 1}', // النص الافتراضي: مستند 1، مستند 2... إلخ
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        hasFile ? 'مرفوع ✅' : 'لم يُرفع بعد',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11.sp,
                                          color: hasFile
                                              ? AppColors.success
                                              : AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Icon(
                                        hasFile
                                            ? Icons.check_circle_outline
                                            : Icons.upload_file_outlined,
                                        size: 14.sp,
                                        color: hasFile
                                            ? AppColors.success
                                            : AppColors.error,
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

  void _showDeadlineDialog(
      BuildContext context, AccreditationCubit cubit, int docId) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    bool oneWeek = true, oneDay = true, onDue = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
              const Text('التذكيرات',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              CheckboxListTile(
                value: oneWeek,
                onChanged: (v) => setState(() => oneWeek = v!),
                title: const Text('قبل أسبوع',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: oneDay,
                onChanged: (v) => setState(() => oneDay = v!),
                title: const Text('قبل يوم',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: onDue,
                onChanged: (v) => setState(() => onDue = v!),
                title: const Text('يوم الاستحقاق',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);

                cubit.setDeadline(
                  docId,
                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  oneWeek,
                  oneDay,
                  onDue,
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

  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

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
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)),
      ),
    );
  }
}
