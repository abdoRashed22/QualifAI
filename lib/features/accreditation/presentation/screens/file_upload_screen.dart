// lib/features/accreditation/presentation/screens/file_upload_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:qualif_ai/core/router/app_router.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/app_button.dart';

import '../cubit/accreditation_cubit.dart';

class FileUploadScreen extends StatefulWidget {
  final int documentId;

  const FileUploadScreen({super.key, required this.documentId});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _selectedFile;

  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);

        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccreditationCubit>(),
      child: BlocConsumer<AccreditationCubit, AccreditationState>(
        listener: (ctx, state) {
          if (state is DocumentUploaded) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text( "تم رفع الملف بنجاح ✅"),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.accreditation);
            }
          }

          if (state is AccreditationError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (ctx, state) {
          final isUploading = state is UploadingDocument;

          return Scaffold(
            appBar: AppBar(title: const Text("رفع ملف جديد")),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'يُرجى تحميل المستندات الخاصة بك بتنسيق PDF أو Word فقط',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),

                  SizedBox(height: 20.h),

                  // Drop zone

                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 180.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: _selectedFile != null
                              ? AppColors.success
                              : AppColors.blue,
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isUploading) ...[
                            const CircularProgressIndicator(),
                            SizedBox(height: 12.h),
                            Text( "جاري الرفع...",
                                style: Theme.of(context).textTheme.bodyMedium),
                          ] else if (_selectedFile != null) ...[
                            Icon(Icons.description_outlined,
                                size: 48.sp, color: AppColors.success),
                            SizedBox(height: 10.h),
                            Text(
                              _fileName ?? '',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text('اضغط لتغيير الملف',
                                style: Theme.of(context).textTheme.bodySmall),
                          ] else ...[
                            Icon(Icons.cloud_upload_outlined,
                                size: 48.sp, color: AppColors.blue),
                            SizedBox(height: 10.h),
                            Text( "اسحب وأفلت الملفات هنا",
                                style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 6.h),
                            Text('أو',
                                style: Theme.of(context).textTheme.bodySmall),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                "أو اختر الملفات",
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (_selectedFile != null && !isUploading) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedFile = null;
                        _fileName = null;
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("حذف الملف المختار",
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: AppColors.error)),
                          SizedBox(width: 4.w),
                          Icon(Icons.delete_outline,
                              size: 16.sp, color: AppColors.error),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  AppButton(
                    label: "رفع الملف",
                    isLoading: isUploading,
                    onPressed: _selectedFile == null
                        ? null
                        : () {
                            ctx.read<AccreditationCubit>().uploadDocument(
                                widget.documentId, _selectedFile!);
                          },
                    icon: Icons.upload,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
