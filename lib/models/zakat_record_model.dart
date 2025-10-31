import 'package:hive/hive.dart';

part 'zakat_record_model.g.dart';

@HiveType(typeId: 6)
class ZakatRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime calculationDate;

  @HiveField(2)
  double assetsTotal;

  @HiveField(3)
  double receivablesTotal;

  @HiveField(4)
  double liabilitiesTotal;

  @HiveField(5)
  double netZakatableAmount;

  @HiveField(6)
  double zakatDue;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  ZakatRecordModel({
    required this.id,
    required this.calculationDate,
    required this.assetsTotal,
    required this.receivablesTotal,
    required this.liabilitiesTotal,
    required this.netZakatableAmount,
    required this.zakatDue,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculationDate': calculationDate.toIso8601String(),
      'assetsTotal': assetsTotal,
      'receivablesTotal': receivablesTotal,
      'liabilitiesTotal': liabilitiesTotal,
      'netZakatableAmount': netZakatableAmount,
      'zakatDue': zakatDue,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ZakatRecordModel.fromJson(Map<String, dynamic> json) {
    return ZakatRecordModel(
      id: json['id'],
      calculationDate: DateTime.parse(json['calculationDate']),
      assetsTotal: (json['assetsTotal'] as num).toDouble(),
      receivablesTotal: (json['receivablesTotal'] as num).toDouble(),
      liabilitiesTotal: (json['liabilitiesTotal'] as num).toDouble(),
      netZakatableAmount: (json['netZakatableAmount'] as num).toDouble(),
      zakatDue: (json['zakatDue'] as num).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ZakatRecordModel copyWith({
    String? id,
    DateTime? calculationDate,
    double? assetsTotal,
    double? receivablesTotal,
    double? liabilitiesTotal,
    double? netZakatableAmount,
    double? zakatDue,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZakatRecordModel(
      id: id ?? this.id,
      calculationDate: calculationDate ?? this.calculationDate,
      assetsTotal: assetsTotal ?? this.assetsTotal,
      receivablesTotal: receivablesTotal ?? this.receivablesTotal,
      liabilitiesTotal: liabilitiesTotal ?? this.liabilitiesTotal,
      netZakatableAmount: netZakatableAmount ?? this.netZakatableAmount,
      zakatDue: zakatDue ?? this.zakatDue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

