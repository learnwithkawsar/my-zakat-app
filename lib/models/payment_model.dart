import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 2)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? loanId; // Optional - null if payment is for borrower (all loans)

  @HiveField(2)
  String borrowerId; // Required - always track which borrower

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? paymentType;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  PaymentModel({
    required this.id,
    this.loanId, // Optional - null means payment for all borrower's loans
    required this.borrowerId,
    required this.amount,
    required this.date,
    this.paymentType,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Check if payment is for a specific loan
  bool get isForSpecificLoan => loanId != null;

  /// Check if payment is for all borrower's loans
  bool get isForAllLoans => loanId == null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanId': loanId,
      'borrowerId': borrowerId,
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
      borrowerId: json['borrowerId'],
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
    String? borrowerId,
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
      borrowerId: borrowerId ?? this.borrowerId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentType: paymentType ?? this.paymentType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

