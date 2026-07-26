// lib/features/admin/presentation/widgets/colleges/college_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/data_display/app_badge.dart' as badges;
import '../../../../../shared/widgets/data_display/app_meta_chip.dart';
import '../../../../../shared/widgets/data_display/app_progress_bar.dart'
    as progress;
import '../../../../../shared/widgets/app_card.dart';
import '../../cubit/admin_cubit.dart';

/// College card widget extracted from colleges_screen.dart
class CollegeCard extends StatelessWidget {
  final Map<String, dynamic> college;
  final AdminCubit cubit;

  const CollegeCard({
    super.key,
    required this.college,
    required this.cubit,
  });

  Color _resolveStatusColor(String statusColorStr) {
    final s = statusColorStr.toLowerCase();
    if (s.contains('gray') || s.contains('grey')) return Colors.blueGrey;
    if (s.contains('green')) return AppColors.success;
    if (s.contains('red')) return AppColors.error;
    if (s.contains('yellow') || s.contains('orange')) return AppColors.warning;
    if (s.contains('blue')) return AppColors.blue;
    return AppColors.navyBlue;
  }

  String _formatDate(String date) {
    if (date.isNotEmpty && date.length >= 10) return date.substring(0, 10);
    return date;
  }

  String _resolveImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/'))
      return 'https://qualefai.runasp.net$imagePath';
    return 'https://qualefai.runasp.net/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final id = college['id'] ?? 0;
    final name = college['CollegeName'] ??
        college['collegeName'] ??
        college['name'] ??
        'كلية';
    final university = college['UniversityName'] ??
        college['universityName'] ??
        college['university'] ??
        '';
    final institutionType = (college['institutionType'] ?? '').toString();
    final accreditationType = (college['accreditationType'] ?? '').toString();
    final status = (college['status'] ?? 'غير محدد').toString();
    final statusColorStr =
        (college['statusColor'] ?? '').toString().toLowerCase();
    final lastUploadDate = (college['lastUploadDate'] ?? '').toString();
    final readiness =
        (college['readinessPercentage'] as num?)?.toDouble() ?? 0.0;
    final imagePath = (college['image'] ??
                college['imagePath'] ??
                college['logo'] ??
                college['Image'])
            ?.toString()
            .trim() ??
        '';

    final badgeColor = _resolveStatusColor(statusColorStr);
    final formattedDate = _formatDate(lastUploadDate);
    final imageUrl = _resolveImageUrl(imagePath);

    return AppCard(
      padding: AppSpacing.all12(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => cubit.deleteCollege(id),
                child: Container(
                  padding: AppSpacing.chipPadding(small: true),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.r8.r),
                  ),
                  child: Text('حذف',
                      style: AppTypography.badgeSmall(color: Colors.white)),
                ),
              ),
              AppSpacing.w8(),
              if (status.isNotEmpty && status != 'غير محدد')
                badges.AppBadge(label: status, color: badgeColor, small: true),
              AppSpacing.w8(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (university.isNotEmpty) ...[
                      AppSpacing.h4(),
                      Text('جامعة $university',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              AppSpacing.w10(),
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(AppRadius.r12.r),
                ),
                child: imageUrl.isEmpty
                    ? Icon(Icons.account_balance,
                        size: 24.sp, color: Colors.grey[600])
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r12.r),
                        child: Image.network(imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.account_balance,
                                size: 24.sp,
                                color: Colors.grey[600])),
                      ),
              ),
            ],
          ),
          if (institutionType.isNotEmpty ||
              accreditationType.isNotEmpty ||
              formattedDate.isNotEmpty) ...[
            AppSpacing.h12(),
            const Divider(height: 1, thickness: 0.5),
            AppSpacing.h10(),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              alignment: WrapAlignment.end,
              children: [
                if (formattedDate.isNotEmpty)
                  AppMetaChip(
                      icon: Icons.upload_file_outlined,
                      label: formattedDate,
                      color: Colors.teal),
                if (institutionType.isNotEmpty)
                  AppMetaChip(
                      icon: Icons.apartment_outlined,
                      label: institutionType,
                      color: Colors.indigo),
                if (accreditationType.isNotEmpty)
                  AppMetaChip(
                      icon: Icons.verified_outlined,
                      label: accreditationType,
                      color: Colors.purple),
              ],
            ),
          ],
          if (college.containsKey('readinessPercentage')) ...[
            AppSpacing.h10(),
            Row(
              children: [
                Expanded(
                  child: progress.AppProgressBar(value: readiness),
                ),
                AppSpacing.w8(),
                Text(
                  'نسبة الجاهزية',
                  style: AppTypography.caption(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
