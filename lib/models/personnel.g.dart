// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonnelAdapter extends TypeAdapter<Personnel> {
  @override
  final typeId = 0;

  @override
  Personnel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Personnel(
      rankAbbreviation: fields[0] as String,
      name: fields[1] as String,
      fullRank: fields[2] as String,
      hp: fields[3] as String?,
      type: fields[4] as PersonnelType,
      id: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Personnel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.rankAbbreviation)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullRank)
      ..writeByte(3)
      ..write(obj.hp)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
