import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuas_manning_2/models/personnel_type.dart';
import 'package:tuas_manning_2/services/database_service.dart';
import 'package:tuas_manning_2/screens/manning_form.dart';
import 'package:tuas_manning_2/screens/history_screen.dart';
import 'package:tuas_manning_2/screens/personnel_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _fileName;
  String? _errorMessage;
  late DatabaseService _dbService;
  
  @override
  void initState() {
    super.initState();
    _dbService = context.read<DatabaseService>();
    _checkExistingData();
  }
  
  Future<void> _checkExistingData() async {
    setState(() {
      _isLoading = true;
    });
    
    await _dbService.init();
    
    if (_dbService.hasData()) {
      setState(() {
        _fileName = 'Previously Imported Data';
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _importJson() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        _fileName = result.files.first.name;
        
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          String fileContents = utf8.decode(bytes);
          final jsonData = jsonDecode(fileContents) as Map<String, dynamic>;
          
          try {
            _validateJsonStructure(jsonData);
            
            await _dbService.importJson(jsonData);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully imported $_fileName'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {});
            }
          } catch (e) {
            setState(() {
              _errorMessage = e.toString();
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invalid JSON structure: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error during file picking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _validateJsonStructure(Map<String, dynamic> json) {
    if (!json.containsKey('rota') || json['rota'] is! int) {
      throw FormatException('Missing or invalid "rota" field (must be integer)');
    }
    
    if (!json.containsKey('organization') || json['organization'] is! String) {
      throw FormatException('Missing or invalid "organization" field');
    }
    
    if (!json.containsKey('personnel') || json['personnel'] is! Map) {
      throw FormatException('Missing or invalid "personnel" field');
    }
    
    final personnel = json['personnel'] as Map<String, dynamic>;
    
    if (!personnel.containsKey('CFS') || personnel['CFS'] is! Map) {
      throw FormatException('Missing or invalid "CFS" section');
    }
    
    if (!personnel.containsKey('Firefighters') || personnel['Firefighters'] is! Map) {
      throw FormatException('Missing or invalid "Firefighters" section');
    }
    
    if (personnel.containsKey('Alpha') && personnel['Alpha'] is! Map) {
      throw FormatException('Invalid "Alpha" section');
    }
  }

  void _navigateToManningForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManningFormScreen(),
      ),
    );
  }
  
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }
  
  void _navigateToPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonnelScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tuas Manning"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fileName == null
              ? _buildEmptyState()
              : _buildFileImportedState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Import Personnel JSON file to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _importJson,
              icon: const Icon(Icons.file_upload),
              label: const Text('Import JSON'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileImportedState() {
    final config = _dbService.getConfig();
    final personnelCount = _dbService.getAllPersonnel().length;
    final alphaCount = _dbService.getPersonnelByType(PersonnelType.alpha).length;
    final firefighterCount = _dbService.getPersonnelByType(PersonnelType.firefighter).length;
    final cfsCount = _dbService.getPersonnelByType(PersonnelType.cfs).length;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_download_done,
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(height: 15),
            Text(
              'Data Loaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.format_list_numbered),
                      title: Text('Rota: ${config['rota']}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: Text('Total Personnel: $personnelCount'),
                      subtitle: Text('Alpha: $alphaCount • Firefighters: $firefighterCount • CFS: $cfsCount'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToManningForm,
                icon: const Icon(Icons.add),
                label: const Text('Create New Manning'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToPersonnel,
                icon: const Icon(Icons.people_alt),
                label: const Text('View/Update Personnel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToHistory,
                icon: const Icon(Icons.history),
                label: const Text('View Manning History'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _importJson,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-import Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}