// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZakatRecordModelAdapter extends TypeAdapter<ZakatRecordModel> {
  @override
  final int typeId = 6;

  @override
  ZakatRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZakatRecordModel(
      id: fields[0] as String,
      calculationDate: fields[1] as DateTime,
      assetsTotal: fields[2] as double,
      receivablesTotal: fields[3] as double,
      liabilitiesTotal: fields[4] as double,
      netZakatableAmount: fields[5] as double,
      zakatDue: fields[6] as double,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ZakatRecordModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.calculationDate)
      ..writeByte(2)
      ..write(obj.assetsTotal)
      ..writeByte(3)
      ..write(obj.receivablesTotal)
      ..writeByte(4)
      ..write(obj.liabilitiesTotal)
      ..writeByte(5)
      ..write(obj.netZakatableAmount)
      ..writeByte(6)
      ..write(obj.zakatDue)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZakatRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
