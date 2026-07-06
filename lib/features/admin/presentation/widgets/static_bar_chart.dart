import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

BarChartGroupData makeBarGroup(int x, double y, Color color) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 14.w,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(6.r),
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 20,
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
    ],
  );
}

Widget buildStaticBarChart(BuildContext context) {
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'معدل تقديم طلبات الاعتماد (آخر 6 أشهر)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 180.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navyBlue,
                  tooltipBorder:
                      const BorderSide(color: AppColors.cyan, width: 1),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} طلب',
                      TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'يناير',
                        'فبراير',
                        'مارس',
                        'أبريل',
                        'مايو',
                        'يونيو'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                makeBarGroup(0, 8, AppColors.blue),
                makeBarGroup(1, 14, AppColors.cyan),
                makeBarGroup(2, 11, AppColors.success),
                makeBarGroup(3, 18, AppColors.warning),
                makeBarGroup(4, 9, AppColors.info),
                makeBarGroup(5, 15, AppColors.blue),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
