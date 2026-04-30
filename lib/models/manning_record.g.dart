// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manning_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ManningRecordAdapter extends TypeAdapter<ManningRecord> {
  @override
  final typeId = 3;

  @override
  ManningRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManningRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      rota: (fields[2] as num).toInt(),
      organization: fields[3] as String,
      appliances: (fields[4] as Map).map(
        (dynamic k, dynamic v) =>
            MapEntry(k as String, (v as List).cast<Position>()),
      ),
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ManningRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.rota)
      ..writeByte(3)
      ..write(obj.organization)
      ..writeByte(4)
      ..write(obj.appliances)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManningRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
