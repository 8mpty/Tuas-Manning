// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplianceAdapter extends TypeAdapter<Appliance> {
  @override
  final typeId = 1;

  @override
  Appliance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appliance(
      code: fields[0] as String,
      vehicleNumber: fields[1] as String?,
      positions: (fields[2] as List).cast<Position>(),
      autoAssignFrom: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Appliance obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.vehicleNumber)
      ..writeByte(2)
      ..write(obj.positions)
      ..writeByte(3)
      ..write(obj.autoAssignFrom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplianceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PositionAdapter extends TypeAdapter<Position> {
  @override
  final typeId = 2;

  @override
  Position read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Position(
      role: fields[0] as String,
      personnel: fields[1] as Personnel?,
      isAutoAssigned: fields[2] == null ? false : fields[2] as bool,
      autoAssignRole: fields[3] as String?,
      autoAssignAppliance: fields[4] as String?,
      personnelType: fields[5] as PersonnelType,
    );
  }

  @override
  void write(BinaryWriter writer, Position obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.personnel)
      ..writeByte(2)
      ..write(obj.isAutoAssigned)
      ..writeByte(3)
      ..write(obj.autoAssignRole)
      ..writeByte(4)
      ..write(obj.autoAssignAppliance)
      ..writeByte(5)
      ..write(obj.personnelType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
