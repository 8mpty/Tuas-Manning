// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonnelTypeAdapter extends TypeAdapter<PersonnelType> {
  @override
  final typeId = 4;

  @override
  PersonnelType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PersonnelType.cfs;
      case 1:
        return PersonnelType.firefighter;
      case 2:
        return PersonnelType.alpha;
      default:
        return PersonnelType.cfs;
    }
  }

  @override
  void write(BinaryWriter writer, PersonnelType obj) {
    switch (obj) {
      case PersonnelType.cfs:
        writer.writeByte(0);
      case PersonnelType.firefighter:
        writer.writeByte(1);
      case PersonnelType.alpha:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
