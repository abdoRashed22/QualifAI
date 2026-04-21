// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _showPasswordSection = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    _emailCtrl.text = data['email'] ?? '';
    _firstCtrl.text = data['firstName'] ?? '';
    _lastCtrl.text = data['lastName'] ?? '';
  }

  Future<void> _pickImage(ProfileCubit cubit) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      cubit.uploadPhoto(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cache = sl<HiveCache>();
    final role = cache.getRole() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Ø­Ø³Ø§Ø¨ÙŠ')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (ctx, state) {
          if (state is ProfileLoaded) _populateFields(state.data);
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('ØªÙ… Ø§Ù„Ø­ÙØ¸ Ø¨Ù†Ø¬Ø§Ø­ âœ“'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() => _showPasswordSection = false);
            _oldPassCtrl.clear();
            _newPassCtrl.clear();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (ctx, state) {
          final cubit = ctx.read<ProfileCubit>();
          final isLoading = state is ProfileUpdating;
          final photoUrl = state is ProfileLoaded ? state.data['photoUrl'] as String? : null;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // â”€â”€ Avatar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.blue.withOpacity(0.15),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(
                                  (_firstCtrl.text.isNotEmpty ? _firstCtrl.text[0] : 'Ù…').toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blue,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(cubit),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 16.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${_firstCtrl.text} ${_lastCtrl.text}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4.h),
                  AppBadge(
                    label: _roleLabel(role),
                    color: _roleColor(role),
                  ),
                  SizedBox(height: 24.h),

                  // â”€â”€ Personal Info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ø´Ø®ØµÙŠØ©', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Ø§Ø³Ù… Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©',
                                controller: _lastCtrl,
                                validator: (v) => v!.isEmpty ? 'Ù…Ø·Ù„ÙˆØ¨' : null,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: AppTextField(
                                label: 'Ø§Ù„Ø§Ø³Ù… Ø§Ù„Ø£ÙˆÙ„',
                                controller: _firstCtrl,
                                validator: (v) => v!.isEmpty ? 'Ù…Ø·Ù„ÙˆØ¨' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ù…Ø·Ù„ÙˆØ¨';
                            if (!v.contains('@')) return 'Ø¨Ø±ÙŠØ¯ ØºÙŠØ± ØµØ­ÙŠØ­';
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        AppButton(
                          label: 'Ø­ÙØ¸ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„Ø§Øª',
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.update(
                                _emailCtrl.text.trim(),
                                _firstCtrl.text.trim(),
                                _lastCtrl.text.trim(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // â”€â”€ Change Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                                color: Theme.of(context).disabledColor,
                              ),
                              Text('ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        ),
                        if (_showPasswordSection) ...[
                          SizedBox(height: 16.h),
                          AppTextField(
                            label: 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø­Ø§Ù„ÙŠØ©',
                            controller: _oldPassCtrl,
                            obscure: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) => v!.isEmpty ? 'Ù…Ø·Ù„ÙˆØ¨' : null,
                          ),
                          SizedBox(height: 16.h),
                          AppTextField(
                            label: 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©',
                            controller: _newPassCtrl,
                            obscure: true,
                            prefixIcon: Icons.lock_reset,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ù…Ø·Ù„ÙˆØ¨';
                              if (v.length < 6) return 'ÙŠØ¬Ø¨ Ø£Ù† ØªÙƒÙˆÙ† 6 Ø£Ø­Ø±Ù Ø¹Ù„Ù‰ Ø§Ù„Ø£Ù‚Ù„';
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          AppButton(
                            label: 'ØªØ­Ø¯ÙŠØ« ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
                            isLoading: isLoading,
                            onPressed: () {
                              if (_oldPassCtrl.text.isNotEmpty && _newPassCtrl.text.length >= 6) {
                                cubit.changePassword(_oldPassCtrl.text, _newPassCtrl.text);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // â”€â”€ App Settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§Ù„ØªØ·Ø¨ÙŠÙ‚', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 12.h),
                        // Dark Mode
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (ctx, themeMode) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Switch(
                                value: themeMode == ThemeMode.dark,
                                onChanged: (_) => ctx.read<ThemeCubit>().toggleTheme(),
                                activeColor: AppColors.cyan,
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8.w),
                                  Text('Ø§Ù„ÙˆØ¶Ø¹ Ø§Ù„Ø¯Ø§ÙƒÙ†', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.dark_mode_outlined, size: 20.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        SizedBox(height: 8.h),
                        // Language
                        BlocBuilder<LocaleCubit, dynamic>(
                          builder: (ctx, locale) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => ctx.read<LocaleCubit>().toggleLocale(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.navyBlue,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    locale.languageCode == 'ar' ? 'English' : 'Ø¹Ø±Ø¨ÙŠ',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8.w),
                                  Text('Ø§Ù„Ù„ØºØ©', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.language, size: 20.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  AppCard(
                    onTap: () => _showLogoutDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.logout, color: AppColors.error, size: 20.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬', textAlign: TextAlign.right),
        content: const Text('Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬ØŸ', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ø¥Ù„ØºØ§Ø¡'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              sl<HiveCache>().clearAll();
              context.go(AppRoutes.login);
            },
            child: const Text('ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'system_admin': return 'Ù…Ø¯ÙŠØ± Ø§Ù„Ù†Ø¸Ø§Ù…';
      case 'quality_manager': return 'Ù…Ø¯ÙŠØ± Ø§Ù„Ø¬ÙˆØ¯Ø©';
      case 'quality_employee': return 'Ù…ÙˆØ¸Ù Ø§Ù„Ø¬ÙˆØ¯Ø©';
      case 'reviewer': return 'Ù…Ø±Ø§Ø¬Ø¹';
      default: return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'system_admin': return AppColors.adminColor;
      case 'quality_manager': return AppColors.managerColor;
      case 'quality_employee': return AppColors.employeeColor;
      case 'reviewer': return AppColors.reviewerColor;
      default: return AppColors.blue;
    }
  }
}
