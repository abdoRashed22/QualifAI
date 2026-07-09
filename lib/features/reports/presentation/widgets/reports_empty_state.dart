import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportsEmptyState extends StatelessWidget {
  const ReportsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🤖', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 16.h),
          const Text(
            'لقد تم إرسال تقريرك بنجاح وسوف تظهر بمجرد استلام المراجع لها',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}
