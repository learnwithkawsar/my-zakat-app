import 'package:hive/hive.dart';

part 'snapshot_model.g.dart';

@HiveType(typeId: 7)
class SnapshotModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String year;

  @HiveField(2)
  String label;

  @HiveField(3)
  Map<String, dynamic> summaryJson;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  SnapshotModel({
    required this.id,
    required this.year,
    required this.label,
    required this.summaryJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'label': label,
      'summaryJson': summaryJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SnapshotModel.fromJson(Map<String, dynamic> json) {
    return SnapshotModel(
      id: json['id'],
      year: json['year'],
      label: json['label'],
      summaryJson: Map<String, dynamic>.from(json['summaryJson']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  SnapshotModel copyWith({
    String? id,
    String? year,
    String? label,
    Map<String, dynamic>? summaryJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SnapshotModel(
      id: id ?? this.id,
      year: year ?? this.year,
      label: label ?? this.label,
      summaryJson: summaryJson ?? this.summaryJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

