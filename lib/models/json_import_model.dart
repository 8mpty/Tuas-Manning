class JsonImportData {
  final int rota;
  final String organization;
  final Map<String, dynamic> personnel;
  
  JsonImportData({
    required this.rota,
    required this.organization,
    required this.personnel,
  });
  
  factory JsonImportData.fromJson(Map<String, dynamic> json) {
    return JsonImportData(
      rota: json['rota'] as int,
      organization: json['organization'] as String,
      personnel: json['personnel'] as Map<String, dynamic>,
    );
  }
}