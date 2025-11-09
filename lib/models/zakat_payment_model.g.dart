// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZakatPaymentModelAdapter extends TypeAdapter<ZakatPaymentModel> {
  @override
  final int typeId = 11;

  @override
  ZakatPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZakatPaymentModel(
      id: fields[0] as String,
      zakatRecordId: fields[1] as String,
      beneficiaryId: fields[2] as String,
      amount: fields[3] as double,
      paymentDate: fields[4] as DateTime,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ZakatPaymentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.zakatRecordId)
      ..writeByte(2)
      ..write(obj.beneficiaryId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paymentDate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZakatPaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
