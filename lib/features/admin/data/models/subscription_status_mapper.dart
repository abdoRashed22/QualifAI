import 'subscription_status_model.dart';

class SubscriptionStatusMapper {
  static SubscriptionStatusModel fromJson(Map<String, dynamic> sub) {
    final id = int.tryParse('${sub['id'] ?? 0}') ?? 0;

    String _statusText() {
      final status = (sub['status'] ??
              sub['subscriptionStatus'] ??
              sub['statusName'] ??
              '')
          .toString();
      return status.isEmpty ? 'غير محدد' : status;
    }

    String _toString(dynamic v) => (v ?? '').toString();

    return SubscriptionStatusModel(
      id: id,
      status: _statusText(),
      collegeName: _toString(sub['collegeName'] ?? 'كلية'),
      university: _toString(sub['university'] ?? ''),
      institutionType: _toString(sub['institutionType'] ?? ''),
      accreditationType: _toString(sub['accreditationType'] ?? ''),
      planName: _toString(sub['planName'] ?? ''),
      planPrice: _toString(sub['planPrice'] ?? ''),
      startDate: _toString(sub['startDate'] ?? ''),
      endDate: _toString(sub['endDate'] ?? ''),
    );
  }
}
