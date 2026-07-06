import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/app_card.dart';
import '../../../../../core/theme/app_colors.dart';

Widget buildStaticLineChart(BuildContext context) {
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'منحنى نشاط النظام وتقديم الطلبات',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 180.h,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navyBlue,
                  tooltipBorder:
                      const BorderSide(color: AppColors.cyan, width: 1),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y.toInt()} طلب',
                        TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
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
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 8),
                    FlSpot(1, 12),
                    FlSpot(2, 14),
                    FlSpot(3, 13),
                    FlSpot(4, 16),
                    FlSpot(5, 18),
                  ],
                  isCurved: true,
                  color: AppColors.cyan,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.cyan,
                        strokeWidth: 0,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
