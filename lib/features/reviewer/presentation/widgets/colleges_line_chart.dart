import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

LineChartBarData buildMainLine(List<FlSpot> spots) {
  return LineChartBarData(
    spots: spots,
    isCurved: true,
    curveSmoothness: 0.35,
    color: AppColors.cyan,
    barWidth: 4.w,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
        radius: 4,
        color: AppColors.cyan,
        strokeWidth: 1.5,
        strokeColor: AppColors.bgDark,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      color: AppColors.cyan.withOpacity(0.15),
    ),
  );
}

Widget buildCollegesLineChart(
  BuildContext context,
  List<dynamic> colleges, {
  required String Function(dynamic) stringValue,
}) {
  final theme = Theme.of(context);
  final spots = colleges.asMap().entries.map((entry) {
    final index = entry.key.toDouble();
    final college = entry.value;
    final readiness =
        (college['readinessPercentage'] as num?)?.toDouble() ?? 0.0;
    return FlSpot(index, readiness);
  }).toList();

  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مستوى جاهزية الكليات',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 200.h,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navyBlue,
                  tooltipBorder:
                      const BorderSide(color: AppColors.cyan, width: 1),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final collegeName =
                          stringValue(colleges[spot.spotIndex]['name']);
                      return LineTooltipItem(
                        '$collegeName\n',
                        TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'الجاهزية: ${spot.y.toInt()}%',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 50,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: theme.hintColor),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= colleges.length) return const SizedBox();
                      final name = stringValue(colleges[index]['name']);
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.sp,
                                color: theme.hintColor)),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [buildMainLine(spots)],
            ),
          ),
        ),
      ],
    ),
  );
}
