import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String stringValue(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int intValue(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

String formatDate(dynamic value) {
  if (value == null) return '';
  try {
    final date = DateTime.parse(value.toString()).toLocal();
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return value.toString();
  }
}

String statusLabel(dynamic college) {
  final raw = college is Map
      ? college['status'] ?? college['reviewStatus'] ?? college['statusName']
      : null;
  final value = raw?.toString().toLowerCase() ?? '';
  if (value.contains('approve') ||
      value.contains('موافق') ||
      value.contains('معتمد')) {
    return 'معتمد';
  }
  if (value.contains('reject') ||
      value.contains('رفض') ||
      value.contains('مرفوض')) {
    return 'مرفوض';
  }
  if (value.contains('revision') || value.contains('تعديل')) {
    return 'يحتاج تعديل';
  }
  if (value.contains('تسجيل') || value.contains('register')) {
    return 'قيد التسجيل';
  }
  return 'قيد المراجعة';
}

Color statusColor(String status) {
  if (status == 'معتمد') return Colors.green;
  if (status == 'مرفوض') return Colors.red;
  if (status == 'يحتاج تعديل') return Colors.orange;
  if (status == 'قيد التسجيل') return Colors.blueGrey;
  return Colors.blue;
}

Color readinessColor(double value) {
  if (value >= 70) return Colors.green;
  if (value >= 40) return Colors.orange;
  return Colors.redAccent;
}

String resolveImagePath(dynamic imagePath) {
  if (imagePath == null) return '';
  final path = imagePath.toString().trim();
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  if (path.startsWith('/')) {
    return 'https://qualefai.runasp.net$path';
  }
  return 'https://qualefai.runasp.net/$path';
}

Widget buildCollegeImage(dynamic imagePath) {
  final url = resolveImagePath(imagePath);
  return Container(
    width: 52.w,
    height: 52.w,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: url.isEmpty
          ? Center(
              child: Icon(
                Icons.account_balance,
                size: 26.sp,
                color: Colors.grey[600],
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.account_balance,
                  size: 26.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
    ),
  );
}

Widget buildShimmerCard(double height) => Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
