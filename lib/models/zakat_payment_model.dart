import 'package:hive/hive.dart';

part 'zakat_payment_model.g.dart';

@HiveType(typeId: 11)
class ZakatPaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String zakatRecordId; // Reference to ZakatRecordModel

  @HiveField(2)
  final String beneficiaryId; // Reference to BeneficiaryModel

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime paymentDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  ZakatPaymentModel({
    required this.id,
    required this.zakatRecordId,
    required this.beneficiaryId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zakatRecordId': zakatRecordId,
      'beneficiaryId': beneficiaryId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ZakatPaymentModel.fromJson(Map<String, dynamic> json) {
    return ZakatPaymentModel(
      id: json['id'],
      zakatRecordId: json['zakatRecordId'],
      beneficiaryId: json['beneficiaryId'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ZakatPaymentModel copyWith({
    String? id,
    String? zakatRecordId,
    String? beneficiaryId,
    double? amount,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZakatPaymentModel(
      id: id ?? this.id,
      zakatRecordId: zakatRecordId ?? this.zakatRecordId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

