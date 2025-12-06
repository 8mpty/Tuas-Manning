import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuas_manning_2/models/manning_record.dart';
import 'package:tuas_manning_2/services/database_service.dart';
import 'package:tuas_manning_2/screens/manning_form.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:tuas_manning_2/data/appliance_definitions.dart';
import 'package:tuas_manning_2/models/appliance.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DatabaseService _dbService;
  List<ManningRecord> _records = [];
  final List<Appliance> _appliances = ApplianceDefinitions.getAppliances();
  
  @override
  void initState() {
    super.initState();
    _dbService = context.read<DatabaseService>();
    _loadRecords();
  }
  
  void _loadRecords() {
    setState(() {
      _records = _dbService.getAllRecords();
      _records.sort((a, b) => b.date.compareTo(a.date));
    });
  }
  
  void _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _dbService.deleteRecord(id);
      _loadRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted')),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  void _showRecordDetails(ManningRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Manning Details - ${_formatDate(record.date)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _buildAllApplianceDetails(record),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(record),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Copy',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(ManningRecord record) async {
    final String manningText = _formatManningDetails(record);
    
    await Clipboard.setData(ClipboardData(text: manningText));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manning details copied to clipboard'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatManningDetails(ManningRecord record) {
    final StringBuffer buffer = StringBuffer();
    
    buffer.writeln('Tuas Manning Details - ${_formatDate(record.date)}');
    buffer.writeln('Rota: ${record.rota} - ${record.organization}');
    buffer.writeln('Created: ${_formatDateTime(record.createdAt)}');
    buffer.writeln();
    
    for (var appliance in _appliances) {
      final positions = record.appliances[appliance.code];
      if (positions != null && positions.isNotEmpty) {
        bool hasAnyAssignment = false;
        final roleLines = <String>[];
        
        for (var position in positions) {
          if (position.personnel != null) {
            hasAnyAssignment = true;
            roleLines.add('${position.role}: ${position.personnel!.toString()}');
          } else if (position.role == 'CFS' && appliance.code == 'IV421') {
            hasAnyAssignment = true;
            roleLines.add('${position.role}: CFS Personnel');
          } else {
            roleLines.add('${position.role}: NULL');
          }
        }
        
        if (hasAnyAssignment) {
          final vehicleInfo = appliance.vehicleNumber != null ? ' (${appliance.vehicleNumber})' : '';
          buffer.writeln('${appliance.code}$vehicleInfo');
          for (var line in roleLines) {
            buffer.writeln('  $line');
          }
          buffer.writeln();
        }
      }
    }
    
    return buffer.toString();
  }

  List<Widget> _buildAllApplianceDetails(ManningRecord record) {
    final widgets = <Widget>[];
    
    widgets.addAll([
      Text(
        'Rota: ${record.rota}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      Text(
        'Organization: ${record.organization}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      Text(
        'Created: ${_formatDateTime(record.createdAt)}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 16),
      const Divider(),
    ]);
    
    bool hasAnyAssignment = false;
    
    for (var appliance in _appliances) {
      final positions = record.appliances[appliance.code];
      if (positions != null && positions.isNotEmpty) {
        final roleWidgets = <Widget>[];
        bool applianceHasAssignment = false;
        
        for (var position in positions) {
          if (position.personnel != null || position.role == 'CFS') {
            applianceHasAssignment = true;
            hasAnyAssignment = true;
            
            final personnelText = position.personnel?.toString() ?? 
                (position.role == 'CFS' && appliance.code == 'IV421' ? 'CFS Personnel' : 'NULL');
            
            roleWidgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      child: Text(
                        '${position.role}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        personnelText,
                        style: TextStyle(
                          color: position.personnel != null ? 
                              Colors.green : 
                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        
        if (applianceHasAssignment) {
          final vehicleInfo = appliance.vehicleNumber != null ? ' (${appliance.vehicleNumber})' : '';
          
          widgets.addAll([
            const SizedBox(height: 16),
            Text(
              '${appliance.code}$vehicleInfo',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            ...roleWidgets,
          ]);
        }
      }
    }
    
    if (!hasAnyAssignment) {
      widgets.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No assignments found for this date.', textAlign: TextAlign.center),
      ));
    }
    
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manning History'),
      ),
      body: _records.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No manning records found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.pink),
                    title: Text(
                      'Manning - ${_formatDate(record.date)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rota: ${record.rota} - ${record.organization}'),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${_formatDateTime(record.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManningFormScreen(
                                  existingRecord: record,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadRecords();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteRecord(record.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showRecordDetails(record);
                    },
                  ),
                );
              },
            ),
    );
  }
}