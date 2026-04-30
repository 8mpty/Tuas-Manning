import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuas_manning_2/home_page.dart';
import 'package:tuas_manning_2/services/database_service.dart';
import 'package:tuas_manning_2/models/personnel.dart';
import 'package:tuas_manning_2/models/appliance.dart';
import 'package:tuas_manning_2/models/manning_record.dart';
import 'package:tuas_manning_2/models/personnel_type.dart';
import 'package:tuas_manning_2/models/rank.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  Hive.registerAdapter(PersonnelAdapter());
  Hive.registerAdapter(ApplianceAdapter());
  Hive.registerAdapter(PositionAdapter());
  Hive.registerAdapter(ManningRecordAdapter());
  Hive.registerAdapter(PersonnelTypeAdapter());
  Hive.registerAdapter(RankAdapter());
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => DatabaseService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}