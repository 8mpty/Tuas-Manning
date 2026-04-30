import 'package:hive_ce/hive.dart';
import 'package:tuas_manning_2/models/personnel.dart';
import 'package:tuas_manning_2/models/manning_record.dart';
import 'package:tuas_manning_2/models/json_import_model.dart';
import 'package:tuas_manning_2/models/personnel_type.dart';

class DatabaseService {
  static const String personnelBox = 'personnel';
  static const String recordsBox = 'manning_records';
  static const String configBox = 'config';
  
  late Box<Personnel> _personnelBox;
  late Box<ManningRecord> _recordsBox;
  late Box _configBox;
  
  Future<void> init() async {
    _personnelBox = await Hive.openBox<Personnel>(personnelBox);
    _recordsBox = await Hive.openBox<ManningRecord>(recordsBox);
    _configBox = await Hive.openBox(configBox);
  }
  
  Future<void> importJson(Map<String, dynamic> json) async {
    final importData = JsonImportData.fromJson(json);
    
    await _personnelBox.clear();
    
    _configBox.put('rota', importData.rota);
    _configBox.put('organization', importData.organization);
    _configBox.put('lastImport', DateTime.now());
    
    if (importData.personnel.containsKey('CFS')) {
      final cfsMap = importData.personnel['CFS'] as Map<String, dynamic>;
      for (final entry in cfsMap.entries) {
        final personData = entry.value as Map<String, dynamic>;
        final hp = personData['hp'] as String?;
        final personnel = Personnel(
          rankAbbreviation: entry.key,
          name: personData['name'] as String,
          fullRank: personData['full_rank'] as String,
          hp: hp?.trim().isEmpty == true ? null : hp,
          type: PersonnelType.cfs,
        );
        await _personnelBox.put(personnel.id, personnel);
      }
    }
    
    if (importData.personnel.containsKey('Firefighters')) {
      final ffMap = importData.personnel['Firefighters'] as Map<String, dynamic>;
      for (final rankEntry in ffMap.entries) {
        final rankList = rankEntry.value as List<dynamic>;
        for (final personData in rankList) {
          final personMap = personData as Map<String, dynamic>;
          final hp = personMap['hp'] as String?;
          final personnel = Personnel(
            rankAbbreviation: rankEntry.key,
            name: personMap['name'] as String,
            fullRank: personMap['full_rank'] as String,
            hp: hp?.trim().isEmpty == true ? null : hp,
            type: PersonnelType.firefighter,
          );
          await _personnelBox.put(personnel.id, personnel);
        }
      }
    }
    
    if (importData.personnel.containsKey('Alpha')) {
      final alphaMap = importData.personnel['Alpha'] as Map<String, dynamic>;
      for (final rankEntry in alphaMap.entries) {
        final rankList = rankEntry.value as List<dynamic>;
        for (final personData in rankList) {
          final personMap = personData as Map<String, dynamic>;
          final hp = personMap['hp'] as String?;
          final personnel = Personnel(
            rankAbbreviation: rankEntry.key,
            name: personMap['name'] as String,
            fullRank: personMap['full_rank'] as String,
            hp: hp?.trim().isEmpty == true ? null : hp,
            type: PersonnelType.alpha,
          );
          await _personnelBox.put(personnel.id, personnel);
        }
      }
    }
  }
  
  List<Personnel> getAllPersonnel() {
    return _personnelBox.values.toList()..sort(Personnel.compareByRank);
  }
  
  List<Personnel> getPersonnelByType(PersonnelType type) {
    return _personnelBox.values
        .where((person) => person.type == type)
        .toList()
        ..sort(Personnel.compareByRank);
  }
  
  List<Personnel> getPersonnelForPosition(String applianceCode, String role) {
    if (applianceCode == 'A421') {
      return getPersonnelByType(PersonnelType.alpha);
    }
    
    if (applianceCode == 'IV421' && role == 'CFS') {
      return getPersonnelByType(PersonnelType.cfs);
    }
    
    return getPersonnelByType(PersonnelType.firefighter);
  }
  
  Personnel? getCFSPersonnel() {
    try {
      return _personnelBox.values
          .firstWhere((person) => person.type == PersonnelType.cfs);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> savePersonnel(Personnel personnel) async {
    await _personnelBox.put(personnel.id, personnel);
  }
  
  Future<void> deletePersonnel(String id) async {
    await _personnelBox.delete(id);
  }
  
  Future<void> saveManningRecord(ManningRecord record) async {
    await _recordsBox.put(record.id, record);
  }
  
  List<ManningRecord> getAllRecords() {
    return _recordsBox.values.toList();
  }
  
  ManningRecord? getRecord(String id) {
    return _recordsBox.get(id);
  }

  Future<void> deleteRecord(String id) async {
    await _recordsBox.delete(id);
  }
  
  Map<String, dynamic> getConfig() {
    return {
      'rota': _configBox.get('rota', defaultValue: 0) as int,
      'organization': _configBox.get('organization', defaultValue: '') as String,
      'lastImport': _configBox.get('lastImport') as DateTime?,
    };
  }
  
  bool hasData() {
    return _configBox.containsKey('rota') && _personnelBox.isNotEmpty;
  }
  
  void cleanupDuplicates() {
    final allPersonnel = _personnelBox.values.toList();
    final uniquePersonnel = <String, Personnel>{};
    
    for (final person in allPersonnel) {
      uniquePersonnel[person.id] = person;
    }
    
    if (uniquePersonnel.length != allPersonnel.length) {
      _personnelBox.clear();
      for (final person in uniquePersonnel.values) {
        _personnelBox.put(person.id, person);
      }
    }
  }
}