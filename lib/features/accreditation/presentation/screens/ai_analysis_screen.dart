// lib/features/accreditation/presentation/screens/ai_analysis_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';

import '../../../../shared/widgets/app_badge.dart';



class AiAnalysisScreen extends StatelessWidget {

  final int documentId;

  const AiAnalysisScreen({super.key, required this.documentId});



  @override

  Widget build(BuildContext context) {

    // The AI analysis results come embedded in the uploadDocument response

    // or from the section detail. We display what was returned.

    return Scaffold(

      appBar: AppBar(title: const Text('نتائج التحليل الذكي')),

      body: ListView(

        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),

        children: [

          // Score circle

          Center(

            child: Column(

              children: [

                Text('نتيجة التحليل', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).disabledColor)),

                SizedBox(height: 16.h),

                SizedBox(

                  width: 140.w,

                  height: 140.w,

                  child: Stack(

                    alignment: Alignment.center,

                    children: [

                      SizedBox(

                        width: 140.w,

                        height: 140.w,

                        child: CircularProgressIndicator(

                          value: 0.72,

                          strokeWidth: 10.w,

                          backgroundColor: Theme.of(context).dividerColor,

                          valueColor: const AlwaysStoppedAnimation(AppColors.success),

                        ),

                      ),

                      Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(

                            '72',

                            style: TextStyle(

                              fontFamily: 'Cairo',

                              fontSize: 40.sp,

                              fontWeight: FontWeight.w700,

                              color: AppColors.navyBlue,

                            ),

                          ),

                          Text(

                            '/100',

                            style: TextStyle(

                              fontFamily: 'Cairo',

                              fontSize: 14.sp,

                              color: Theme.of(context).disabledColor,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          SizedBox(height: 24.h),



          // Metrics grid

          Row(

            children: [

              const Expanded(child: _MetricCard(label: 'جودة المستند', value: 'عالية', color: AppColors.success)),

              SizedBox(width: 10.w),

              const Expanded(child: _MetricCard(label: 'نوع المستند'  , value: 'تقرير', color: AppColors.blue)),

            ],

          ),

          SizedBox(height: 10.h),

          Row(

            children: [

              const Expanded(child: _MetricCard(label: 'اللغة', value: 'عربية', color: AppColors.navyBlue)),

              SizedBox(width: 10.w),

              const Expanded(child: _MetricCard(label: 'درجة OCR', value: '94%', color: AppColors.success)),

            ],

          ),

          SizedBox(height: 24.h),



          // Recommendations

          Text('التوصيات', style: Theme.of(context).textTheme.titleMedium),

          SizedBox(height: 12.h),

          const _RecommendationTile(

            icon: Icons.warning_amber_outlined,

            text: "يفتقر التقرير إلى توصيف واضح للأهداف الاستراتيجية",

            color: AppColors.warning,

          ),

          SizedBox(height: 8.h),

          const _RecommendationTile(

            icon: Icons.cancel_outlined,

            text: "لم يتم ذكر آليات المتابعة والتقييم بشكل كافٍ",

            color: AppColors.error,

          ),

          SizedBox(height: 8.h),

          const _RecommendationTile(

            icon: Icons.check_circle_outline,

            text: "التنسيق العام جيد والمحتوى منظم بشكل واضح",

            color: AppColors.success,

          ),

          SizedBox(height: 24.h),



          // Action buttons

          Row(

            children: [

              Expanded(

                child: ElevatedButton(

                  onPressed: () {},

                  child: const Text("عرض التصنيفات"),

                ),

              ),

              SizedBox(width: 12.w),

              Expanded(

                child: OutlinedButton(

                  onPressed: () {},

                  child: const Text( "تحليل ملف آخر"),

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }

}



class _MetricCard extends StatelessWidget {

  final String label;

  final String value;

  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});



  @override

  Widget build(BuildContext context) {

    return AppCard(

      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.end,

        children: [

          Text(label, style: Theme.of(context).textTheme.bodySmall),

          SizedBox(height: 4.h),

          Text(

            value,

            style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp, fontWeight: FontWeight.w700, color: color),

          ),

        ],

      ),

    );

  }

}



class _RecommendationTile extends StatelessWidget {

  final IconData icon;

  final String text;

  final Color color;

  const _RecommendationTile({required this.icon, required this.text, required this.color});



  @override

  Widget build(BuildContext context) {

    return AppCard(

      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(

            child: Text(

              text,

              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: color),

              textAlign: TextAlign.right,

            ),

          ),

          SizedBox(width: 10.w),

          Icon(icon, color: color, size: 20.sp),

        ],

      ),

    );

  }

}

