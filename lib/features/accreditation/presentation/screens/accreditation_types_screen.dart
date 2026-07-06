// lib/features/accreditation/presentation/screens/accreditation_types_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../widgets/accreditation_type_card.dart';

class AccreditationTypesScreen extends StatefulWidget {
  const AccreditationTypesScreen({super.key});

  @override
  State<AccreditationTypesScreen> createState() =>
      _AccreditationTypesScreenState();
}

class _AccreditationTypesScreenState extends State<AccreditationTypesScreen> {
  late Future<List<AccreditationTypeModel>> _typesFuture;

  @override
  void initState() {
    super.initState();
    _typesFuture = _loadAccreditationTypes();
  }

  Future<List<AccreditationTypeModel>> _loadAccreditationTypes() async {
    final response = await sl<Dio>().get(ApiEndpoints.accreditationTypes);
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => AccreditationTypeModel.fromMap(item))
          .toList();
    }

    throw Exception('Unexpected response format for accreditation types');
  }

  void _retry() {
    setState(() {
      _typesFuture = _loadAccreditationTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاعتماد'),
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
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('اختر نوع الاعتماد',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 24.h),
            Expanded(
              child: FutureBuilder<List<AccreditationTypeModel>>(
                future: _typesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('فشل تحميل أنواع الاعتماد'),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _retry,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  final types = snapshot.data ?? [];
                  if (types.isEmpty) {
                    return const Center(
                      child: Text('لم يتم العثور على أي أنواع اعتماد'),
                    );
                  }

                  return ListView.separated(
                    itemCount: types.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      return AccreditationTypeCard(
                        icon: type.icon,
                        title: type.title,
                        subtitle: type.subtitle,
                        color: type.color,
                        onTap: () => context.push(
                          '${AppRoutes.standards}?type=${type.id}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccreditationTypeModel {
  final int id;
  final String title;
  final String subtitle;
  final Color color;
  final String icon;

  AccreditationTypeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  factory AccreditationTypeModel.fromMap(Map<String, dynamic> json) {
    final id = int.tryParse(
          json['id']?.toString() ?? json['type']?.toString() ?? '',
        ) ??
        int.tryParse(json['value']?.toString() ?? '') ??
        0;

    final title = _stringValue(
      json['title'] ??
          json['name'] ??
          json['displayName'] ??
          json['nameAr'] ??
          json['titleAr'],
    );

    final subtitle = _stringValue(
      json['description'] ?? json['subtitle'] ?? json['details'],
    );

    final color = _parseColor(
          json['color'] ??
              json['colorHex'] ??
              json['hex'] ??
              json['backgroundColor'],
        ) ??
        _fallbackColor(id);

    final icon = _stringValue(json['icon'] ?? json['symbol'] ?? '🏛️');

    return AccreditationTypeModel(
      id: id,
      title: title.isNotEmpty ? title : 'نوع اعتماد',
      subtitle: subtitle.isNotEmpty ? subtitle : 'اضغط لعرض المعايير',
      color: color,
      icon: icon,
    );
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final hex = raw.replaceAll('#', '').toUpperCase();
    if (RegExp(r'^[0-9A-F]{6}$').hasMatch(hex)) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (RegExp(r'^[0-9A-F]{8}$').hasMatch(hex)) {
      return Color(int.parse(hex, radix: 16));
    }

    return null;
  }

  static Color _fallbackColor(int id) {
    const palette = [
      AppColors.navyBlue,
      AppColors.blue,
      AppColors.success,
      AppColors.cyan,
      AppColors.warning,
      AppColors.error,
    ];
    return palette[id.abs() % palette.length];
  }
}
