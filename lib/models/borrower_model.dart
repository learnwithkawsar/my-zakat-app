import 'package:hive/hive.dart';

part 'borrower_model.g.dart';

@HiveType(typeId: 0)
class BorrowerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? contactInfo;

  @HiveField(3)
  String? address;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  BorrowerModel({
    required this.id,
    required this.name,
    this.contactInfo,
    this.address,
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
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BorrowerModel.fromJson(Map<String, dynamic> json) {
    return BorrowerModel(
      id: json['id'],
      name: json['name'],
      contactInfo: json['contactInfo'],
      address: json['address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  BorrowerModel copyWith({
    String? id,
    String? name,
    String? contactInfo,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BorrowerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

