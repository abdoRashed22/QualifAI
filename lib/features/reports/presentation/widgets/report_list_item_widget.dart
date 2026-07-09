import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/reports_cubit.dart';
import '../../data/models/report_list_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class ReportListItemWidget extends StatelessWidget {
  final ReportListItemModel item;
  final bool isEmployee;

  const ReportListItemWidget(
      {super.key, required this.item, required this.isEmployee});

  @override
  Widget build(BuildContext context) {
    final pct = item.completionRatio;

    return AppCard(
      onTap: () => context.push(
        AppRoutes.reportDetail.replaceFirst(':id', '${item.id}'),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context.push(
                    AppRoutes.reportDetail.replaceFirst(':id', '${item.id}'),
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'تفاصيل التقرير',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isEmployee) ...[
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => context
                      .read<ReportsCubit>()
                      .downloadCollegeReport(item.collegeId),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'تحميل التقرير',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isEmployee && item.collegeName.isNotEmpty)
                  Text(
                    item.collegeName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: AppColors.blue,
                    ),
                    textAlign: TextAlign.right,
                  ),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 4.h),
                Text(
                  'الحالة: ${item.status}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(pct * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: pct >= 0.7
                            ? AppColors.success
                            : pct >= 0.4
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AppProgressBar(value: pct, height: 5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(' 📋', style: TextStyle(fontSize: 28.sp)),
        ],
      ),
    );
  }
}
