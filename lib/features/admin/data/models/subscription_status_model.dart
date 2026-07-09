class SubscriptionStatusModel {
  final int id;
  final String status;
  final String collegeName;
  final String university;
  final String institutionType;
  final String accreditationType;
  final String planName;
  final String planPrice;
  final String startDate;
  final String endDate;

  const SubscriptionStatusModel({
    required this.id,
    required this.status,
    required this.collegeName,
    required this.university,
    required this.institutionType,
    required this.accreditationType,
    required this.planName,
    required this.planPrice,
    required this.startDate,
    required this.endDate,
  });
}
