import 'package:hive/hive.dart';

part 'liability_model.g.dart';

enum LiabilityType {
  @HiveField(0)
  shortTerm,
  @HiveField(1)
  longTerm,
}

@HiveType(typeId: 4)
class LiabilityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String creditorName;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String currency;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  LiabilityType type;

  @HiveField(7)
  bool includeInZakat;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  LiabilityModel({
    required this.id,
    required this.creditorName,
    this.description,
    required this.amount,
    required this.currency,
    this.dueDate,
    this.type = LiabilityType.shortTerm,
    this.includeInZakat = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditorName': creditorName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate?.toIso8601String(),
      'type': type.name,
      'includeInZakat': includeInZakat,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LiabilityModel.fromJson(Map<String, dynamic> json) {
    return LiabilityModel(
      id: json['id'],
      creditorName: json['creditorName'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      type: LiabilityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LiabilityType.shortTerm,
      ),
      includeInZakat: json['includeInZakat'] ?? true,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  LiabilityModel copyWith({
    String? id,
    String? creditorName,
    String? description,
    double? amount,
    String? currency,
    DateTime? dueDate,
    LiabilityType? type,
    bool? includeInZakat,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiabilityModel(
      id: id ?? this.id,
      creditorName: creditorName ?? this.creditorName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      includeInZakat: includeInZakat ?? this.includeInZakat,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

