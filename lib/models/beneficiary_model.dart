import 'package:hive/hive.dart';

part 'beneficiary_model.g.dart';

@HiveType(typeId: 5)
class BeneficiaryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? contactInfo;

  @HiveField(3)
  double? percentageShare;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  BeneficiaryModel({
    required this.id,
    required this.name,
    this.contactInfo,
    this.percentageShare,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactInfo': contactInfo,
      'percentageShare': percentageShare,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryModel(
      id: json['id'],
      name: json['name'],
      contactInfo: json['contactInfo'],
      percentageShare: json['percentageShare'] != null
          ? (json['percentageShare'] as num).toDouble()
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  BeneficiaryModel copyWith({
    String? id,
    String? name,
    String? contactInfo,
    double? percentageShare,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeneficiaryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      percentageShare: percentageShare ?? this.percentageShare,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

