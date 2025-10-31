// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrower_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BorrowerModelAdapter extends TypeAdapter<BorrowerModel> {
  @override
  final int typeId = 0;

  @override
  BorrowerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BorrowerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      contactInfo: fields[2] as String?,
      address: fields[3] as String?,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BorrowerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactInfo)
      ..writeByte(3)
      ..write(obj.address)
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
      other is BorrowerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
