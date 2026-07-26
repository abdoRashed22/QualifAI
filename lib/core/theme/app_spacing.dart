// lib/core/theme/app_spacing.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppSpacing {
  // Double spacing values
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // EdgeInsets - All sides
  static EdgeInsets all4() => EdgeInsets.all(4.w);
  static EdgeInsets all8() => EdgeInsets.all(8.w);
  static EdgeInsets all12() => EdgeInsets.all(12.w);
  static EdgeInsets all16() => EdgeInsets.all(16.w);
  static EdgeInsets all20() => EdgeInsets.all(20.w);
  static EdgeInsets all24() => EdgeInsets.all(24.w);

  // EdgeInsets - Horizontal
  static EdgeInsets horizontal4() => EdgeInsets.symmetric(horizontal: 4.w);
  static EdgeInsets horizontal8() => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets horizontal12() => EdgeInsets.symmetric(horizontal: 12.w);
  static EdgeInsets horizontal16() => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets horizontal20() => EdgeInsets.symmetric(horizontal: 20.w);
  static EdgeInsets horizontal24() => EdgeInsets.symmetric(horizontal: 24.w);

  // EdgeInsets - Vertical
  static EdgeInsets vertical4() => EdgeInsets.symmetric(vertical: 4.h);
  static EdgeInsets vertical8() => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets vertical12() => EdgeInsets.symmetric(vertical: 12.h);
  static EdgeInsets vertical16() => EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets vertical20() => EdgeInsets.symmetric(vertical: 20.h);
  static EdgeInsets vertical24() => EdgeInsets.symmetric(vertical: 24.h);

  // EdgeInsets - Symmetric (horizontal + vertical)
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h.w, vertical: v.h);

  // EdgeInsets - Only (specific sides)
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: left.w,
        top: top.h,
        right: right.w,
        bottom: bottom.h,
      );

  // EdgeInsets - From LTRB
  static EdgeInsets fromLTRB(double l, double t, double r, double b) =>
      EdgeInsets.fromLTRB(l.w, t.h, r.w, b.h);

  // Common padding patterns
  static EdgeInsets cardPadding() => EdgeInsets.all(16.w);
  static EdgeInsets screenPadding() =>
      EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h);
  static EdgeInsets listPadding() =>
      EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h);
  static EdgeInsets dialogPadding() => EdgeInsets.all(24.w);
  static EdgeInsets inputPadding() =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);
  static EdgeInsets chipPadding({bool small = false}) => EdgeInsets.symmetric(
      horizontal: small ? 8.w : 12.w, vertical: small ? 2.h : 4.h);
  static EdgeInsets badgePadding({bool small = false}) => EdgeInsets.symmetric(
      horizontal: small ? 8.w : 12.w, vertical: small ? 2.h : 4.h);
  static EdgeInsets buttonPadding() =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);

  // SizedBox helpers
  static SizedBox box4() => SizedBox(width: 4.w, height: 4.h);
  static SizedBox box8() => SizedBox(width: 8.w, height: 8.h);
  static SizedBox box12() => SizedBox(width: 12.w, height: 12.h);
  static SizedBox box16() => SizedBox(width: 16.w, height: 16.h);
  static SizedBox box20() => SizedBox(width: 20.w, height: 20.h);
  static SizedBox box24() => SizedBox(width: 24.w, height: 24.h);
  static SizedBox box32() => SizedBox(width: 32.w, height: 32.h);

  // SizedBox - Width only
  static SizedBox w4() => SizedBox(width: 4.w);
  static SizedBox w6() => SizedBox(width: 6.w);
  static SizedBox w8() => SizedBox(width: 8.w);
  static SizedBox w10() => SizedBox(width: 10.w);
  static SizedBox w12() => SizedBox(width: 12.w);
  static SizedBox w16() => SizedBox(width: 16.w);
  static SizedBox w20() => SizedBox(width: 20.w);
  static SizedBox w24() => SizedBox(width: 24.w);

  // SizedBox - Height only
  static SizedBox h4() => SizedBox(height: 4.h);
  static SizedBox h6() => SizedBox(height: 6.h);
  static SizedBox h8() => SizedBox(height: 8.h);
  static SizedBox h10() => SizedBox(height: 10.h);
  static SizedBox h12() => SizedBox(height: 12.h);
  static SizedBox h16() => SizedBox(height: 16.h);
  static SizedBox h20() => SizedBox(height: 20.h);
  static SizedBox h24() => SizedBox(height: 24.h);
  static SizedBox h32() => SizedBox(height: 32.h);
  static SizedBox h40() => SizedBox(height: 40.h);
  static SizedBox h48() => SizedBox(height: 48.h);
  static SizedBox h64() => SizedBox(height: 64.h);
  static SizedBox h100() => SizedBox(height: 100.h);
}
