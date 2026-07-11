import 'package:equatable/equatable.dart';

class PlanModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> features;

  const PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? 0;
    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    final name = (json['name'] ?? '').toString();
    final description = (json['description'] ?? '').toString();

    final priceRaw = json['price'] ?? 0;
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw.toString()) ?? 0.0;

    final featuresRaw = json['features'];
    final features = featuresRaw is List
        ? featuresRaw
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    return PlanModel(
      id: id,
      name: name,
      description: description,
      price: price,
      features: features,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'features': features,
    };
  }

  PlanModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    List<String>? features,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      features: features ?? this.features,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, features];
}
