// lib/features/admin/presentation/screens/roles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadRoles(),
      child: const _RolesView(),
    );
  }
}

class _RolesView extends StatelessWidget {
  const _RolesView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ø§Ù„Ø£Ø¯ÙˆØ§Ø± ÙˆØ§Ù„ØµÙ„Ø§Ø­ÙŠØ§Øª'), actions: [
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showAddRoleDialog(context)),
      ]),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.success));
          if (state is AdminError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
        },
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is RolesLoaded) {
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.roles.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final r = state.roles[i] as Map<String, dynamic>? ?? {};
                return AppCard(child: Row(children: [
                  GestureDetector(
                    onTap: () => ctx.read<AdminCubit>().deleteRole(r['id'] ?? 0),
                    child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8.r)),
                      child: Text('Ø­Ø°Ù', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white))),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r['roleName'] ?? r['name'] ?? 'Ø¯ÙˆØ±', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                    SizedBox(height: 4.h),
                    Text(r['description'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right, maxLines: 2),
                  ])),
                  SizedBox(width: 10.w),
                  Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: AppColors.adminColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.security_outlined, color: AppColors.adminColor, size: 20.sp)),
                ]));
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('Ø¥Ù†Ø´Ø§Ø¡ Ø¯ÙˆØ± Ø¬Ø¯ÙŠØ¯', textAlign: TextAlign.right),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        AppTextField(label: 'Ø§Ø³Ù… Ø§Ù„Ø¯ÙˆØ±', controller: nameCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'ÙˆØµÙ Ø§Ù„Ø¯ÙˆØ±', controller: descCtrl, maxLines: 2),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ø¥Ù„ØºØ§Ø¡')),
        ElevatedButton(onPressed: () { Navigator.pop(context); context.read<AdminCubit>().createRole(nameCtrl.text, descCtrl.text); }, child: const Text('Ø¥Ù†Ø´Ø§Ø¡')),
      ],
    ));
  }
}
