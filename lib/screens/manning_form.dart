import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuas_manning_2/models/appliance.dart';
import 'package:tuas_manning_2/models/manning_record.dart';
import 'package:tuas_manning_2/models/personnel.dart';
import 'package:tuas_manning_2/services/database_service.dart';
import 'package:tuas_manning_2/data/appliance_definitions.dart';
import 'package:tuas_manning_2/models/personnel_type.dart';

class ManningFormScreen extends StatefulWidget {
  final ManningRecord? existingRecord;
  
  const ManningFormScreen({super.key, this.existingRecord});
  
  @override
  State<ManningFormScreen> createState() => _ManningFormScreenState();
}

class _ManningFormScreenState extends State<ManningFormScreen> {
  late List<Appliance> _appliances;
  late Map<String, List<Position>> _appliancePositions;
  late DatabaseService _dbService;
  List<Personnel> _allPersonnel = [];
  Personnel? _defaultCfsPersonnel;
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();
  final Set<String> _manuallyOverriddenPositions = <String>{};
  
  @override
  void initState() {
    super.initState();
    _dbService = context.read<DatabaseService>();
    _initializeData();
    _selectedDate = widget.existingRecord?.date ?? DateTime.now();
  }
  
  String _positionKey(String applianceCode, String role) => '$applianceCode|$role';
  
  void _initializeData() {
    _dbService.cleanupDuplicates();
    _appliances = ApplianceDefinitions.getAppliances();
    _allPersonnel = _dbService.getAllPersonnel();
    _defaultCfsPersonnel = _dbService.getCFSPersonnel();
    
    if (widget.existingRecord != null) {
      _appliancePositions = widget.existingRecord!.appliances;
      _reLinkPersonnelObjects();
      _detectManualOverrides();
    } else {
      _appliancePositions = {};
      for (var appliance in _appliances) {
        _appliancePositions[appliance.code] = List<Position>.from(appliance.positions);
      }
    }
    _applyDefaultAutoAssignments();
  }

  void _detectManualOverrides() {
    for (var applianceEntry in _appliancePositions.entries) {
      for (var position in applianceEntry.value) {
        if (!position.isAutoAssigned) continue;
        if (position.autoAssignAppliance == null || position.autoAssignRole == null) continue;
        
        final sourcePersonnel = _getPersonnelFromAppliance(
          position.autoAssignAppliance!,
          position.autoAssignRole!,
        );
        
        final isSynced = sourcePersonnel != null &&
            position.personnel != null &&
            sourcePersonnel.id == position.personnel!.id;
        final bothEmpty = sourcePersonnel == null && position.personnel == null;
        
        if (!isSynced && !bothEmpty) {
          _manuallyOverriddenPositions.add(_positionKey(applianceEntry.key, position.role));
        }
      }
    }
  }
  
  void _applyDefaultAutoAssignments() {
    final bool isNewManning = widget.existingRecord == null;
    
    for (var applianceEntry in _appliancePositions.entries) {
      for (var position in applianceEntry.value) {
        if (position.isAutoAssigned) {
          final key = _positionKey(applianceEntry.key, position.role);
          if (_manuallyOverriddenPositions.contains(key)) continue;
          if (position.personnel != null) continue;
          if (position.autoAssignAppliance == null || position.autoAssignRole == null) continue;
          
          position.personnel = _getPersonnelFromAppliance(
            position.autoAssignAppliance!,
            position.autoAssignRole!,
          );
          continue;
        }

        if (isNewManning &&
            position.role == 'CFS' &&
            position.personnelType == PersonnelType.cfs &&
            position.personnel == null) {
          position.personnel = _defaultCfsPersonnel;
        }
      }
    }
  }
  
  void _reLinkPersonnelObjects() {
    for (var applianceEntry in _appliancePositions.entries) {
      for (var position in applianceEntry.value) {
        if (position.personnel != null) {
          final currentPersonnel = _findMatchingPersonnel(position.personnel!);
          if (currentPersonnel != null) {
            position.personnel = currentPersonnel;
          }
        }
      }
    }
  }
  
  Personnel? _findMatchingPersonnel(Personnel storedPersonnel) {
    for (var person in _allPersonnel) {
      if (person.id == storedPersonnel.id) {
        return person;
      }
    }
    
    for (var person in _allPersonnel) {
      if (person.name == storedPersonnel.name && 
          person.rankAbbreviation == storedPersonnel.rankAbbreviation &&
          person.type == storedPersonnel.type) {
        return person;
      }
    }
    
    return null;
  }
  
  void _updateAutoAssignedPositions(String sourceApplianceCode, String sourceRole) {
    final sourcePersonnel = _getPersonnelFromAppliance(sourceApplianceCode, sourceRole);
    
    for (var applianceEntry in _appliancePositions.entries) {
      for (var position in applianceEntry.value) {
        if (position.isAutoAssigned &&
            position.autoAssignAppliance == sourceApplianceCode &&
            position.autoAssignRole == sourceRole) {
          
          final key = _positionKey(applianceEntry.key, position.role);
          if (_manuallyOverriddenPositions.contains(key)) continue;
          
          position.personnel = sourcePersonnel;
        }
      }
    }
  }
  
  Personnel? _getPersonnelFromAppliance(String applianceCode, String role) {
    final positions = _appliancePositions[applianceCode];
    if (positions != null) {
      for (var position in positions) {
        if (position.role == role) {
          return position.personnel;
        }
      }
    }
    return null;
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _saveManning() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    
    final config = _dbService.getConfig();
    final recordId = widget.existingRecord?.id ?? 
        '${_selectedDate!.toIso8601String()}_${DateTime.now().millisecondsSinceEpoch}';
    
    final record = ManningRecord(
      id: recordId,
      date: _selectedDate!,
      rota: config['rota'] as int,
      organization: config['organization'] as String,
      appliances: Map<String, List<Position>>.from(_appliancePositions),
    );
    
    await _dbService.saveManningRecord(record);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manning saved successfully!')),
    );
    
    Navigator.pop(context, true);
  }
  
  List<Personnel> _getAvailablePersonnelForPosition(Position position, String applianceCode) {
    List<Personnel> personnelList;
    
    switch (position.personnelType) {
      case PersonnelType.alpha:
        personnelList = _dbService.getPersonnelByType(PersonnelType.alpha);
        break;
      case PersonnelType.cfs:
        personnelList = _dbService.getPersonnelByType(PersonnelType.cfs);
        break;
      case PersonnelType.firefighter:
        personnelList = _dbService.getPersonnelByType(PersonnelType.firefighter);
        break;
    }
    
    final uniquePersonnel = <String, Personnel>{};
    for (var person in personnelList) {
      uniquePersonnel[person.id] = person;
    }
    
    if (position.personnel != null) {
      uniquePersonnel[position.personnel!.id] = position.personnel!;
    }
    
    return uniquePersonnel.values.toList()..sort(Personnel.compareByRank);
  }
  
  Widget _buildPositionDropdown(Position position, String applianceCode) {
    final bool isAutoLinked = position.isAutoAssigned;
    final bool isOverridden = isAutoLinked &&
        _manuallyOverriddenPositions.contains(_positionKey(applianceCode, position.role));
    final availablePersonnel = _getAvailablePersonnelForPosition(position, applianceCode);
    
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            '${position.role}:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (isAutoLinked) ...[
          Tooltip(
            message: isOverridden
                ? 'Manually changed - no longer follows its linked vehicle'
                : 'Auto-assigned from linked vehicle (editable)',
            child: Icon(
              isOverridden ? Icons.edit_outlined : Icons.link,
              size: 15,
              color: isOverridden
                  ? Colors.orangeAccent
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: DropdownButton<Personnel?>(
            value: position.personnel,
            isExpanded: true,
            underline: Container(height: 0),
            items: [
              DropdownMenuItem<Personnel?>(
                value: null,
                child: Text(
                  'NULL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              ...availablePersonnel.map((personnel) {
                return DropdownMenuItem<Personnel?>(
                  value: personnel,
                  child: Text(
                    personnel.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ],
            onChanged: (Personnel? newValue) {
              setState(() {
                position.personnel = newValue;
                
                if (isAutoLinked) {
                  final source = position.autoAssignAppliance != null &&
                          position.autoAssignRole != null
                      ? _getPersonnelFromAppliance(
                          position.autoAssignAppliance!,
                          position.autoAssignRole!,
                        )
                      : null;
                  final sameAsSource = (source == null && newValue == null) ||
                      (source != null && newValue != null && source.id == newValue.id);
                  final key = _positionKey(applianceCode, position.role);
                  if (sameAsSource) {
                    _manuallyOverriddenPositions.remove(key);
                  } else {
                    _manuallyOverriddenPositions.add(key);
                  }
                }
                _updateAutoAssignedPositions(applianceCode, position.role);
              });
            },
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildApplianceCard(Appliance appliance) {
    final positions = _appliancePositions[appliance.code] ?? [];
    final isAutoAssignedAppliance = appliance.code == 'HSV421' || appliance.code == 'HMV421' || appliance.code == 'FP421M' || appliance.code == 'FP422M' || appliance.code == 'FP421' || appliance.code == 'FP422';
    final bool hasCfsAssigned = positions.any(
      (p) => p.role == 'CFS' && p.personnel != null,
    );
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${appliance.code}${appliance.vehicleNumber != null ? ' (${appliance.vehicleNumber})' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isAutoAssignedAppliance)
                  Tooltip(
                    message: 'Some roles are auto-assigned from a linked vehicle. You can still change them.',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Auto-assigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                if (appliance.code == 'IV421' && hasCfsAssigned)
                  Tooltip(
                    message: 'Pick which CFS officer takes this manning',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'CFS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...positions.map((position) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: _buildPositionDropdown(position, appliance.code),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord != null ? 'Edit Manning' : 'New Manning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveManning,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                const Text('Manning Date:'),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedDate != null 
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _appliances.length,
              itemBuilder: (context, index) {
                return _buildApplianceCard(_appliances[index]);
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveManning,
                icon: const Icon(Icons.save, size: 20),
                label: const Text(
                  'Save Manning',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}