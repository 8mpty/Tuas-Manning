import 'package:hive_ce/hive.dart';

part 'personnel_type.g.dart';

@HiveType(typeId: 4)
enum PersonnelType {
  @HiveField(0)
  cfs('CFS'),
  
  @HiveField(1)
  firefighter('Firefighters'),
  
  @HiveField(2)
  alpha('Alpha');

  final String jsonKey;
  const PersonnelType(this.jsonKey);
  
  @override
  String toString() => jsonKey;
  
  static PersonnelType fromString(String type) {
    switch (type) {
      case 'CFS':
        return PersonnelType.cfs;
      case 'Firefighters':
        return PersonnelType.firefighter;
      case 'Alpha':
        return PersonnelType.alpha;
      default:
        return PersonnelType.firefighter;
    }
  }
}