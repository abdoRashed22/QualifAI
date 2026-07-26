// lib/shared/widgets/inputs/app_image_picker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable image picker widget that replaces inline image picking patterns
class AppImagePicker extends StatelessWidget {
  final String? imagePath;
  final double size;
  final VoidCallback? onPickFromGallery;
  final VoidCallback? onPickFromCamera;
  final VoidCallback? onRemove;
  final bool editable;

  const AppImagePicker({
    super.key,
    this.imagePath,
    this.size = 120,
    this.onPickFromGallery,
    this.onPickFromCamera,
    this.onRemove,
    this.editable = true,
  });

  /// Show bottom sheet to choose image source
  static Future<void> showPickerSheet(
    BuildContext context, {
    required ValueChanged<ImageSource> onImagePicked,
    VoidCallback? onRemove,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24.r),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.all24(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختيار صورة',
                style: AppTypography.titleMedium(),
              ),
              AppSpacing.h24(),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('المعرض'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onImagePicked(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('الكاميرا'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onImagePicked(ImageSource.camera);
                },
              ),
              if (onRemove != null)
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('إزالة الصورة',
                      style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onRemove();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable
          ? () => showPickerSheet(
                context,
                onImagePicked: (source) {
                  if (source == ImageSource.gallery) {
                    onPickFromGallery?.call();
                  } else {
                    onPickFromCamera?.call();
                  }
                },
                onRemove: onRemove,
              )
          : null,
      child: Stack(
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).dividerColor,
              image: imagePath != null
                  ? DecorationImage(
                      image: FileImage(
                        File(imagePath!),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imagePath == null
                ? Icon(
                    Icons.person,
                    size: size.w * 0.4,
                    color: Theme.of(context).disabledColor,
                  )
                : null,
          ),
          if (editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: AppSpacing.all4(),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
