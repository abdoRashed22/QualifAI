import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualif_ai/features/reports/presentation/cubit/reports_cubit.dart';

class ReportsListUploadFab extends StatelessWidget {
  final bool isManager;

  const ReportsListUploadFab({super.key, required this.isManager});

  @override
  Widget build(BuildContext context) {
    if (!isManager) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          if (context.mounted) {
            context.read<ReportsCubit>().uploadReport(file);
          }
        }
      },
      label: const Text('رفع تقرير'),
      icon: const Icon(Icons.upload_file),
    );
  }
}
