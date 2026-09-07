import 'package:hive_ce/hive.dart';

part 'rank.g.dart';

@HiveType(typeId: 5)
enum Rank {
  @HiveField(0)
  cfs(100, 'CFS'),
  
  @HiveField(1)
  maj(90, 'MAJ'),
  
  @HiveField(2)
  lta(80, 'LTA'),
  
  @HiveField(3)
  wo2(70, 'WO2'),
  
  @HiveField(4)
  wo1(60, 'WO1'), 
  
  @HiveField(5)
  ssg(50, 'SSG'),
  
  @HiveField(6)
  sgt(40, 'SGT'),
  
  @HiveField(7)
  sgt3(30, 'SGT3'),
  
  @HiveField(8)
  sgt2(20, 'SGT2'),
  
  @HiveField(9)
  sgt1(10, 'SGT1'),
  
  @HiveField(10)
  cpl(0, 'CPL'),
  
  @HiveField(11)
  lcpl(-10, 'LCPL'),
  
  @HiveField(12)
  pte(-20, 'PTE'),
  
  @HiveField(13)
  cp(-30, 'CP'),
  
  @HiveField(14)
  unknown(-100, ''),
  
  @HiveField(15)
  cpt(85, 'CPT'),
  
  @HiveField(16)
  ltc(92, 'LTC'),
  
  @HiveField(17)
  col(95, 'COL');

  final int priority;
  final String abbreviation;
  const Rank(this.priority, this.abbreviation);
  
  static Rank fromAbbreviation(String abbreviation) {
    final abbr = abbreviation.toUpperCase();
    
    if (abbr == 'LCP') return lcpl;
    if (abbr == 'CPL') return cpl;
    if (abbr == 'PTE') return pte;
    if (abbr == 'CP') return cp;
    if (abbr == 'SGT') return sgt;
    if (abbr == 'SSG') return ssg;
    if (abbr == 'WO1') return wo1;
    if (abbr == 'WO2') return wo2;
    if (abbr == 'LTA') return lta;
    if (abbr == 'MAJ') return maj;
    if (abbr == 'CFS') return cfs;
    if (abbr == 'CPT') return cpt;
    if (abbr == 'LTC') return ltc;
    if (abbr == 'COL') return col;
    if (abbr == 'SGT3' || abbr == 'SGT 3') return sgt3;
    if (abbr == 'SGT2' || abbr == 'SGT 2') return sgt2;
    if (abbr == 'SGT1' || abbr == 'SGT 1') return sgt1;
    
    for (var rank in Rank.values) {
      if (rank.abbreviation == abbr) {
        return rank;
      }
    }
    return unknown;
  }
  
  @override
  String toString() => abbreviation;
}