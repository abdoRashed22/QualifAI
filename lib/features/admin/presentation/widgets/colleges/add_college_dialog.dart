// lib/features/admin/presentation/widgets/colleges/add_college_dialog.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../cubit/admin_cubit.dart';

/// Dialog for adding a new college
/// Matches original inline dialog exactly - ALL fields preserved
class AddCollegeDialog extends StatefulWidget {
  final AdminCubit cubit;

  const AddCollegeDialog({super.key, required this.cubit});

  static Future<bool?> show(BuildContext context, AdminCubit cubit) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddCollegeDialog(cubit: cubit),
    );
  }

  @override
  State<AddCollegeDialog> createState() => _AddCollegeDialogState();
}

class _AddCollegeDialogState extends State<AddCollegeDialog> {
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _managerPasswordController = TextEditingController();
  final _imagePicker = ImagePicker();

  int _institutionType = 2; // Default: جامعة أهلية
  int _accreditationType = 1; // Default: أكاديمي
  final DateTime _subscriptionDate = DateTime.now();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _managerEmailController.dispose();
    _managerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final university = _universityController.text.trim();
    final managerEmail = _managerEmailController.text.trim();
    final managerPassword = _managerPasswordController.text;

    if (name.isEmpty ||
        university.isEmpty ||
        managerEmail.isEmpty ||
        managerPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.cubit.createCollege({
        'UniversityName': university,
        'CollegeName': name,
        'InstitutionType': _institutionType,
        'AccreditationType': _accreditationType,
        'SubscriptionStartDate': _subscriptionDate.toIso8601String(),
        'ManagerEmail': managerEmail,
        'ManagerPassword': managerPassword,
        if (_selectedImage != null) 'Image': _selectedImage,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الكلية بنجاح')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإضافة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16.r),
        ),
        child: Padding(
          padding: AppSpacing.dialogPadding(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title
                Center(
                  child: Text(
                    'إضافة كلية جديدة',
                    style: AppTypography.titleLarge(),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSpacing.h20(),

                // Image picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(AppRadius.r12.r),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r12.r),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 30.sp, color: AppColors.subTextLight),
                                AppSpacing.h8(),
                                Text('شعار الكلية',
                                    style: AppTypography.bodySmall()),
                              ],
                            ),
                    ),
                  ),
                ),
                AppSpacing.h16(),

                // CollegeName
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم الكلية',
                  ),
                ),
                AppSpacing.h12(),

                // UniversityName
                TextField(
                  controller: _universityController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم الجامعة',
                  ),
                ),
                AppSpacing.h12(),

                // InstitutionType dropdown
                DropdownButtonFormField<int>(
                  value: _institutionType,
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
                      setState(() => _institutionType = value);
                    }
                  },
                ),
                AppSpacing.h12(),

                // AccreditationType dropdown
                DropdownButtonFormField<int>(
                  value: _accreditationType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الاعتماد',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('أكاديمي')),
                    DropdownMenuItem(value: 2, child: Text('برامجي')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _accreditationType = value);
                    }
                  },
                ),
                AppSpacing.h12(),

                // ManagerEmail
                TextField(
                  controller: _managerEmailController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني للمدير',
                  ),
                ),
                AppSpacing.h12(),

                // ManagerPassword
                TextField(
                  controller: _managerPasswordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة مرور المدير',
                  ),
                ),
                AppSpacing.h24(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: AppSpacing.buttonPadding(),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r12.r),
                          ),
                        ),
                        child: Text('إلغاء',
                            style: AppTypography.buttonText()
                                .copyWith(color: AppColors.subTextLight)),
                      ),
                    ),
                    AppSpacing.w12(),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: AppSpacing.buttonPadding(),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r12.r),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('حفظ',
                                style: AppTypography.buttonText()
                                    .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
