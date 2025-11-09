// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 8;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      currency: fields[0] as String,
      zakatRate: fields[1] as double,
      nisab: fields[2] as double,
      reminderDate: fields[3] as DateTime?,
      useBiometric: fields[4] as bool,
      autoLockTimeoutMinutes: fields[5] as int,
      goldPricePerGram: (fields[7] as double?) ?? 0.0,
      silverPricePerGram: (fields[8] as double?) ?? 0.0,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.zakatRate)
      ..writeByte(2)
      ..write(obj.nisab)
      ..writeByte(3)
      ..write(obj.reminderDate)
      ..writeByte(4)
      ..write(obj.useBiometric)
      ..writeByte(5)
      ..write(obj.autoLockTimeoutMinutes)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.goldPricePerGram)
      ..writeByte(8)
      ..write(obj.silverPricePerGram);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
