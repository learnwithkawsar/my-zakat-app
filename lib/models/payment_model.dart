import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 2)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String loanId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? paymentType;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.date,
    this.paymentType,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanId': loanId,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentType': paymentType,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      loanId: json['loanId'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      paymentType: json['paymentType'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  PaymentModel copyWith({
    String? id,
    String? loanId,
    double? amount,
    DateTime? date,
    String? paymentType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentType: paymentType ?? this.paymentType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

