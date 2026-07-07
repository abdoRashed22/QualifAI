//lib/features/support/presentation/screens/support_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qualif_ai/core/di/injection.dart';
import 'package:qualif_ai/core/theme/app_colors.dart';
import 'package:qualif_ai/features/support/presentation/cubit/support_cubit.dart';
import 'package:qualif_ai/features/support/presentation/cubit/support_state.dart';
import 'package:qualif_ai/features/support/presentation/widgets/support_form.dart';

import 'package:qualif_ai/features/support/presentation/widgets/support_header.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupportCubit>(),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatefulWidget {
  const _SupportView();

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني', style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state is SupportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            _nameCtrl.clear();
            _emailCtrl.clear();
            _msgCtrl.clear();
          } else if (state is SupportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SupportLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                const SupportHeader(),
                SizedBox(height: 32.h),
                SupportForm(
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  msgCtrl: _msgCtrl,
                  isLoading: isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
