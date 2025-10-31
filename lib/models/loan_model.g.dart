// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 1;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      id: fields[0] as String,
      borrowerId: fields[1] as String,
      amount: fields[2] as double,
      transactionDate: fields[3] as DateTime,
      dueDate: fields[4] as DateTime?,
      currency: fields[5] as String,
      status: fields[6] as LoanStatus,
      notes: fields[7] as String?,
      includeInZakat: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.borrowerId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.transactionDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.includeInZakat)
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
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
