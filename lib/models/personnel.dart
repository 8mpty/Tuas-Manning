import 'package:hive_ce/hive.dart';
import 'rank.dart';
import 'personnel_type.dart';

part 'personnel.g.dart';

@HiveType(typeId: 0)
class Personnel {
  @HiveField(0)
  final String rankAbbreviation;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String fullRank;
  
  @HiveField(3)
  final String? hp;
  
  @HiveField(4)
  final PersonnelType type;
  
  @HiveField(5)
  final String id;
  
  Rank get rank => Rank.fromAbbreviation(rankAbbreviation);
  
  Personnel({
    required this.rankAbbreviation,
    required this.name,
    required this.fullRank,
    this.hp,
    required this.type,
    String? id,
  }) : id = id ?? '${rankAbbreviation}_${name}_${type.name}';
  
  String get displayName {
    final hpText = hp?.trim().isNotEmpty == true ? hp : 'NONE';
    return '$rankAbbreviation $name (HP: $hpText)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Personnel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return displayName;
  }
  
  static int compareByRank(Personnel a, Personnel b) {
    final rankCompare = b.rank.priority.compareTo(a.rank.priority);
    if (rankCompare != 0) return rankCompare;
    
    return a.name.compareTo(b.name);
  }
}