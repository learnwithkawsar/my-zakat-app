// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeneficiaryModelAdapter extends TypeAdapter<BeneficiaryModel> {
  @override
  final int typeId = 5;

  @override
  BeneficiaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BeneficiaryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      contactInfo: fields[2] as String?,
      percentageShare: fields[3] as double?,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BeneficiaryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactInfo)
      ..writeByte(3)
      ..write(obj.percentageShare)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeneficiaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
