import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/app_card.dart';
import '../cubit/dashboard_cubit.dart';
import 'dashboard_helpers.dart';

Widget buildComplianceChart(
  BuildContext context,
  List<SectionSummary> sections,
) {
  if (sections.isEmpty) {
    return const SizedBox.shrink();
  }

  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الامتثال للمعايير',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 200.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
                  tooltipBorder: const BorderSide(color: Colors.cyan, width: 1),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final sectionName = sections[group.x.toInt()].name;
                    return BarTooltipItem(
                      '$sectionName\n',
                      TextStyle(
                        fontFamily: 'Cairo',
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'نسبة الإنجاز: ${rod.toY.round()}%',
                          style: TextStyle(
                            color: rod.color,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (val, meta) {
                      final i = val.toInt();
                      if (i >= sections.length) return const SizedBox();
                      return Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: sections.asMap().entries.map((e) {
                final pct = (e.value.completionPercent * 100);
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: pct,
                      color: pctColor(e.value.completionPercent),
                      width: 16.w,
                      borderRadius: BorderRadius.circular(5.r),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color:
                            Theme.of(context).disabledColor.withOpacity(0.08),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}
