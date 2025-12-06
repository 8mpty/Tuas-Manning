import 'package:hive_ce/hive.dart';
import 'personnel.dart';
import 'personnel_type.dart';

part 'appliance.g.dart';

@HiveType(typeId: 1)
class Appliance {
  @HiveField(0)
  final String code;
  
  @HiveField(1)
  final String? vehicleNumber;
  
  @HiveField(2)
  final List<Position> positions;
  
  @HiveField(3)
  final String? autoAssignFrom;
  
  Appliance({
    required this.code,
    this.vehicleNumber,
    required this.positions,
    this.autoAssignFrom,
  });
}

@HiveType(typeId: 2)
class Position {
  @HiveField(0)
  final String role;
  
  @HiveField(1)
  Personnel? personnel;
  
  @HiveField(2)
  final bool isAutoAssigned;
  
  @HiveField(3)
  final String? autoAssignRole;
  
  @HiveField(4)
  final String? autoAssignAppliance;
  
  @HiveField(5)
  final PersonnelType personnelType;
  
  Position({
    required this.role,
    this.personnel,
    this.isAutoAssigned = false,
    this.autoAssignRole,
    this.autoAssignAppliance,
    required this.personnelType,
  });
}