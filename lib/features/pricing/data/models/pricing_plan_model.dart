class PricingPlanModel {
  final int? id;
  final String name;
  final String description;
  final String price;
  final String? billingCycle;
  final List<String> features;
  final bool isActive;
  final bool isCurrentPlan;

  const PricingPlanModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.billingCycle,
    this.features = const [],
    this.isActive = false,
    this.isCurrentPlan = false,
  });

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = <String>[];

    if (rawFeatures is List) {
      for (final item in rawFeatures) {
        final value = item?.toString().trim();
        if (value != null && value.isNotEmpty && value != 'string') {
          features.add(value);
        }
      }
    } else if (rawFeatures is String) {
      final split = rawFeatures
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != 'string');
      features.addAll(split);
    }

    return PricingPlanModel(
      id: int.tryParse('${json['id'] ?? json['planId'] ?? json['pricingId']}'),
      name: (json['name'] ?? 'الباقة').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] ?? '0').toString(),
      billingCycle: json['billingCycle']?.toString(),
      features: features,
      isActive: json['isActive'] == true || json['isCurrentPlan'] == true,
      isCurrentPlan: json['isCurrentPlan'] == true,
    );
  }
}
