import 'package:equatable/equatable.dart';

class CollegeModel extends Equatable {
  final int id;
  final String collegeName;
  final String universityName;
  final String institutionType;
  final String accreditationType;
  final String subscriptionStartDate;
  final String managerEmail;
  final String managerPassword;
  final String status;
  final String statusColor;
  final String lastUploadDate;
  final double readinessPercentage;
  final String image;

  const CollegeModel({
    required this.id,
    required this.collegeName,
    required this.universityName,
    required this.institutionType,
    required this.accreditationType,
    required this.subscriptionStartDate,
    required this.managerEmail,
    required this.managerPassword,
    required this.status,
    required this.statusColor,
    required this.lastUploadDate,
    required this.readinessPercentage,
    required this.image,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? 0;
    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    String collegeName =
        (json['CollegeName'] ?? json['collegeName'] ?? json['name'] ?? 'كلية')
            .toString();
    String universityName = (json['UniversityName'] ??
            json['universityName'] ??
            json['university'] ??
            '')
        .toString();

    final institutionType =
        (json['InstitutionType'] ?? json['institutionType'] ?? '').toString();
    final accreditationType =
        (json['AccreditationType'] ?? json['accreditationType'] ?? '')
            .toString();

    final subscriptionStartDate =
        (json['SubscriptionStartDate'] ?? json['subscriptionStartDate'] ?? '')
            .toString();
    final managerEmail =
        (json['ManagerEmail'] ?? json['managerEmail'] ?? '').toString();
    final managerPassword =
        (json['ManagerPassword'] ?? json['managerPassword'] ?? '').toString();

    final status = (json['status'] ?? 'غير محدد').toString();
    final statusColor = (json['statusColor'] ?? '').toString();

    final lastUploadDate = (json['lastUploadDate'] ?? '').toString();

    final readinessRaw = json['readinessPercentage'] ?? json['readiness'] ?? 0;
    final readinessPercentage = readinessRaw is num
        ? readinessRaw.toDouble()
        : double.tryParse(readinessRaw.toString()) ?? 0.0;

    final image = (json['image'] ??
            json['imagePath'] ??
            json['logo'] ??
            json['Image'] ??
            '')
        .toString();

    return CollegeModel(
      id: id,
      collegeName: collegeName,
      universityName: universityName,
      institutionType: institutionType,
      accreditationType: accreditationType,
      subscriptionStartDate: subscriptionStartDate,
      managerEmail: managerEmail,
      managerPassword: managerPassword,
      status: status,
      statusColor: statusColor,
      lastUploadDate: lastUploadDate,
      readinessPercentage: readinessPercentage,
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'CollegeName': collegeName,
      'UniversityName': universityName,
      'InstitutionType': institutionType,
      'AccreditationType': accreditationType,
      'SubscriptionStartDate': subscriptionStartDate,
      'ManagerEmail': managerEmail,
      'ManagerPassword': managerPassword,
      'status': status,
      'statusColor': statusColor,
      'lastUploadDate': lastUploadDate,
      'readinessPercentage': readinessPercentage,
      'image': image,
    };
  }

  CollegeModel copyWith({
    int? id,
    String? collegeName,
    String? universityName,
    String? institutionType,
    String? accreditationType,
    String? subscriptionStartDate,
    String? managerEmail,
    String? managerPassword,
    String? status,
    String? statusColor,
    String? lastUploadDate,
    double? readinessPercentage,
    String? image,
  }) {
    return CollegeModel(
      id: id ?? this.id,
      collegeName: collegeName ?? this.collegeName,
      universityName: universityName ?? this.universityName,
      institutionType: institutionType ?? this.institutionType,
      accreditationType: accreditationType ?? this.accreditationType,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      managerEmail: managerEmail ?? this.managerEmail,
      managerPassword: managerPassword ?? this.managerPassword,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      lastUploadDate: lastUploadDate ?? this.lastUploadDate,
      readinessPercentage: readinessPercentage ?? this.readinessPercentage,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
        id,
        collegeName,
        universityName,
        institutionType,
        accreditationType,
        subscriptionStartDate,
        managerEmail,
        managerPassword,
        status,
        statusColor,
        lastUploadDate,
        readinessPercentage,
        image,
      ];
}
