import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 8)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String currency;

  @HiveField(1)
  double zakatRate;

  @HiveField(2)
  double nisab;

  @HiveField(3)
  DateTime? reminderDate;

  @HiveField(4)
  bool useBiometric;

  @HiveField(5)
  int autoLockTimeoutMinutes;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  double goldPricePerGram;

  @HiveField(8)
  double silverPricePerGram;

  SettingsModel({
    this.currency = 'BDT',
    this.zakatRate = 2.5,
    this.nisab = 0.0,
    this.reminderDate,
    this.useBiometric = false,
    this.autoLockTimeoutMinutes = 5,
    this.goldPricePerGram = 0.0,
    this.silverPricePerGram = 0.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'zakatRate': zakatRate,
      'nisab': nisab,
      'reminderDate': reminderDate?.toIso8601String(),
      'useBiometric': useBiometric,
      'autoLockTimeoutMinutes': autoLockTimeoutMinutes,
      'goldPricePerGram': goldPricePerGram,
      'silverPricePerGram': silverPricePerGram,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currency: json['currency'] ?? 'BDT',
      zakatRate: (json['zakatRate'] as num?)?.toDouble() ?? 2.5,
      nisab: (json['nisab'] as num?)?.toDouble() ?? 0.0,
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'])
          : null,
      useBiometric: json['useBiometric'] ?? false,
      autoLockTimeoutMinutes: json['autoLockTimeoutMinutes'] ?? 5,
      goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble() ?? 0.0,
      silverPricePerGram: (json['silverPricePerGram'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  SettingsModel copyWith({
    String? currency,
    double? zakatRate,
    double? nisab,
    DateTime? reminderDate,
    bool? useBiometric,
    int? autoLockTimeoutMinutes,
    double? goldPricePerGram,
    double? silverPricePerGram,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      currency: currency ?? this.currency,
      zakatRate: zakatRate ?? this.zakatRate,
      nisab: nisab ?? this.nisab,
      reminderDate: reminderDate ?? this.reminderDate,
      useBiometric: useBiometric ?? this.useBiometric,
      autoLockTimeoutMinutes: autoLockTimeoutMinutes ?? this.autoLockTimeoutMinutes,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

