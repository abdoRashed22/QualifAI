import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../cubit/deadlines_cubit.dart';

class FilterTab extends StatelessWidget {
  final String label;
  final String value;
  final String current;

  const FilterTab({
    required this.label,
    required this.value,
    required this.current,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DeadlinesCubit>().filterBy(value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : Theme.of(context).disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
