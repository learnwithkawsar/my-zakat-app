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
      zakatYearStart: fields[2] as DateTime,
      zakatYearEnd: fields[3] as DateTime,
      assetsTotal: fields[4] as double,
      receivablesTotal: fields[5] as double,
      liabilitiesTotal: fields[6] as double,
      netZakatableAmount: fields[7] as double,
      zakatDue: fields[8] as double,
      amountPaid: fields[9] as double,
      isCurrent: fields[10] as bool,
      notes: fields[11] as String?,
      name: fields[14] as String,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ZakatRecordModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.calculationDate)
      ..writeByte(2)
      ..write(obj.zakatYearStart)
      ..writeByte(3)
      ..write(obj.zakatYearEnd)
      ..writeByte(4)
      ..write(obj.assetsTotal)
      ..writeByte(5)
      ..write(obj.receivablesTotal)
      ..writeByte(6)
      ..write(obj.liabilitiesTotal)
      ..writeByte(7)
      ..write(obj.netZakatableAmount)
      ..writeByte(8)
      ..write(obj.zakatDue)
      ..writeByte(9)
      ..write(obj.amountPaid)
      ..writeByte(10)
      ..write(obj.isCurrent)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
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
