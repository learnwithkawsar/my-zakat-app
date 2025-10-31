// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liability_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiabilityModelAdapter extends TypeAdapter<LiabilityModel> {
  @override
  final int typeId = 4;

  @override
  LiabilityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiabilityModel(
      id: fields[0] as String,
      creditorName: fields[1] as String,
      description: fields[2] as String?,
      amount: fields[3] as double,
      currency: fields[4] as String,
      dueDate: fields[5] as DateTime?,
      type: fields[6] as LiabilityType,
      includeInZakat: fields[7] as bool,
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LiabilityModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditorName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.includeInZakat)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiabilityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
