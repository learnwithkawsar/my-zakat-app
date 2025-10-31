// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnapshotModelAdapter extends TypeAdapter<SnapshotModel> {
  @override
  final int typeId = 7;

  @override
  SnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SnapshotModel(
      id: fields[0] as String,
      year: fields[1] as String,
      label: fields[2] as String,
      summaryJson: (fields[3] as Map).cast<String, dynamic>(),
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SnapshotModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.summaryJson)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
