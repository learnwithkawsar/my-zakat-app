import 'package:hive/hive.dart';

part 'zakat_record_model.g.dart';

@HiveType(typeId: 6)
class ZakatRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime calculationDate;

  @HiveField(2)
  DateTime zakatYearStart; // Start of zakat year (e.g., 1/1/2025)

  @HiveField(3)
  DateTime zakatYearEnd; // End of zakat year (e.g., 31/12/2025)

  @HiveField(4)
  double assetsTotal;

  @HiveField(5)
  double receivablesTotal;

  @HiveField(6)
  double liabilitiesTotal;

  @HiveField(7)
  double netZakatableAmount;

  @HiveField(8)
  double zakatDue;

  @HiveField(9)
  double amountPaid; // Total amount paid for this zakat year

  @HiveField(10)
  bool isCurrent; // Whether this is the current zakat year

  @HiveField(11)
  String? notes;

  @HiveField(14) // New field, using 14 to avoid conflicts
  String name; // Name of the zakat year (e.g., "2025 Zakat Year", "Hijri 1446")

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  ZakatRecordModel({
    required this.id,
    required this.calculationDate,
    required this.zakatYearStart,
    required this.zakatYearEnd,
    required this.assetsTotal,
    required this.receivablesTotal,
    required this.liabilitiesTotal,
    required this.netZakatableAmount,
    required this.zakatDue,
    this.amountPaid = 0.0,
    this.isCurrent = false,
    this.notes,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get the balance (zakatDue - amountPaid)
  double get balance => zakatDue - amountPaid;

  /// Check if zakat is fully paid
  bool get isFullyPaid => balance <= 0;

  /// Get zakat year as string (returns name if available, otherwise year)
  String get zakatYear => name.isNotEmpty ? name : zakatYearStart.year.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculationDate': calculationDate.toIso8601String(),
      'zakatYearStart': zakatYearStart.toIso8601String(),
      'zakatYearEnd': zakatYearEnd.toIso8601String(),
      'assetsTotal': assetsTotal,
      'receivablesTotal': receivablesTotal,
      'liabilitiesTotal': liabilitiesTotal,
      'netZakatableAmount': netZakatableAmount,
      'zakatDue': zakatDue,
      'amountPaid': amountPaid,
      'isCurrent': isCurrent,
      'notes': notes,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ZakatRecordModel.fromJson(Map<String, dynamic> json) {
    return ZakatRecordModel(
      id: json['id'],
      calculationDate: DateTime.parse(json['calculationDate']),
      zakatYearStart: DateTime.parse(json['zakatYearStart']),
      zakatYearEnd: DateTime.parse(json['zakatYearEnd']),
      assetsTotal: (json['assetsTotal'] as num).toDouble(),
      receivablesTotal: (json['receivablesTotal'] as num).toDouble(),
      liabilitiesTotal: (json['liabilitiesTotal'] as num).toDouble(),
      netZakatableAmount: (json['netZakatableAmount'] as num).toDouble(),
      zakatDue: (json['zakatDue'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      isCurrent: json['isCurrent'] ?? false,
      notes: json['notes'],
      name: json['name'] ?? json['zakatYearStart']?.toString().substring(0, 4) ?? 'Zakat Year',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ZakatRecordModel copyWith({
    String? id,
    DateTime? calculationDate,
    DateTime? zakatYearStart,
    DateTime? zakatYearEnd,
    double? assetsTotal,
    double? receivablesTotal,
    double? liabilitiesTotal,
    double? netZakatableAmount,
    double? zakatDue,
    double? amountPaid,
    bool? isCurrent,
    String? notes,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZakatRecordModel(
      id: id ?? this.id,
      calculationDate: calculationDate ?? this.calculationDate,
      zakatYearStart: zakatYearStart ?? this.zakatYearStart,
      zakatYearEnd: zakatYearEnd ?? this.zakatYearEnd,
      assetsTotal: assetsTotal ?? this.assetsTotal,
      receivablesTotal: receivablesTotal ?? this.receivablesTotal,
      liabilitiesTotal: liabilitiesTotal ?? this.liabilitiesTotal,
      netZakatableAmount: netZakatableAmount ?? this.netZakatableAmount,
      zakatDue: zakatDue ?? this.zakatDue,
      amountPaid: amountPaid ?? this.amountPaid,
      isCurrent: isCurrent ?? this.isCurrent,
      notes: notes ?? this.notes,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

