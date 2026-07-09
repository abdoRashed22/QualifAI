import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qualif_ai/core/di/injection.dart';
import 'package:qualif_ai/core/router/app_router.dart';

import 'package:dio/dio.dart';
import 'package:qualif_ai/core/theme/app_colors.dart';

import '../../../profile/data/remote/side_rail_navigation.dart';

// NOTE: this screen currently reuses Dio directly like other admin screens
// to keep the change minimal.

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  late final Dio _dio;
  bool _loading = true;
  String? _error;

  List<dynamic> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _dio = sl<Dio>();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/Subscription');
      final data = res.data;
      if (data is List) {
        _subscriptions = data;
      } else if (data is Map) {
        if (data['data'] is List) {
          _subscriptions = data['data'] as List;
        } else if (data['result'] is List) {
          _subscriptions = data['result'] as List;
        } else {
          _subscriptions = [];
        }
      } else {
        _subscriptions = [];
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل بيانات الاشتراكات';
      });
    }
  }

  String _statusText(dynamic sub) {
    final status =
        (sub['status'] ?? sub['subscriptionStatus'] ?? sub['statusName'] ?? '')
            .toString();
    return status.isEmpty ? 'غير محدد' : status;
  }

  Color _statusColor(String status) {
    final s = status.trim();
    if (s == 'فعال') return Colors.green;
    if (s == 'موقوف') return Colors.grey;
    if (s == 'منتهي') return Colors.red;
    return Colors.blueGrey;
  }

  Future<void> _updateStatus({
    required int subscriptionId,
    required String toStatus,
  }) async {
    final endpoint = toStatus == 'فعال'
        ? '/Subscription/activate/$subscriptionId'
        : toStatus == 'موقوف'
            ? '/Subscription/suspend/$subscriptionId'
            : null;

    if (endpoint == null) return;

    await _dio.put(endpoint);
    await _fetch();
  }

  void _showSubscriptionDetails(Map<String, dynamic> sub) {
    final id = int.tryParse('${sub['id'] ?? 0}') ?? 0;
    final collegeName = (sub['collegeName'] ?? 'كلية').toString();
    final university = (sub['university'] ?? '').toString();
    final institutionType = (sub['institutionType'] ?? '').toString();
    final accreditationType = (sub['accreditationType'] ?? '').toString();
    final planName = (sub['planName'] ?? '').toString();
    final planPrice = sub['planPrice']?.toString() ?? '';
    final startDate = (sub['startDate'] ?? '').toString();
    final endDate = (sub['endDate'] ?? '').toString();

    final status = _statusText(sub);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تفاصيل الاشتراك',
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22.sp,
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                collegeName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (university.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'جامعة $university',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: Theme.of(ctx).disabledColor,
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              _DetailRow(
                label: 'الحالة',
                value: status,
                valueColor: _statusColor(status),
                icon: Icons.info_outline,
              ),
              SizedBox(height: 10.h),
              if (planName.isNotEmpty)
                _DetailRow(
                  label: 'الخطة',
                  value: planName,
                  icon: Icons.menu_book_outlined,
                ),
              SizedBox(height: 10.h),
              if (planPrice.toString().trim().isNotEmpty)
                _DetailRow(
                  label: 'السعر',
                  value: planPrice,
                  icon: Icons.attach_money_outlined,
                ),
              SizedBox(height: 10.h),
              if (startDate.isNotEmpty)
                _DetailRow(
                  label: 'بداية',
                  value: startDate.length >= 10
                      ? startDate.substring(0, 10)
                      : startDate,
                  icon: Icons.play_arrow,
                ),
              SizedBox(height: 10.h),
              if (endDate.isNotEmpty)
                _DetailRow(
                  label: 'نهاية',
                  value:
                      endDate.length >= 10 ? endDate.substring(0, 10) : endDate,
                  icon: Icons.event_available,
                ),
              SizedBox(height: 10.h),
              if (institutionType.isNotEmpty)
                _DetailRow(
                  label: 'نوع المؤسسة',
                  value: institutionType,
                  icon: Icons.apartment_outlined,
                ),
              SizedBox(height: 10.h),
              if (accreditationType.isNotEmpty)
                _DetailRow(
                  label: 'نوع الاعتماد',
                  value: accreditationType,
                  icon: Icons.verified_outlined,
                ),
              SizedBox(height: 10.h),
              if (id > 0) ...[
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionChip(
                      label: 'فعال',
                      color: AppColors.success,
                      onTap: () async {
                        await _updateStatus(
                            subscriptionId: id, toStatus: 'فعال');
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                    SizedBox(width: 8.w),
                    _ActionChip(
                      label: 'موقوف',
                      color: AppColors.warning,
                      onTap: () async {
                        await _updateStatus(
                            subscriptionId: id, toStatus: 'موقوف');
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                    SizedBox(width: 8.w),
                    _ActionChip(
                      label: 'منتهي',
                      color: AppColors.error,
                      onTap: () async {
                        // Swagger endpoint لا يدعم direct لـ "منتهي".
                        // فاعتبرناه اقرب حالة عبر suspend.
                        await _updateStatus(
                            subscriptionId: id, toStatus: 'موقوف');
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة الاشتراك'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.cyan,
                  backgroundColor: Colors.indigo,
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemCount: _subscriptions.length,
                    itemBuilder: (context, i) {
                      final sub =
                          _subscriptions[i] as Map<String, dynamic>? ?? {};
                      final id = int.tryParse('${sub['id'] ?? 0}') ?? 0;

                      final collegeName =
                          (sub['collegeName'] ?? 'كلية').toString();
                      final university = (sub['university'] ?? '').toString();
                      final status = _statusText(sub);

                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => _showSubscriptionDetails(sub),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                            color: _statusColor(status),
                                            width: 1),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(status),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.school_outlined,
                                        size: 20.sp, color: Colors.indigo),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  collegeName,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                if (university.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    'جامعة $university',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.sp,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                // quick actions (keeps previous UI look)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _ActionChip(
                                      label: 'فعال',
                                      color: AppColors.success,
                                      onTap: () async {
                                        if (id <= 0) return;
                                        await _updateStatus(
                                            subscriptionId: id,
                                            toStatus: 'فعال');
                                      },
                                    ),
                                    SizedBox(width: 8.w),
                                    _ActionChip(
                                      label: 'موقوف',
                                      color: AppColors.warning,
                                      onTap: () async {
                                        if (id <= 0) return;
                                        await _updateStatus(
                                            subscriptionId: id,
                                            toStatus: 'موقوف');
                                      },
                                    ),
                                    SizedBox(width: 8.w),
                                    _ActionChip(
                                      label: 'منتهي',
                                      color: AppColors.error,
                                      onTap: () async {
                                        if (id <= 0) return;
                                        // لا يوجد endpoint "منتهي" مباشر في الـ swagger المتاح.
                                        // فبنعتبره suspend.
                                        await _updateStatus(
                                            subscriptionId: id,
                                            toStatus: 'موقوف');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: Theme.of(context).disabledColor),
              SizedBox(width: 6.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: valueColor ??
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
