import 'package:hive_ce/hive.dart';
import 'package:tuas_manning_2/models/appliance.dart';

part 'manning_record.g.dart';

@HiveType(typeId: 3)
class ManningRecord {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final int rota;
  
  @HiveField(3)
  final String organization;
  
  @HiveField(4)
  final Map<String, List<Position>> appliances;
  
  @HiveField(5)
  final DateTime createdAt;
  
  ManningRecord({
    required this.id,
    required this.date,
    required this.rota,
    required this.organization,
    required this.appliances,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  ManningRecord copyWith({
    String? id,
    DateTime? date,
    int? rota,
    String? organization,
    Map<String, List<Position>>? appliances,
    DateTime? createdAt,
  }) {
    return ManningRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      rota: rota ?? this.rota,
      organization: organization ?? this.organization,
      appliances: appliances ?? this.appliances,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}