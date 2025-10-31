import 'package:hive/hive.dart';

part 'asset_model.g.dart';

enum AssetType {
  @HiveField(0)
  cash,
  @HiveField(1)
  bank,
  @HiveField(2)
  gold,
  @HiveField(3)
  silver,
  @HiveField(4)
  investment,
  @HiveField(5)
  property,
  @HiveField(6)
  business,
  @HiveField(7)
  other,
}

@HiveType(typeId: 3)
class AssetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  AssetType type;

  @HiveField(3)
  double value;

  @HiveField(4)
  String currency;

  @HiveField(5)
  DateTime valuationDate;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.currency,
    required this.valuationDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'value': value,
      'currency': currency,
      'valuationDate': valuationDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['name'],
      type: AssetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssetType.other,
      ),
      value: (json['value'] as num).toDouble(),
      currency: json['currency'],
      valuationDate: DateTime.parse(json['valuationDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  AssetModel copyWith({
    String? id,
    String? name,
    AssetType? type,
    double? value,
    String? currency,
    DateTime? valuationDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      valuationDate: valuationDate ?? this.valuationDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

