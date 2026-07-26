// lib/core/theme/app_radius.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppRadius {
  // Double radius values
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r28 = 28.0;
  static const double r32 = 32.0;
  static const double rFull = 9999.0; // Use for circular shapes

  // BorderRadius objects
  static BorderRadius get small => BorderRadius.circular(r8.r);
  static BorderRadius get medium => BorderRadius.circular(r12.r);
  static BorderRadius get large => BorderRadius.circular(r16.r);
  static BorderRadius get xlarge => BorderRadius.circular(r24.r);
  static BorderRadius get card => BorderRadius.circular(r16.r);
  static BorderRadius get button => BorderRadius.circular(r14.r);
  static BorderRadius get chip => BorderRadius.circular(r20.r);
  static BorderRadius get dialog => BorderRadius.circular(r16.r);
  static BorderRadius get avatar => BorderRadius.circular(rFull);
  static BorderRadius get input => BorderRadius.circular(r12.r);
  static BorderRadius get badge => BorderRadius.circular(r20.r);
  static BorderRadius get progressBar => BorderRadius.circular(r8.r);
  static BorderRadius get image => BorderRadius.circular(r12.r);

  // Custom radius with specific value
  static BorderRadius custom(double radius) => BorderRadius.circular(radius.r);

  // Only specific corners
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft.r),
        topRight: Radius.circular(topRight.r),
        bottomLeft: Radius.circular(bottomLeft.r),
        bottomRight: Radius.circular(bottomRight.r),
      );

  // Top rounded
  static BorderRadius get topRounded => BorderRadius.only(
        topLeft: Radius.circular(r16.r),
        topRight: Radius.circular(r16.r),
      );

  // Bottom rounded
  static BorderRadius get bottomRounded => BorderRadius.only(
        bottomLeft: Radius.circular(r16.r),
        bottomRight: Radius.circular(r16.r),
      );
}
