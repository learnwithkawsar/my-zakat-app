import 'package:hive/hive.dart';

part 'loan_model.g.dart';

enum LoanStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  closed,
}

@HiveType(typeId: 1)
class LoanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String borrowerId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime transactionDate;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String currency;

  @HiveField(6)
  LoanStatus status;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool includeInZakat;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  LoanModel({
    required this.id,
    required this.borrowerId,
    required this.amount,
    required this.transactionDate,
    this.dueDate,
    required this.currency,
    this.status = LoanStatus.active,
    this.notes,
    this.includeInZakat = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'borrowerId': borrowerId,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'currency': currency,
      'status': status.name,
      'notes': notes,
      'includeInZakat': includeInZakat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      borrowerId: json['borrowerId'],
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      currency: json['currency'],
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.active,
      ),
      notes: json['notes'],
      includeInZakat: json['includeInZakat'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  LoanModel copyWith({
    String? id,
    String? borrowerId,
    double? amount,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? currency,
    LoanStatus? status,
    String? notes,
    bool? includeInZakat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      borrowerId: borrowerId ?? this.borrowerId,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      includeInZakat: includeInZakat ?? this.includeInZakat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

