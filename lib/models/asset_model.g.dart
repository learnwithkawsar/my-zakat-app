// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetModelAdapter extends TypeAdapter<AssetModel> {
  @override
  final int typeId = 3;

  @override
  AssetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as AssetType,
      value: fields[3] as double,
      currency: fields[4] as String,
      valuationDate: fields[5] as DateTime,
      notes: fields[6] as String?,
      weightInGrams: fields[9] as double?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssetModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.valuationDate)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.weightInGrams)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssetTypeAdapter extends TypeAdapter<AssetType> {
  @override
  final int typeId = 9;

  @override
  AssetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AssetType.cash;
      case 1:
        return AssetType.bank;
      case 2:
        return AssetType.gold;
      case 3:
        return AssetType.silver;
      case 4:
        return AssetType.investment;
      case 5:
        return AssetType.property;
      case 6:
        return AssetType.business;
      case 7:
        return AssetType.other;
      default:
        return AssetType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, AssetType obj) {
    switch (obj) {
      case AssetType.cash:
        writer.writeByte(0);
        break;
      case AssetType.bank:
        writer.writeByte(1);
        break;
      case AssetType.gold:
        writer.writeByte(2);
        break;
      case AssetType.silver:
        writer.writeByte(3);
        break;
      case AssetType.investment:
        writer.writeByte(4);
        break;
      case AssetType.property:
        writer.writeByte(5);
        break;
      case AssetType.business:
        writer.writeByte(6);
        break;
      case AssetType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
