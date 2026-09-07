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
    
    final personnel = importData.personnel;
    
    // CFS section supports both { rank: <single person> } and
    // { rank: [<person>, ...] } so the app can hold multiple CFS officers of
    // different ranks (MAJ, LTC, COL, etc.) under the single "CFS" title.
    if (personnel.containsKey('CFS')) {
      final cfsMap = personnel['CFS'] as Map<String, dynamic>;
      for (final entry in cfsMap.entries) {
        await _importRankedPersonnel(entry.key, entry.value, PersonnelType.cfs);
      }
    }
    
    if (personnel.containsKey('Firefighters')) {
      final ffMap = personnel['Firefighters'] as Map<String, dynamic>;
      for (final entry in ffMap.entries) {
        await _importRankedPersonnel(entry.key, entry.value, PersonnelType.firefighter);
      }
    }
    
    if (personnel.containsKey('Alpha')) {
      final alphaMap = personnel['Alpha'] as Map<String, dynamic>;
      for (final entry in alphaMap.entries) {
        await _importRankedPersonnel(entry.key, entry.value, PersonnelType.alpha);
      }
    }
  }
  
  Future<void> _importRankedPersonnel(
    String rankAbbreviation,
    dynamic rankValue,
    PersonnelType type,
  ) async {
    if (rankValue is List) {
      for (final item in rankValue) {
        if (item is Map) {
          await _saveImportedPerson(rankAbbreviation, item as Map<String, dynamic>, type);
        }
      }
    } else if (rankValue is Map) {
      await _saveImportedPerson(rankAbbreviation, rankValue as Map<String, dynamic>, type);
    }
  }
  
  Future<void> _saveImportedPerson(
    String rankAbbreviation,
    Map<String, dynamic> personData,
    PersonnelType type,
  ) async {
    final name = personData['name'];
    if (name is! String || name.trim().isEmpty) {
      return;
    }
    
    final rawHp = personData['hp'] as String?;
    final personnel = Personnel(
      rankAbbreviation: rankAbbreviation,
      name: name,
      fullRank: (personData['full_rank'] as String?) ?? rankAbbreviation,
      hp: rawHp?.trim().isEmpty == true ? null : rawHp,
      type: type,
    );
    await _personnelBox.put(personnel.id, personnel);
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
    final cfsPersonnel = getPersonnelByType(PersonnelType.cfs);
    return cfsPersonnel.isEmpty ? null : cfsPersonnel.first;
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