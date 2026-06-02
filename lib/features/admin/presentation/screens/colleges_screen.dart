// lib/features/admin/presentation/screens/colleges_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

import '../cubit/admin_cubit.dart';

class CollegesScreen extends StatelessWidget {
  const CollegesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<AdminCubit>()..loadColleges(),
        child: const _CollegesView());
  }
}

class _CollegesView extends StatelessWidget {
  const _CollegesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكليات'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddCollegeDialog(context),
        label: const Text('إضافة كلية'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CollegesLoadedSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading)
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                          width: 45.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r))),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: double.infinity,
                                height: 14.h,
                                color: Colors.white),
                            SizedBox(height: 8.h),
                            Container(
                                width: 120.w,
                                height: 10.h,
                                color: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                          width: 32.sp,
                          height: 32.sp,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle)),
                    ],
                  ),
                ),
              ),
            );

          if (state is CollegesLoaded || state is CollegesLoadedSuccess) {
            final colleges = state is CollegesLoadedSuccess
                ? state.colleges
                : (state as CollegesLoaded).colleges;
            if (colleges.isEmpty)
              return const Center(child: Text('لا توجد كليات'));

            return RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.navyBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await ctx.read<AdminCubit>().loadColleges();
              },
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: colleges.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final c = colleges[i] as Map<String, dynamic>? ?? {};
                  final id = c['id'] ?? 0;
                  final name = c['CollegeName'] ??
                      c['collegeName'] ??
                      c['name'] ??
                      'كلية';
                  final university = c['UniversityName'] ??
                      c['universityName'] ??
                      c['university'] ??
                      '';
                  final institutionType =
                      (c['institutionType'] ?? '').toString();
                  final accreditationType =
                      (c['accreditationType'] ?? '').toString();
                  final status = (c['status'] ?? 'غير محدد').toString();
                  final statusColorStr =
                      (c['statusColor'] ?? '').toString().toLowerCase();
                  final lastUploadDate = (c['lastUploadDate'] ?? '').toString();
                  final readiness =
                      (c['readinessPercentage'] as num?)?.toDouble() ?? 0.0;

                  Color badgeColor = AppColors.navyBlue;
                  if (statusColorStr.contains('gray') ||
                      statusColorStr.contains('grey'))
                    badgeColor = Colors.blueGrey;
                  else if (statusColorStr.contains('green'))
                    badgeColor = AppColors.success;
                  else if (statusColorStr.contains('red'))
                    badgeColor = AppColors.error;
                  else if (statusColorStr.contains('yellow') ||
                      statusColorStr.contains('orange'))
                    badgeColor = AppColors.warning;
                  else if (statusColorStr.contains('blue'))
                    badgeColor = AppColors.blue;

                  Color readinessColor = Colors.green;
                  if (readiness < 40)
                    readinessColor = Colors.redAccent;
                  else if (readiness < 70) readinessColor = Colors.orange;

                  String formattedDate = lastUploadDate;
                  if (lastUploadDate.isNotEmpty &&
                      lastUploadDate.length >= 10) {
                    formattedDate = lastUploadDate.substring(0, 10);
                  }

                  return AppCard(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    ctx.read<AdminCubit>().deleteCollege(id),
                                child: Text('حذف',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (status.isNotEmpty && status != 'غير محدد')
                              AppBadge(
                                  label: status,
                                  color: badgeColor,
                                  small: true),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (university.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      'جامعة $university',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Builder(builder: (context) {
                              final imagePath = (c['image'] ??
                                          c['imagePath'] ??
                                          c['logo'] ??
                                          c['Image'])
                                      ?.toString()
                                      .trim() ??
                                  '';
                              String url = '';
                              if (imagePath.isNotEmpty) {
                                if (imagePath.startsWith('http')) {
                                  url = imagePath;
                                } else if (imagePath.startsWith('/')) {
                                  url = 'https://qualefai.runasp.net$imagePath';
                                } else {
                                  url =
                                      'https://qualefai.runasp.net/$imagePath';
                                }
                              }
                              return Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: url.isEmpty
                                    ? Icon(Icons.account_balance,
                                        size: 24.sp, color: Colors.grey[600])
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                              Icons.account_balance,
                                              size: 24.sp,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                              );
                            }),
                          ],
                        ),
                        if (institutionType.isNotEmpty ||
                            accreditationType.isNotEmpty ||
                            formattedDate.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          const Divider(height: 1, thickness: 0.5),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            alignment: WrapAlignment.end,
                            children: [
                              if (formattedDate.isNotEmpty)
                                _buildMetaChip(Icons.upload_file_outlined,
                                    formattedDate, Colors.teal),
                              if (institutionType.isNotEmpty)
                                _buildMetaChip(Icons.apartment_outlined,
                                    institutionType, Colors.indigo),
                              if (accreditationType.isNotEmpty)
                                _buildMetaChip(Icons.verified_outlined,
                                    accreditationType, Colors.purple),
                            ],
                          ),
                        ],
                        if (c.containsKey('readinessPercentage')) ...[
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              /* Text(
                                '${readiness.toInt()}%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: readinessColor,
                                ),
                              ),*/
                              SizedBox(width: 8.w),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: LinearProgressIndicator(
                                    value: readiness / 100,
                                    minHeight: 7.h,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        readinessColor),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'نسبة الجاهزية',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                    fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          }

          if (state is AdminError) return Center(child: Text(state.message));

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11.sp, color: color)),
          SizedBox(width: 4.w),
          Icon(icon, size: 12.sp, color: color),
        ],
      ),
    );
  }

  void _showAddCollegeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final universityController = TextEditingController();
    final managerEmailController = TextEditingController();
    final managerPasswordController = TextEditingController();
    var institutionType = 2;
    var accreditationType = 1;
    final subscriptionDate = DateTime.now();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إضافة كلية جديدة', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      } catch (e) {
                        debugPrint('Error picking image: $e');
                      }
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child:
                                  Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    color: Colors.grey[600], size: 30.sp),
                                SizedBox(height: 8.h),
                                Text('شعار الكلية',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontFamily: 'Cairo')),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم الكلية',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: universityController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم الجامعة',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: institutionType,
                  decoration: const InputDecoration(
                    labelText: 'نوع المؤسسة',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('حكومية')),
                    DropdownMenuItem(value: 2, child: Text('جامعة أهلية')),
                    DropdownMenuItem(value: 3, child: Text('جامعة خاصة')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      institutionType = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: accreditationType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الاعتماد',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('أكاديمي')),
                    DropdownMenuItem(value: 2, child: Text('برامجي')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      accreditationType = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: managerEmailController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني للمدير',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: managerPasswordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة مرور المدير',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final university = universityController.text.trim();
                final managerEmail = managerEmailController.text.trim();
                final managerPassword = managerPasswordController.text;
                if (name.isNotEmpty &&
                    university.isNotEmpty &&
                    managerEmail.isNotEmpty &&
                    managerPassword.isNotEmpty) {
                  context.read<AdminCubit>().createCollege({
                    'UniversityName': university,
                    'CollegeName': name,
                    'InstitutionType': institutionType,
                    'AccreditationType': accreditationType,
                    'SubscriptionStartDate': subscriptionDate.toIso8601String(),
                    'ManagerEmail': managerEmail,
                    'ManagerPassword': managerPassword,
                    if (selectedImage != null) 'Image': selectedImage,
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PricingScreen ─────────────────────────────────────────────────────────────

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<AdminCubit>()..loadPlans(),
        child: const _PricingView());
  }
}

class _PricingView extends StatelessWidget {
  const _PricingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسعار والاشتراكات'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is PlansLoaded) {
            if (state.plans.isEmpty)
              return const Center(child: Text('لا توجد باقات'));

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.plans.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final p = state.plans[i] as Map<String, dynamic>? ?? {};

                final features = (p['features'] as List?) ?? [];

                final isPopular = i == 1;

                return Container(
                  decoration: BoxDecoration(
                    color: isPopular
                        ? AppColors.navyBlue
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: isPopular
                            ? AppColors.navyBlue
                            : Theme.of(context).dividerColor,
                        width: isPopular ? 0 : 0.5),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isPopular)
                          Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                  color: AppColors.cyan,
                                  borderRadius: BorderRadius.circular(20.r)),
                              child: Text('الأكثر شيوعاً',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: AppColors.navyBlue,
                                      fontWeight: FontWeight.w700))),

                        Text(p['name'] ?? '',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isPopular ? Colors.white : null)),

                        SizedBox(height: 4.h),

                        // ✅ FIX: API بيبعت 'price' كـ double مش string

                        Text('£ ${(p['price'] ?? 0).toStringAsFixed(0)}',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: isPopular
                                    ? AppColors.cyan
                                    : AppColors.navyBlue)),

                        Text('/ سنويًا',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: isPopular ? Colors.white60 : null)),

                        SizedBox(height: 4.h),

                        // ✅ NEW: description من الـ API

                        if ((p['description'] ?? '').toString().isNotEmpty)
                          Text(p['description'].toString(),
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: isPopular
                                      ? Colors.white70
                                      : Theme.of(context).disabledColor),
                              textAlign: TextAlign.right),

                        SizedBox(height: 12.h),

                        ...features.map((f) {
                          final fStr = f.toString();

                          // ✅ FIX: skip 'string' placeholder values from API

                          if (fStr == 'string' || fStr.isEmpty)
                            return const SizedBox.shrink();

                          return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(fStr,
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12.sp,
                                            color: isPopular
                                                ? Colors.white70
                                                : null)),
                                    SizedBox(width: 6.w),
                                    Icon(Icons.check_circle_outline,
                                        size: 14.sp,
                                        color: isPopular
                                            ? AppColors.cyan
                                            : AppColors.success),
                                  ]));
                        }),
                      ]),
                );
              },
            );
          }

          if (state is AdminError) return Center(child: Text(state.message));

          return const SizedBox();
        },
      ),
    );
  }
}
