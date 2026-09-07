import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuas_manning_2/models/personnel.dart';
import 'package:tuas_manning_2/models/personnel_type.dart';
import 'package:tuas_manning_2/services/database_service.dart';

import 'package:tuas_manning_2/helpers/export_helper_web.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  late DatabaseService _dbService;
  late List<Personnel> _allPersonnel;
  Map<String, dynamic> _config = {};

  @override
  void initState() {
    super.initState();
    _dbService = context.read<DatabaseService>();
    _allPersonnel = _dbService.getAllPersonnel();
    _config = _dbService.getConfig();
  }

  Future<void> _addPersonnel() async {
    String? selectedCategory = 'Firefighters';
    final rankController = TextEditingController();
    final nameController = TextEditingController();
    final fullRankController = TextEditingController();
    final hpController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Personnel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CFS', child: Text('CFS')),
                    DropdownMenuItem(
                      value: 'Firefighters',
                      child: Text('Firefighters'),
                    ),
                    DropdownMenuItem(
                      value: 'Alpha',
                      child: Text('Alpha'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rankController,
                  decoration: const InputDecoration(
                    labelText: 'Rank Abbreviation (e.g., LTA, CPL)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fullRankController,
                  decoration: const InputDecoration(
                    labelText: 'Full Rank',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hpController,
                  decoration: const InputDecoration(
                    labelText: 'HP (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (rankController.text.trim().isEmpty ||
                    nameController.text.trim().isEmpty ||
                    fullRankController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      PersonnelType personnelType;
      switch (selectedCategory) {
        case 'CFS':
          personnelType = PersonnelType.cfs;
          break;
        case 'Alpha':
          personnelType = PersonnelType.alpha;
          break;
        case 'Firefighters':
        default:
          personnelType = PersonnelType.firefighter;
          break;
      }

      final newPersonnel = Personnel(
        rankAbbreviation: rankController.text.trim().toUpperCase(),
        name: nameController.text.trim(),
        fullRank: fullRankController.text.trim(),
        hp: hpController.text.trim().isEmpty ? null : hpController.text.trim(),
        type: personnelType,
      );

      await _dbService.savePersonnel(newPersonnel);
      
      setState(() {
        _allPersonnel = _dbService.getAllPersonnel();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personnel added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editPersonnel(Personnel personnel) async {
    final nameController = TextEditingController(text: personnel.name);
    final fullRankController = TextEditingController(text: personnel.fullRank);
    final hpController = TextEditingController(text: personnel.hp ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Personnel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullRankController,
                decoration: const InputDecoration(
                  labelText: 'Full Rank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hpController,
                decoration: const InputDecoration(
                  labelText: 'HP (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedPersonnel = Personnel(
        rankAbbreviation: personnel.rankAbbreviation,
        name: nameController.text.trim(),
        fullRank: fullRankController.text.trim(),
        hp: hpController.text.trim().isEmpty ? null : hpController.text.trim(),
        type: personnel.type,
        id: personnel.id,
      );

      await _dbService.savePersonnel(updatedPersonnel);
      
      setState(() {
        _allPersonnel = _dbService.getAllPersonnel();
      });
    }
  }

  Future<void> _deletePersonnel(Personnel personnel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Personnel'),
        content: Text(
          'Are you sure you want to delete ${personnel.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbService.deletePersonnel(personnel.id);
      
      setState(() {
        _allPersonnel = _dbService.getAllPersonnel();
      });
    }
  }

  Map<String, dynamic> _generateExportData() {
    final personnelMap = {
      'CFS': <String, dynamic>{},
      'Firefighters': <String, dynamic>{},
      'Alpha': <String, dynamic>{},
    };

    for (var person in _allPersonnel) {
      final personData = {
        'name': person.name,
        'full_rank': person.fullRank,
        'hp': person.hp,
      };

      String categoryKey;
      switch (person.type) {
        case PersonnelType.cfs:
          categoryKey = 'CFS';
          break;
        case PersonnelType.firefighter:
          categoryKey = 'Firefighters';
          break;
        case PersonnelType.alpha:
          categoryKey = 'Alpha';
          break;
      }

      if (!personnelMap[categoryKey]!.containsKey(person.rankAbbreviation)) {
        personnelMap[categoryKey]![person.rankAbbreviation] = <dynamic>[];
      }
      (personnelMap[categoryKey]![person.rankAbbreviation] as List).add(personData);
    }
    final cfsRanks = personnelMap['CFS']!;
    for (final rank in cfsRanks.keys.toList()) {
      final officers = cfsRanks[rank] as List;
      if (officers.length == 1) {
        cfsRanks[rank] = officers.first;
      }
    }

    return {
      'rota': _config['rota'] ?? 0,
      'organization': _config['organization'] ?? '',
      'personnel': personnelMap,
    };
  }

  Future<void> _exportJson() async {
    try {
      final exportData = _generateExportData();
      final jsonString = jsonEncode(exportData);
      final rota = _config['rota'] ?? 0;
      final organization = (_config['organization'] as String?)?.replaceAll(' ', '_').toLowerCase() ?? 'unknown';
      final fileName = 'rota_${rota}_personnel_export.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      await exportFile(bytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personnel data exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Map<String, List<Personnel>> _organizePersonnelByCategory() {
    final Map<String, List<Personnel>> organized = {
      'CFS': [],
      'Firefighters': [],
      'Alpha': [],
    };

    for (var person in _allPersonnel) {
      switch (person.type) {
        case PersonnelType.cfs:
          organized['CFS']!.add(person);
          break;
        case PersonnelType.firefighter:
          organized['Firefighters']!.add(person);
          break;
        case PersonnelType.alpha:
          organized['Alpha']!.add(person);
          break;
      }
    }

    for (var category in organized.keys) {
      organized[category]!.sort(Personnel.compareByRank);
    }

    return organized;
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        category,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRankSection(String rank, List<Personnel> personnel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              rank,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...List.generate(personnel.length, (index) {
            final person = personnel[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  person.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(person.name),
              subtitle: Text(
                person.hp != null
                    ? '${person.fullRank} • ${person.hp}'
                    : person.fullRank,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editPersonnel(person),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePersonnel(person),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final organizedPersonnel = _organizePersonnelByCategory();
    final hasCFS = organizedPersonnel['CFS']!.isNotEmpty;
    final hasFirefighters = organizedPersonnel['Firefighters']!.isNotEmpty;
    final hasAlpha = organizedPersonnel['Alpha']!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Management'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'add':
                  _addPersonnel();
                  break;
                case 'export':
                  _exportJson();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Personnel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Export Personnel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _allPersonnel.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No personnel data found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Import JSON file or add personnel manually',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_config['organization'] != null || _config['rota'] != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_config['organization'] != null)
                            Text(
                              'Organization: ${_config['organization']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          if (_config['rota'] != null)
                            Text(
                              'Rota: ${_config['rota']}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                if (hasCFS) ...[
                  _buildCategoryHeader('CFS'),
                  const SizedBox(height: 8),
                  ...organizedPersonnel['CFS']!.fold<Map<String, List<Personnel>>>(
                    {},
                    (map, person) {
                      if (!map.containsKey(person.rankAbbreviation)) {
                        map[person.rankAbbreviation] = [];
                      }
                      map[person.rankAbbreviation]!.add(person);
                      return map;
                    },
                  ).entries.map(
                    (entry) => _buildRankSection(entry.key, entry.value),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (hasFirefighters) ...[
                  _buildCategoryHeader('Firefighters'),
                  const SizedBox(height: 8),
                  ...organizedPersonnel['Firefighters']!.fold<Map<String, List<Personnel>>>(
                    {},
                    (map, person) {
                      if (!map.containsKey(person.rankAbbreviation)) {
                        map[person.rankAbbreviation] = [];
                      }
                      map[person.rankAbbreviation]!.add(person);
                      return map;
                    },
                  ).entries.map(
                    (entry) => _buildRankSection(entry.key, entry.value),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (hasAlpha) ...[
                  _buildCategoryHeader('Alpha'),
                  const SizedBox(height: 8),
                  ...organizedPersonnel['Alpha']!.fold<Map<String, List<Personnel>>>(
                    {},
                    (map, person) {
                      if (!map.containsKey(person.rankAbbreviation)) {
                        map[person.rankAbbreviation] = [];
                      }
                      map[person.rankAbbreviation]!.add(person);
                      return map;
                    },
                  ).entries.map(
                    (entry) => _buildRankSection(entry.key, entry.value),
                  ),
                ],
              ],
            ),
    );
  }
}